package io.admobflutterplus.admob_flutter_plus.native_ads

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.text.TextUtils
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.RatingBar
import android.widget.TextView
import com.google.android.libraries.ads.mobile.sdk.nativead.MediaView
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdView
import io.flutter.FlutterInjector
import org.xmlpull.v1.XmlPullParser
import org.xmlpull.v1.XmlPullParserFactory
import java.io.IOException
import java.io.InputStreamReader
import java.nio.charset.StandardCharsets

/**
 * Inflates a native ad layout XML stored as a Flutter asset.
 *
 * Android's [android.view.LayoutInflater] cannot inflate non-resource
 * [XmlPullParser] streams (`XmlPullAttributes` is not an `XmlBlock$Parser`).
 * This inflater builds the view tree programmatically from asset XML instead.
 *
 * Asset templates must use [android:tag] values (not `@+id`) for binding:
 * `ad_view`, `ad_headline`, `ad_call_to_action`, and optional asset tags.
 */
object NativeTemplateAssetInflater {

    private const val ANDROID_NS = "http://schemas.android.com/apk/res/android"

    fun inflate(context: Context, assetPath: String, packageName: String?): View {
        val loader = FlutterInjector.instance().flutterLoader()
        val key = if (packageName.isNullOrBlank()) {
            loader.getLookupKeyForAsset(assetPath)
        } else {
            loader.getLookupKeyForAsset(assetPath, packageName)
        }

        val stream = try {
            context.assets.open(key)
        } catch (e: IOException) {
            throw NativeTemplateException(
                "Native ad template not found: \"$assetPath\"" +
                    (if (packageName.isNullOrBlank()) "" else " (package: $packageName)") +
                    ". Declare it under flutter/assets in pubspec.yaml.",
            )
        }

        return stream.use { input ->
            val factory = XmlPullParserFactory.newInstance()
            factory.isNamespaceAware = true
            val parser = factory.newPullParser()
            parser.setInput(InputStreamReader(input, StandardCharsets.UTF_8))

            var event = parser.eventType
            while (event != XmlPullParser.START_TAG && event != XmlPullParser.END_DOCUMENT) {
                event = parser.next()
            }
            if (event != XmlPullParser.START_TAG) {
                throw NativeTemplateException(
                    "Invalid native ad template XML (no root element): \"$assetPath\"",
                )
            }

            try {
                parseView(context, parser, parent = null)
            } catch (e: NativeTemplateException) {
                throw e
            } catch (e: Exception) {
                throw NativeTemplateException(
                    "Failed to inflate native ad template \"$assetPath\": ${e.message}",
                )
            }
        }
    }

    private fun parseView(
        context: Context,
        parser: XmlPullParser,
        parent: ViewGroup?,
    ): View {
        val name = parser.name
        val depth = parser.depth
        val view = createView(context, name)
        applyCommonAttributes(context, view, parser)
        applyTypeAttributes(context, view, parser)

        val layoutParams = createLayoutParams(context, parent, parser)
        view.layoutParams = layoutParams

        if (parser.isEmptyElementTag) {
            parser.next()
            return view
        }

        var event = parser.next()
        while (!(event == XmlPullParser.END_TAG && parser.depth == depth) &&
            event != XmlPullParser.END_DOCUMENT
        ) {
            if (event == XmlPullParser.START_TAG) {
                if (view !is ViewGroup) {
                    throw NativeTemplateException(
                        "Element <$name> cannot have children.",
                    )
                }
                val child = parseView(context, parser, parent = view)
                view.addView(child)
            }
            event = parser.next()
        }
        return view
    }

    private fun createView(context: Context, name: String): View {
        return when (name) {
            "com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdView",
            "NativeAdView",
            -> NativeAdView(context)

            "com.google.android.libraries.ads.mobile.sdk.nativead.MediaView",
            "MediaView",
            -> MediaView(context)

            "LinearLayout" -> LinearLayout(context)
            "FrameLayout" -> FrameLayout(context)
            "TextView" -> TextView(context)
            "Button" -> Button(context).apply {
                // Avoid Material theme padding surprises for asset templates.
                minHeight = 0
                minimumHeight = 0
                setAllCaps(false)
            }
            "ImageView" -> ImageView(context)
            "RatingBar" -> RatingBar(context, null, android.R.attr.ratingBarStyleSmall)
            else -> throw NativeTemplateException(
                "Unsupported view in native ad template: <$name>. " +
                    "Supported: NativeAdView, MediaView, LinearLayout, FrameLayout, " +
                    "TextView, Button, ImageView, RatingBar.",
            )
        }
    }

    private fun applyCommonAttributes(context: Context, view: View, parser: XmlPullParser) {
        attr(parser, "tag")?.let { view.tag = it }

        attr(parser, "background")?.let { raw ->
            parseColor(raw)?.let { view.setBackgroundColor(it) }
        }

        val pad = attrDimensionPx(context, parser, "padding")
        val padL = attrDimensionPx(context, parser, "paddingLeft")
            ?: attrDimensionPx(context, parser, "paddingStart")
        val padR = attrDimensionPx(context, parser, "paddingRight")
            ?: attrDimensionPx(context, parser, "paddingEnd")
        val padT = attrDimensionPx(context, parser, "paddingTop")
        val padB = attrDimensionPx(context, parser, "paddingBottom")
        if (pad != null || padL != null || padR != null || padT != null || padB != null) {
            view.setPadding(
                padL ?: pad ?: view.paddingLeft,
                padT ?: pad ?: view.paddingTop,
                padR ?: pad ?: view.paddingRight,
                padB ?: pad ?: view.paddingBottom,
            )
        }
    }

    private fun applyTypeAttributes(context: Context, view: View, parser: XmlPullParser) {
        when (view) {
            is LinearLayout -> {
                view.orientation = when (attr(parser, "orientation")) {
                    "horizontal" -> LinearLayout.HORIZONTAL
                    else -> LinearLayout.VERTICAL
                }
                attr(parser, "gravity")?.let { view.gravity = parseGravity(it) }
            }
            is TextView -> {
                attr(parser, "text")?.let { view.text = it }
                attr(parser, "textColor")?.let { raw ->
                    parseColor(raw)?.let { view.setTextColor(it) }
                }
                attr(parser, "textSize")?.let { raw ->
                    val (value, unit) = parseTypedValue(raw)
                    view.setTextSize(unit, value)
                }
                attr(parser, "textStyle")?.let { style ->
                    val bold = style.contains("bold")
                    val italic = style.contains("italic")
                    val typeface = when {
                        bold && italic -> Typeface.BOLD_ITALIC
                        bold -> Typeface.BOLD
                        italic -> Typeface.ITALIC
                        else -> Typeface.NORMAL
                    }
                    view.setTypeface(view.typeface, typeface)
                }
                attr(parser, "maxLines")?.toIntOrNull()?.let { view.maxLines = it }
                when (attr(parser, "ellipsize")) {
                    "end" -> view.ellipsize = TextUtils.TruncateAt.END
                    "start" -> view.ellipsize = TextUtils.TruncateAt.START
                    "middle" -> view.ellipsize = TextUtils.TruncateAt.MIDDLE
                    "marquee" -> view.ellipsize = TextUtils.TruncateAt.MARQUEE
                }
                attr(parser, "gravity")?.let { view.gravity = parseGravity(it) }
            }
            is ImageView -> {
                when (attr(parser, "scaleType")) {
                    "fitCenter" -> view.scaleType = ImageView.ScaleType.FIT_CENTER
                    "centerCrop" -> view.scaleType = ImageView.ScaleType.CENTER_CROP
                    "fitXY" -> view.scaleType = ImageView.ScaleType.FIT_XY
                    "centerInside" -> view.scaleType = ImageView.ScaleType.CENTER_INSIDE
                    "center" -> view.scaleType = ImageView.ScaleType.CENTER
                }
            }
        }
    }

    private fun createLayoutParams(
        context: Context,
        parent: ViewGroup?,
        parser: XmlPullParser,
    ): ViewGroup.LayoutParams {
        val width = parseLayoutSize(context, attr(parser, "layout_width"), matchDefault = true)
        val height = parseLayoutSize(context, attr(parser, "layout_height"), matchDefault = false)

        val params = when (parent) {
            is LinearLayout -> LinearLayout.LayoutParams(width, height).also { lp ->
                attr(parser, "layout_weight")?.toFloatOrNull()?.let { lp.weight = it }
                attr(parser, "layout_gravity")?.let { lp.gravity = parseGravity(it) }
            }
            is FrameLayout -> FrameLayout.LayoutParams(width, height).also { lp ->
                attr(parser, "layout_gravity")?.let { lp.gravity = parseGravity(it) }
            }
            // NativeAdView is a ViewGroup; MarginLayoutParams are accepted by addView.
            else -> ViewGroup.MarginLayoutParams(width, height)
        }

        if (params is ViewGroup.MarginLayoutParams) {
            val margin = attrDimensionPx(context, parser, "layout_margin")
            val left = attrDimensionPx(context, parser, "layout_marginLeft")
                ?: attrDimensionPx(context, parser, "layout_marginStart")
            val right = attrDimensionPx(context, parser, "layout_marginRight")
                ?: attrDimensionPx(context, parser, "layout_marginEnd")
            val top = attrDimensionPx(context, parser, "layout_marginTop")
            val bottom = attrDimensionPx(context, parser, "layout_marginBottom")
            params.setMargins(
                left ?: margin ?: 0,
                top ?: margin ?: 0,
                right ?: margin ?: 0,
                bottom ?: margin ?: 0,
            )
        }
        return params
    }

    private fun parseLayoutSize(
        context: Context,
        raw: String?,
        matchDefault: Boolean,
    ): Int {
        return when (raw) {
            null -> if (matchDefault) {
                ViewGroup.LayoutParams.MATCH_PARENT
            } else {
                ViewGroup.LayoutParams.WRAP_CONTENT
            }
            "match_parent", "fill_parent" -> ViewGroup.LayoutParams.MATCH_PARENT
            "wrap_content" -> ViewGroup.LayoutParams.WRAP_CONTENT
            else -> attrDimensionPx(context, raw) ?: ViewGroup.LayoutParams.WRAP_CONTENT
        }
    }

    private fun attr(parser: XmlPullParser, name: String): String? {
        return parser.getAttributeValue(ANDROID_NS, name)
            ?: parser.getAttributeValue(null, name)
    }

    private fun attrDimensionPx(
        context: Context,
        parser: XmlPullParser,
        name: String,
    ): Int? = attr(parser, name)?.let { attrDimensionPx(context, it) }

    private fun attrDimensionPx(context: Context, raw: String): Int? {
        if (raw == "@null" || raw.isBlank()) return null
        val trimmed = raw.trim()
        val value = trimmed.replace(Regex("[^0-9.+-]"), "")
        val number = value.toFloatOrNull() ?: return null
        val density = context.resources.displayMetrics.density
        val scaled = context.resources.displayMetrics.scaledDensity
        return when {
            trimmed.endsWith("sp") -> (number * scaled).toInt()
            trimmed.endsWith("px") -> number.toInt()
            else -> (number * density).toInt() // dp default
        }
    }

    private fun parseTypedValue(raw: String): Pair<Float, Int> {
        val value = raw.replace(Regex("[^0-9.+-]"), "").toFloatOrNull() ?: 14f
        return when {
            raw.endsWith("px") -> value to TypedValue.COMPLEX_UNIT_PX
            raw.endsWith("dp") || raw.endsWith("dip") -> value to TypedValue.COMPLEX_UNIT_DIP
            else -> value to TypedValue.COMPLEX_UNIT_SP
        }
    }

    private fun parseColor(raw: String): Int? {
        if (raw.startsWith("@")) return null
        return try {
            Color.parseColor(raw.trim())
        } catch (_: IllegalArgumentException) {
            null
        }
    }

    private fun parseGravity(raw: String): Int {
        var gravity = Gravity.NO_GRAVITY
        for (part in raw.split("|")) {
            gravity = gravity or when (part.trim()) {
                "center" -> Gravity.CENTER
                "center_vertical" -> Gravity.CENTER_VERTICAL
                "center_horizontal" -> Gravity.CENTER_HORIZONTAL
                "start", "left" -> Gravity.START
                "end", "right" -> Gravity.END
                "top" -> Gravity.TOP
                "bottom" -> Gravity.BOTTOM
                "fill" -> Gravity.FILL
                "fill_vertical" -> Gravity.FILL_VERTICAL
                "fill_horizontal" -> Gravity.FILL_HORIZONTAL
                else -> Gravity.NO_GRAVITY
            }
        }
        return gravity
    }
}
