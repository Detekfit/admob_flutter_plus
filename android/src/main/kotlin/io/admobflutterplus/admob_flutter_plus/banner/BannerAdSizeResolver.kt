package io.admobflutterplus.admob_flutter_plus.banner

import android.content.Context
import com.google.android.libraries.ads.mobile.sdk.banner.AdSize

/**
 * Maps Flutter [AdSize] channel maps to Next-Gen [AdSize].
 *
 * Shared by [NextGenBannerAdView] and banner preload so adaptive rules stay
 * identical (anchored → large anchored API, not the deprecated orientation API).
 */
object BannerAdSizeResolver {

    private const val FULL_WIDTH = -1

    fun resolve(context: Context, size: Map<String, Any?>): AdSize {
        val type = size["type"] as? String ?: "anchored"
        val width = (size["width"] as? Number)?.toInt() ?: FULL_WIDTH
        val resolvedWidth = if (width == FULL_WIDTH) fullWidthDp(context) else width

        return when (type) {
            "fixed" -> {
                val w = (size["width"] as? Number)?.toInt() ?: 320
                val h = (size["height"] as? Number)?.toInt() ?: 50
                fixedSize(w, h)
            }
            "anchored" ->
                AdSize.getLargeAnchoredAdaptiveBannerAdSize(context, resolvedWidth)
            "anchoredPortrait" ->
                AdSize.getLargePortraitAnchoredAdaptiveBannerAdSize(context, resolvedWidth)
            "anchoredLandscape" ->
                AdSize.getLargeLandscapeAnchoredAdaptiveBannerAdSize(context, resolvedWidth)
            "inline" -> {
                val maxHeight = (size["maxHeight"] as? Number)?.toInt() ?: 0
                AdSize.getInlineAdaptiveBannerAdSize(resolvedWidth, maxHeight)
            }
            "inlineCurrentOrientation" ->
                AdSize.getCurrentOrientationInlineAdaptiveBannerAdSize(context, resolvedWidth)
            else ->
                AdSize.getLargeAnchoredAdaptiveBannerAdSize(context, resolvedWidth)
        }
    }

    private fun fixedSize(width: Int, height: Int): AdSize = when {
        width == 320 && height == 50 -> AdSize.BANNER
        width == 320 && height == 100 -> AdSize.LARGE_BANNER
        width == 300 && height == 250 -> AdSize.MEDIUM_RECTANGLE
        width == 468 && height == 60 -> AdSize.FULL_BANNER
        width == 728 && height == 90 -> AdSize.LEADERBOARD
        else -> AdSize(width, height)
    }

    private fun fullWidthDp(context: Context): Int {
        val metrics = context.resources.displayMetrics
        return (metrics.widthPixels / metrics.density).toInt()
    }
}
