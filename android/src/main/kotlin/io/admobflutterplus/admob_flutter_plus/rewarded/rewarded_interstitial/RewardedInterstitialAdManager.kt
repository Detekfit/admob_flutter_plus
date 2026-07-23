package io.admobflutterplus.admob_flutter_plus.rewarded.rewarded_interstitial

import android.app.Activity
import com.google.android.libraries.ads.mobile.sdk.common.AdLoadCallback
import com.google.android.libraries.ads.mobile.sdk.common.AdRequest
import com.google.android.libraries.ads.mobile.sdk.common.FullScreenContentError
import com.google.android.libraries.ads.mobile.sdk.common.LoadAdError
import com.google.android.libraries.ads.mobile.sdk.rewarded.OnUserEarnedRewardListener
import com.google.android.libraries.ads.mobile.sdk.rewardedinterstitial.RewardedInterstitialAd
import com.google.android.libraries.ads.mobile.sdk.rewardedinterstitial.RewardedInterstitialAdEventCallback
import io.admobflutterplus.admob_flutter_plus.core.EventDispatcher
import io.admobflutterplus.admob_flutter_plus.core.applyRequest
import io.admobflutterplus.admob_flutter_plus.core.toFlutterMap
import io.admobflutterplus.admob_flutter_plus.helper.AdCoordinator
import io.flutter.plugin.common.MethodChannel

/** Loads, shows, and disposes rewarded interstitial ads. */
class RewardedInterstitialAdManager(private val dispatcher: EventDispatcher) {

    private val ads = HashMap<String, RewardedInterstitialAd>()

    fun load(
        adId: String,
        adUnitId: String,
        request: Map<String, Any?>?,
        result: MethodChannel.Result,
    ) {
        val adRequest = AdRequest.Builder(adUnitId)
            .apply { applyRequest(request) }
            .build()

        RewardedInterstitialAd.load(
            adRequest,
            object : AdLoadCallback<RewardedInterstitialAd> {
                override fun onAdLoaded(ad: RewardedInterstitialAd) {
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

    fun show(adId: String, activity: Activity?) {
        val ad = ads[adId] ?: return
        if (activity == null) return
        if (!AdCoordinator.tryAcquire()) return

        ad.adEventCallback = object : RewardedInterstitialAdEventCallback {
            override fun onAdShowedFullScreenContent() {
                dispatcher.send("onAdShowedFullScreenContent", adId)
            }

            override fun onAdDismissedFullScreenContent() {
                AdCoordinator.release()
                ads.remove(adId)
                dispatcher.send("onAdDismissedFullScreenContent", adId)
            }

            override fun onAdFailedToShowFullScreenContent(
                fullScreenContentError: FullScreenContentError,
            ) {
                AdCoordinator.release()
                ads.remove(adId)
                dispatcher.send(
                    "onAdFailedToShowFullScreenContent",
                    adId,
                    fullScreenContentError.toFlutterMap(),
                )
            }

            override fun onAdImpression() {
                dispatcher.send("onAdImpression", adId)
            }

            override fun onAdClicked() {
                dispatcher.send("onAdClicked", adId)
            }
        }

        ad.show(activity, OnUserEarnedRewardListener { reward ->
            dispatcher.send(
                "onUserEarnedReward",
                adId,
                mapOf("amount" to reward.amount, "type" to reward.type),
            )
        })
    }

    fun dispose(adId: String) {
        ads.remove(adId)
    }

    fun adopt(adId: String, ad: RewardedInterstitialAd) {
        ads[adId] = ad
    }

    fun disposeAll() {
        ads.clear()
    }
}
