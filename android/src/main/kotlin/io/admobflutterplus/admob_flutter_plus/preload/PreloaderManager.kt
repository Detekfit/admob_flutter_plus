package io.admobflutterplus.admob_flutter_plus.preload

import android.content.Context
import com.google.android.libraries.ads.mobile.sdk.banner.BannerAdPreloader
import com.google.android.libraries.ads.mobile.sdk.banner.BannerAdRequest
import com.google.android.libraries.ads.mobile.sdk.common.AdRequest
import com.google.android.libraries.ads.mobile.sdk.common.PreloadConfiguration
import com.google.android.libraries.ads.mobile.sdk.interstitial.InterstitialAdPreloader
import com.google.android.libraries.ads.mobile.sdk.rewarded.RewardedAdPreloader
import com.google.android.libraries.ads.mobile.sdk.rewardedinterstitial.RewardedInterstitialAdPreloader
import io.admobflutterplus.admob_flutter_plus.banner.BannerAdSizeResolver
import io.admobflutterplus.admob_flutter_plus.core.applyRequest
import io.admobflutterplus.admob_flutter_plus.core.extrasBundle
import io.admobflutterplus.admob_flutter_plus.interstitial.InterstitialAdManager
import io.admobflutterplus.admob_flutter_plus.rewarded.RewardedAdManager
import io.admobflutterplus.admob_flutter_plus.rewarded.rewarded_interstitial.RewardedInterstitialAdManager

/**
 * Bridges the SDK preloaders for interstitial, rewarded, rewarded interstitial,
 * and banner. App open ads are not preloaded through a preloader class; load
 * them ahead of time instead.
 *
 * Polled full-screen ads are adopted into the corresponding manager so the
 * standard show/dispose lifecycle applies. Banner ads are polled by the
 * PlatformView via [BannerAdPreloader.pollAd] directly.
 */
class PreloaderManager(
    private val contextProvider: () -> Context,
    private val interstitialManager: InterstitialAdManager,
    private val rewardedManager: RewardedAdManager,
    private val rewardedInterstitialManager: RewardedInterstitialAdManager,
) {

    private fun config(adUnitId: String, bufferSize: Int, request: Map<String, Any?>?):
        PreloadConfiguration {
        val adRequest = AdRequest.Builder(adUnitId)
            .apply { applyRequest(request) }
            .build()
        return PreloadConfiguration(adRequest, bufferSize)
    }

    // --- Interstitial ---

    fun startInterstitial(adUnitId: String, bufferSize: Int, request: Map<String, Any?>?) {
        InterstitialAdPreloader.start(adUnitId, config(adUnitId, bufferSize, request))
    }

    fun pollInterstitial(adUnitId: String, adId: String): Map<String, Any?> {
        val ad = InterstitialAdPreloader.pollAd(adUnitId)
            ?: return mapOf("polled" to false)
        interstitialManager.adopt(adId, ad)
        return mapOf("polled" to true, "adUnitId" to ad.adUnitId)
    }

    fun isInterstitialAvailable(adUnitId: String): Boolean =
        InterstitialAdPreloader.isAdAvailable(adUnitId)

    fun interstitialCount(adUnitId: String): Int =
        InterstitialAdPreloader.getNumAdsAvailable(adUnitId)

    fun destroyInterstitial(adUnitId: String) {
        InterstitialAdPreloader.destroy(adUnitId)
    }

    // --- Rewarded ---

    fun startRewarded(adUnitId: String, bufferSize: Int, request: Map<String, Any?>?) {
        RewardedAdPreloader.start(adUnitId, config(adUnitId, bufferSize, request))
    }

    fun pollRewarded(adUnitId: String, adId: String): Map<String, Any?> {
        val ad = RewardedAdPreloader.pollAd(adUnitId)
            ?: return mapOf("polled" to false)
        rewardedManager.adopt(adId, ad)
        return mapOf("polled" to true, "adUnitId" to ad.adUnitId)
    }

    fun isRewardedAvailable(adUnitId: String): Boolean =
        RewardedAdPreloader.isAdAvailable(adUnitId)

    fun rewardedCount(adUnitId: String): Int =
        RewardedAdPreloader.getNumAdsAvailable(adUnitId)

    fun destroyRewarded(adUnitId: String) {
        RewardedAdPreloader.destroy(adUnitId)
    }

    // --- Rewarded interstitial ---

    fun startRewardedInterstitial(
        adUnitId: String,
        bufferSize: Int,
        request: Map<String, Any?>?,
    ) {
        RewardedInterstitialAdPreloader.start(adUnitId, config(adUnitId, bufferSize, request))
    }

    fun pollRewardedInterstitial(adUnitId: String, adId: String): Map<String, Any?> {
        val ad = RewardedInterstitialAdPreloader.pollAd(adUnitId)
            ?: return mapOf("polled" to false)
        rewardedInterstitialManager.adopt(adId, ad)
        return mapOf("polled" to true, "adUnitId" to ad.adUnitId)
    }

    fun isRewardedInterstitialAvailable(adUnitId: String): Boolean =
        RewardedInterstitialAdPreloader.isAdAvailable(adUnitId)

    fun rewardedInterstitialCount(adUnitId: String): Int =
        RewardedInterstitialAdPreloader.getNumAdsAvailable(adUnitId)

    fun destroyRewardedInterstitial(adUnitId: String) {
        RewardedInterstitialAdPreloader.destroy(adUnitId)
    }

    // --- Banner ---

    fun startBanner(
        adUnitId: String,
        bufferSize: Int,
        size: Map<String, Any?>?,
        request: Map<String, Any?>?,
    ) {
        if (size == null) return
        val context = contextProvider()
        val adSize = BannerAdSizeResolver.resolve(context, size)
        val requestBuilder = BannerAdRequest.Builder(adUnitId, adSize)
            .apply { applyRequest(request) }
        extrasBundle(request)?.let { requestBuilder.setGoogleExtrasBundle(it) }
        BannerAdPreloader.start(
            adUnitId,
            PreloadConfiguration(requestBuilder.build(), bufferSize),
        )
    }

    fun isBannerAvailable(adUnitId: String): Boolean =
        BannerAdPreloader.isAdAvailable(adUnitId)

    fun bannerCount(adUnitId: String): Int =
        BannerAdPreloader.getNumAdsAvailable(adUnitId)

    fun destroyBanner(adUnitId: String) {
        BannerAdPreloader.destroy(adUnitId)
    }
}
