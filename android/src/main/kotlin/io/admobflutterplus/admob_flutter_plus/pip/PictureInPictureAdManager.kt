@file:OptIn(com.google.android.libraries.ads.mobile.sdk.common.ExperimentalApi::class)

package io.admobflutterplus.admob_flutter_plus.pip

import android.app.Activity
import com.google.android.libraries.ads.mobile.sdk.common.AdLoadCallback
import com.google.android.libraries.ads.mobile.sdk.common.FullScreenContentError
import com.google.android.libraries.ads.mobile.sdk.common.LoadAdError
import com.google.android.libraries.ads.mobile.sdk.pip.PictureInPictureAd
import com.google.android.libraries.ads.mobile.sdk.pip.PictureInPictureAdEventCallback
import com.google.android.libraries.ads.mobile.sdk.pip.PictureInPictureAdOptions
import com.google.android.libraries.ads.mobile.sdk.pip.PictureInPictureAdPosition
import com.google.android.libraries.ads.mobile.sdk.pip.PictureInPictureAdPresentationScope
import com.google.android.libraries.ads.mobile.sdk.pip.PictureInPictureAdRequest
import io.admobflutterplus.admob_flutter_plus.core.EventDispatcher
import io.admobflutterplus.admob_flutter_plus.core.applyRequest
import io.admobflutterplus.admob_flutter_plus.core.toFlutterMap
import io.flutter.plugin.common.MethodChannel

/** Loads, shows, hides, and destroys picture-in-picture ads. */
class PictureInPictureAdManager(private val dispatcher: EventDispatcher) {

    private val ads = HashMap<String, PictureInPictureAd>()

    fun load(
        adId: String,
        adUnitId: String,
        request: Map<String, Any?>?,
        result: MethodChannel.Result,
    ) {
        val adRequest = PictureInPictureAdRequest.Builder(adUnitId)
            .apply { applyRequest(request) }
            .build()

        PictureInPictureAd.load(
            adRequest,
            object : AdLoadCallback<PictureInPictureAd> {
                override fun onAdLoaded(ad: PictureInPictureAd) {
                    ads[adId] = ad
                    dispatcher.runOnMain {
                        result.success(
                            mapOf("loaded" to true, "adUnitId" to ad.adUnitId),
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

    fun show(adId: String, activity: Activity?, options: Map<String, Any?>?) {
        val ad = ads[adId] ?: return
        if (activity == null) return

        ad.adEventCallback = object : PictureInPictureAdEventCallback {
            override fun onAdShown() {
                dispatcher.send("onAdShown", adId)
            }

            override fun onAdHidden() {
                dispatcher.send("onAdHidden", adId)
            }

            override fun onAdImpression() {
                dispatcher.send("onAdImpression", adId)
            }

            override fun onAdClicked() {
                dispatcher.send("onAdClicked", adId)
            }

            override fun onAdShowedFullScreenContent() {
                dispatcher.send("onAdShowedFullScreenContent", adId)
            }

            override fun onAdDismissedFullScreenContent() {
                dispatcher.send("onAdDismissedFullScreenContent", adId)
            }

            override fun onAdFailedToShowFullScreenContent(
                fullScreenContentError: FullScreenContentError,
            ) {
                dispatcher.send(
                    "onAdFailedToShowFullScreenContent",
                    adId,
                    fullScreenContentError.toFlutterMap(),
                )
            }
        }

        val pipOptions = PictureInPictureAdOptions.Builder()
            .setPosition(parsePosition(options?.get("position") as? String))
            .setPresentationScope(parseScope(options?.get("presentationScope") as? String))
            .build()
        ad.show(activity, pipOptions)
    }

    fun hide(adId: String) {
        ads[adId]?.hide()
    }

    fun dispose(adId: String) {
        ads.remove(adId)?.destroy()
    }

    fun disposeAll() {
        val snapshot = ads.values.toList()
        ads.clear()
        snapshot.forEach { it.destroy() }
    }

    private fun parsePosition(name: String?): PictureInPictureAdPosition = when (name) {
        "topLeft" -> PictureInPictureAdPosition.TOP_LEFT
        "topRight" -> PictureInPictureAdPosition.TOP_RIGHT
        "bottomLeft" -> PictureInPictureAdPosition.BOTTOM_LEFT
        "bottomRight" -> PictureInPictureAdPosition.BOTTOM_RIGHT
        else -> PictureInPictureAdPosition.DEFAULT
    }

    private fun parseScope(name: String?): PictureInPictureAdPresentationScope = when (name) {
        "application" -> PictureInPictureAdPresentationScope.APPLICATION
        else -> PictureInPictureAdPresentationScope.SCREEN
    }
}
