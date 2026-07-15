package io.admobflutterplus.admob_flutter_plus.native_ads

import android.content.Context
import android.graphics.drawable.GradientDrawable
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.libraries.ads.mobile.sdk.nativead.MediaView
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAd
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdView
import io.admobflutterplus.admob_flutter_plus.R
import io.flutter.plugin.platform.PlatformView

/** Native template variants. */
enum class NativeTemplate(val layoutRes: Int, val hasMedia: Boolean) {
    BANNER(R.layout.native_banner_ad, false),
    SMALL(R.layout.native_small_ad, false),
    LARGE(R.layout.native_large_ad, true),
}

/**
 * PlatformView that binds a loaded [NativeAd] to a template layout.
 *
 * Native Validator compliance:
 * - Banner and small templates never register an undersized [MediaView];
 *   they register without media.
 * - The large template defers `registerNativeAd(nativeAd, mediaView)` until the
 *   [MediaView] has a measured, non-zero size to avoid a 0×0 media violation.
 * - Registration is guarded so it never runs after the view is disposed.
 */
class NextGenNativeAdView(
    context: Context,
    private val template: NativeTemplate,
    private val nativeAd: NativeAd?,
    private val style: Map<String, Any?>?,
) : PlatformView {

    private var disposed = false
    private val root: View =
        LayoutInflater.from(context).inflate(template.layoutRes, null, false)

    init {
        bind()
    }

    override fun getView(): View = root

    override fun dispose() {
        disposed = true
    }

    private fun bind() {
        val ad = nativeAd ?: return
        val adView = root.findViewById<NativeAdView>(R.id.ad_view)

        val headline = root.findViewById<TextView>(R.id.ad_headline)
        val body = root.findViewById<TextView?>(R.id.ad_body)
        val icon = root.findViewById<ImageView?>(R.id.ad_app_icon)
        val cta = root.findViewById<Button>(R.id.ad_call_to_action)
        val attribution = root.findViewById<TextView?>(R.id.ad_attribution)

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

        cta.text = ad.callToAction ?: ""
        adView.callToActionView = cta

        applyStyle(headline, body, cta, attribution)

        if (template.hasMedia) {
            val mediaView = root.findViewById<MediaView>(R.id.ad_media)
            // Defer registration until the MediaView is laid out with a
            // non-zero size to satisfy the Native Validator.
            mediaView.post {
                if (disposed) return@post
                if (mediaView.width == 0 || mediaView.height == 0) {
                    // Re-post until measured.
                    mediaView.post { registerWithMedia(adView, mediaView) }
                } else {
                    registerWithMedia(adView, mediaView)
                }
            }
        } else {
            adView.registerNativeAd(ad, null)
        }
    }

    private fun registerWithMedia(adView: NativeAdView, mediaView: MediaView) {
        if (disposed) return
        val ad = nativeAd ?: return
        adView.registerNativeAd(ad, mediaView)
    }

    private fun applyStyle(
        headline: TextView,
        body: TextView?,
        cta: Button,
        attribution: TextView?,
    ) {
        val s = style ?: return

        (s["cardColor"] as? Number)?.let { root.setBackgroundColor(it.toInt()) }
        (s["titleColor"] as? Number)?.let { headline.setTextColor(it.toInt()) }
        (s["descriptionColor"] as? Number)?.let { body?.setTextColor(it.toInt()) }

        (s["ctaText"] as? String)?.let { cta.text = it }
        (s["ctaTextColor"] as? Number)?.let { cta.setTextColor(it.toInt()) }

        val ctaColor = (s["ctaColor"] as? Number)?.toInt()
        val ctaRadius = (s["ctaCornerRadius"] as? Number)?.toFloat()
        if (ctaColor != null || ctaRadius != null) {
            val bg = GradientDrawable()
            ctaColor?.let { bg.setColor(it) }
            ctaRadius?.let { bg.cornerRadius = it * root.resources.displayMetrics.density }
            cta.background = bg
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
    }
}
