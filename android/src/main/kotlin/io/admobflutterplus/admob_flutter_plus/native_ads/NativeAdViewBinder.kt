package io.admobflutterplus.admob_flutter_plus.native_ads

import android.graphics.drawable.GradientDrawable
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.google.android.libraries.ads.mobile.sdk.nativead.MediaView
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAd
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdView
import io.admobflutterplus.admob_flutter_plus.R

/**
 * Canonical asset tags for custom (Flutter asset) templates and matching
 * resource ids for built-in layouts.
 */
object NativeAdTags {
    const val AD_VIEW = "ad_view"
    const val HEADLINE = "ad_headline"
    const val BODY = "ad_body"
    const val ICON = "ad_app_icon"
    const val CTA = "ad_call_to_action"
    const val ATTRIBUTION = "ad_attribution"
    const val MEDIA = "ad_media"
    const val ADVERTISER = "ad_advertiser"
    const val PRICE = "ad_price"
    const val STORE = "ad_store"
    const val STARS = "ad_stars"
}

/** Resolves and binds native ad assets into an inflated template root. */
internal object NativeAdViewBinder {

    fun resolveAdView(root: View): NativeAdView {
        if (root is NativeAdView) return root
        val tagged = root.findViewWithTag<View>(NativeAdTags.AD_VIEW)
        if (tagged is NativeAdView) return tagged
        val byId = root.findViewById<NativeAdView?>(R.id.ad_view)
        if (byId != null) return byId
        throw NativeTemplateException(
            "Template must contain a NativeAdView root or a view tagged \"${NativeAdTags.AD_VIEW}\".",
        )
    }

    fun hasMedia(root: View): Boolean =
        resolveOptional<MediaView>(root, NativeAdTags.MEDIA, R.id.ad_media) != null

    fun bind(
        root: View,
        ad: NativeAd,
        style: Map<String, Any?>?,
        disposed: () -> Boolean,
        registerWithMedia: (NativeAdView, MediaView) -> Unit,
    ) {
        val adView = resolveAdView(root)

        val headline = resolveRequired<TextView>(
            root,
            NativeAdTags.HEADLINE,
            R.id.ad_headline,
            "Headline TextView",
        )
        val cta = resolveRequired<View>(
            root,
            NativeAdTags.CTA,
            R.id.ad_call_to_action,
            "Call-to-action view",
        )
        val body = resolveOptional<TextView>(root, NativeAdTags.BODY, R.id.ad_body)
        val icon = resolveOptional<ImageView>(root, NativeAdTags.ICON, R.id.ad_app_icon)
        val attribution =
            resolveOptional<TextView>(root, NativeAdTags.ATTRIBUTION, R.id.ad_attribution)
        val advertiser =
            resolveOptional<TextView>(root, NativeAdTags.ADVERTISER, /* no built-in id */ 0)
        val price = resolveOptional<TextView>(root, NativeAdTags.PRICE, 0)
        val store = resolveOptional<TextView>(root, NativeAdTags.STORE, 0)
        val stars = resolveOptional<View>(root, NativeAdTags.STARS, 0)
        val mediaView = resolveOptional<MediaView>(root, NativeAdTags.MEDIA, R.id.ad_media)

        headline.text = ad.headline
        adView.headlineView = headline

        body?.let {
            it.text = ad.body ?: ""
            it.visibility = if (ad.body.isNullOrEmpty()) View.GONE else View.VISIBLE
            adView.bodyView = it
        }

        icon?.let {
            val iconImage = ad.icon
            if (iconImage?.drawable != null) {
                it.setImageDrawable(iconImage.drawable)
                it.visibility = View.VISIBLE
            } else {
                it.visibility = View.GONE
            }
            adView.iconView = it
        }

        when (cta) {
            is Button -> cta.text = ad.callToAction ?: ""
            is TextView -> cta.text = ad.callToAction ?: ""
        }
        adView.callToActionView = cta

        advertiser?.let {
            val value = ad.advertiser
            it.text = value ?: ""
            it.visibility = if (value.isNullOrEmpty()) View.GONE else View.VISIBLE
            adView.advertiserView = it
        }

        price?.let {
            val value = ad.price
            it.text = value ?: ""
            it.visibility = if (value.isNullOrEmpty()) View.GONE else View.VISIBLE
            adView.priceView = it
        }

        store?.let {
            val value = ad.store
            it.text = value ?: ""
            it.visibility = if (value.isNullOrEmpty()) View.GONE else View.VISIBLE
            adView.storeView = it
        }

        stars?.let { starView ->
            val rating = ad.starRating
            if (rating != null && rating > 0) {
                starView.visibility = View.VISIBLE
                when (starView) {
                    is RatingBar -> starView.rating = rating.toFloat()
                    is TextView -> starView.text = "%.1f".format(rating)
                }
            } else {
                starView.visibility = View.GONE
            }
            adView.starRatingView = starView
        }

        applyStyle(
            root = root,
            headline = headline,
            body = body,
            cta = cta,
            attribution = attribution,
            advertiser = advertiser,
            price = price,
            store = store,
            stars = stars as? TextView,
            style = style,
        )

        if (mediaView != null) {
            mediaView.post {
                if (disposed()) return@post
                if (mediaView.width == 0 || mediaView.height == 0) {
                    mediaView.post {
                        if (!disposed()) registerWithMedia(adView, mediaView)
                    }
                } else {
                    registerWithMedia(adView, mediaView)
                }
            }
        } else {
            adView.registerNativeAd(ad, null)
        }
    }

    private fun applyStyle(
        root: View,
        headline: TextView,
        body: TextView?,
        cta: View,
        attribution: TextView?,
        advertiser: TextView?,
        price: TextView?,
        store: TextView?,
        stars: TextView?,
        style: Map<String, Any?>?,
    ) {
        val s = style ?: emptyMap()

        (s["cardColor"] as? Number)?.let { root.setBackgroundColor(it.toInt()) }
        (s["titleColor"] as? Number)?.let { headline.setTextColor(it.toInt()) }
        (s["descriptionColor"] as? Number)?.let { body?.setTextColor(it.toInt()) }

        if (cta is TextView) {
            (s["ctaText"] as? String)?.let { cta.text = it }
            (s["ctaTextColor"] as? Number)?.let { cta.setTextColor(it.toInt()) }
        }

        val ctaColor = (s["ctaColor"] as? Number)?.toInt()
        val ctaRadius = (s["ctaCornerRadius"] as? Number)?.toFloat()
        val ctaHeight = (s["ctaHeight"] as? Number)?.toFloat()
        if (ctaColor != null || ctaRadius != null) {
            val bg = GradientDrawable()
            ctaColor?.let { bg.setColor(it) }
            ctaRadius?.let {
                bg.cornerRadius = it * root.resources.displayMetrics.density
            }
            cta.background = bg
        }
        if (ctaHeight != null) {
            val px = (ctaHeight * root.resources.displayMetrics.density).toInt()
            val lp = cta.layoutParams
            if (lp != null) {
                lp.height = px
                cta.layoutParams = lp
            }
        }

        attribution?.let { badge ->
            (s["adBadgeText"] as? String)?.let { badge.text = it }
            (s["adBadgeTextColor"] as? Number)?.let { badge.setTextColor(it.toInt()) }
            val badgeColor = (s["adBadgeColor"] as? Number)?.toInt()
            val borderColor = (s["adBadgeBorderColor"] as? Number)?.toInt()
            if (badgeColor != null || borderColor != null) {
                val bg = GradientDrawable()
                badgeColor?.let { bg.setColor(it) }
                borderColor?.let {
                    bg.setStroke((1 * root.resources.displayMetrics.density).toInt(), it)
                }
                badge.background = bg
            }
        }

        val fontFamily = (s["fontFamily"] as? String)?.takeIf { it.isNotBlank() }
        if (fontFamily != null) {
            val textViews = listOfNotNull(
                headline,
                body,
                attribution,
                advertiser,
                price,
                store,
                stars,
                cta as? TextView,
            )
            for (tv in textViews) {
                applyFontFamily(tv, fontFamily)
            }
        }
    }

    private fun applyFontFamily(textView: TextView, family: String) {
        val style = when {
            textView.typeface?.isBold == true && textView.typeface?.isItalic == true ->
                android.graphics.Typeface.BOLD_ITALIC
            textView.typeface?.isBold == true -> android.graphics.Typeface.BOLD
            textView.typeface?.isItalic == true -> android.graphics.Typeface.ITALIC
            else -> android.graphics.Typeface.NORMAL
        }
        textView.typeface = android.graphics.Typeface.create(family, style)
    }

    private inline fun <reified T : View> resolveRequired(
        root: View,
        tag: String,
        id: Int,
        label: String,
    ): T {
        val view = resolveOptional<T>(root, tag, id)
            ?: throw NativeTemplateException(
                "Missing required $label. Add android:tag=\"$tag\" (asset templates) " +
                    "or @+id/$tag (built-in layouts).",
            )
        return view
    }

    private inline fun <reified T : View> resolveOptional(
        root: View,
        tag: String,
        id: Int,
    ): T? {
        val byTag = root.findViewWithTag<View>(tag)
        if (byTag is T) return byTag
        if (id != 0) {
            val byId = root.findViewById<View?>(id)
            if (byId is T) return byId
        }
        // Deep search: LayoutInflater from assets may nest tags under groups.
        return findTagged(root, tag) as? T
    }

    private fun findTagged(root: View, tag: String): View? {
        if (root.tag == tag) return root
        if (root is ViewGroup) {
            for (i in 0 until root.childCount) {
                val found = findTagged(root.getChildAt(i), tag)
                if (found != null) return found
            }
        }
        return null
    }
}
