package io.admobflutterplus.admob_flutter_plus.native_ads

import com.google.android.libraries.ads.mobile.sdk.common.LoadAdError
import com.google.android.libraries.ads.mobile.sdk.common.VideoOptions
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAd
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdEventCallback
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdLoader
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdLoaderCallback
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdRequest
import io.admobflutterplus.admob_flutter_plus.core.EventDispatcher
import io.admobflutterplus.admob_flutter_plus.core.applyRequest
import io.admobflutterplus.admob_flutter_plus.core.toFlutterMap
import io.flutter.plugin.common.MethodChannel

/** Loads native ads and retains them for the template PlatformViews. */
class NativeAdManager(private val dispatcher: EventDispatcher) {

    private val ads = HashMap<String, NativeAd>()

    /** Returns the loaded [NativeAd] for [adId], or `null`. */
    fun getAd(adId: String): NativeAd? = ads[adId]

    fun load(
        adId: String,
        adUnitId: String,
        request: Map<String, Any?>?,
        options: Map<String, Any?>?,
        result: MethodChannel.Result,
    ) {
        val startVideoMuted = options?.get("startVideoMuted") as? Boolean ?: true
        val adRequest = NativeAdRequest.Builder(
            adUnitId,
            listOf(NativeAd.NativeAdType.NATIVE),
        )
            .setVideoOptions(VideoOptions.Builder().setStartMuted(startVideoMuted).build())
            .apply { applyRequest(request) }
            .build()

        NativeAdLoader.load(
            adRequest,
            object : NativeAdLoaderCallback {
                override fun onNativeAdLoaded(nativeAd: NativeAd) {
                    ads[adId] = nativeAd
                    nativeAd.adEventCallback = object : NativeAdEventCallback {
                        override fun onAdImpression() {
                            dispatcher.send("onAdImpression", adId)
                        }

                        override fun onAdClicked() {
                            dispatcher.send("onAdClicked", adId)
                        }
                    }
                    dispatcher.runOnMain {
                        result.success(
                            mapOf("loaded" to true, "adUnitId" to nativeAd.adUnitId),
                        )
                    }
                }

                override fun onAdFailedToLoad(adError: LoadAdError) {
                    dispatcher.runOnMain {
                        result.success(
                            mapOf("loaded" to false, "error" to adError.toFlutterMap()),
                        )
                    }
                }
            },
        )
    }

    fun dispose(adId: String) {
        ads.remove(adId)?.destroy()
    }

    fun disposeAll() {
        ads.values.forEach { it.destroy() }
        ads.clear()
    }
}
