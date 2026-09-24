package io.admobflutterplus.admob_flutter_plus.banner

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.google.android.libraries.ads.mobile.sdk.banner.AdView
import com.google.android.libraries.ads.mobile.sdk.banner.BannerAd
import com.google.android.libraries.ads.mobile.sdk.banner.BannerAdEventCallback
import com.google.android.libraries.ads.mobile.sdk.banner.BannerAdPreloader
import com.google.android.libraries.ads.mobile.sdk.banner.BannerAdRefreshCallback
import com.google.android.libraries.ads.mobile.sdk.banner.BannerAdRequest
import com.google.android.libraries.ads.mobile.sdk.common.AdLoadCallback
import com.google.android.libraries.ads.mobile.sdk.common.LoadAdError
import io.admobflutterplus.admob_flutter_plus.core.applyRequest
import io.admobflutterplus.admob_flutter_plus.core.extrasBundle
import io.admobflutterplus.admob_flutter_plus.core.toFlutterMap
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

private const val TAG = "AdmobFlutterPlusBanner"

/**
 * PlatformView hosting a Next-Gen [AdView].
 *
 * When `creationParams["preload"]` is true, polls [BannerAdPreloader] and
 * attaches via [AdView.registerBannerAd]. An empty buffer or a failed
 * register does not call `loadAd`. Otherwise loads via
 * `AdView.loadAd(BannerAdRequest, AdLoadCallback)`. Supports in-place refresh
 * over a per-view method channel without recreating the PlatformView.
 *
 * Collapsible banners require a real [Activity] context; creating [AdView] with
 * only an application / detached context can return `isCollapsible == true`
 * while the expand overlay never appears.
 *
 * Dispose is guarded: load/refresh callbacks that arrive after [dispose] are
 * ignored so tab switches / widget rebuilds cannot crash the host Activity.
 */
class NextGenBannerAdView(
    private val context: Context,
    private val activityProvider: () -> Activity?,
    viewId: Int,
    creationParams: Map<*, *>?,
    messenger: BinaryMessenger,
    initialized: Boolean,
) : PlatformView, MethodChannel.MethodCallHandler {

    private val mainHandler = Handler(Looper.getMainLooper())
    private val container = FrameLayout(context).apply {
        // Collapsible overlays grow outside the collapsed banner bounds.
        clipChildren = false
        clipToPadding = false
    }
    private val channel = MethodChannel(messenger, "admob_flutter_plus/banner_ad_$viewId")

    private var adView: AdView? = null
    private var bannerAd: BannerAd? = null
    private var params: Map<*, *>? = creationParams
    private var disposed = false

    init {
        channel.setMethodCallHandler(this)
        if (!initialized) {
            Log.w(
                TAG,
                "MobileAds.initialize() was not called before mounting a banner. " +
                    "Call and await MobileAds.instance.initialize() at startup.",
            )
        }
        loadBanner(creationParams)
    }

    /** Prefer the foreground Activity; fall back to unwrapping [context]. */
    private fun resolveActivityContext(): Context {
        val activity = activityProvider()
        if (activity != null) return activity

        var current: Context? = context
        while (current is ContextWrapper) {
            if (current is Activity) return current
            current = current.baseContext
        }
        Log.w(
            TAG,
            "No Activity available for AdView. Collapsible expand overlays may not show. " +
                "Ensure the plugin is attached to an Activity before mounting banners.",
        )
        return context
    }

    override fun getView(): View = container

    override fun dispose() {
        disposed = true
        channel.setMethodCallHandler(null)
        tearDown()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (disposed) {
            result.success(null)
            return
        }
        when (call.method) {
            "refresh", "reload" -> {
                // "reload" kept as a temporary channel alias for older clients.
                @Suppress("UNCHECKED_CAST")
                val newParams = call.arguments as? Map<*, *> ?: params
                params = newParams
                loadBanner(newParams)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun tearDown() {
        bannerAd?.adEventCallback = null
        bannerAd?.bannerAdRefreshCallback = null
        bannerAd = null
        try {
            adView?.destroy()
        } catch (error: Exception) {
            Log.w(TAG, "AdView.destroy() threw during tearDown", error)
        }
        adView = null
        container.removeAllViews()
    }

    private fun invokeSafe(method: String, args: Any? = null) {
        if (disposed) return
        mainHandler.post {
            if (disposed) return@post
            try {
                channel.invokeMethod(method, args)
            } catch (error: Exception) {
                Log.w(TAG, "Failed to invoke $method after dispose race", error)
            }
        }
    }

    private fun wireCallbacks(ad: BannerAd) {
        bannerAd = ad
        invokeSafe("onAdLoaded", mapOf("adUnitId" to ad.adUnitId))
        invokeSafe("onIsCollapsible", mapOf("isCollapsible" to ad.isCollapsible()))
        ad.adEventCallback = object : BannerAdEventCallback {
            override fun onAdImpression() {
                invokeSafe("onAdImpression")
            }

            override fun onAdClicked() {
                invokeSafe("onAdClicked")
            }
        }
        ad.bannerAdRefreshCallback = object : BannerAdRefreshCallback {
            override fun onAdRefreshed() {
                invokeSafe("onAdRefreshed")
            }

            override fun onAdFailedToRefresh(adError: LoadAdError) {
                invokeSafe("onAdFailedToRefresh", adError.toFlutterMap())
            }
        }
    }

    private fun loadBanner(creationParams: Map<*, *>?) {
        if (disposed) return
        tearDown()
        val adUnitId = creationParams?.get("adUnitId") as? String ?: return
        @Suppress("UNCHECKED_CAST")
        val sizeMap = creationParams["size"] as? Map<String, Any?> ?: return
        @Suppress("UNCHECKED_CAST")
        val requestMap = creationParams["request"] as? Map<String, Any?>
        val usePreload = creationParams["preload"] as? Boolean == true

        val host = resolveActivityContext()
        val adSize = BannerAdSizeResolver.resolve(host, sizeMap)
        val view = AdView(host)
        adView = view
        container.addView(
            view,
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            ),
        )

        if (usePreload) {
            val activity = activityProvider() ?: (host as? Activity)
            val preloaded = BannerAdPreloader.pollAd(adUnitId)
            if (preloaded != null && activity != null) {
                try {
                    view.registerBannerAd(preloaded, activity)
                    if (disposed || adView !== view) {
                        preloaded.destroy()
                        return
                    }
                    wireCallbacks(preloaded)
                    return
                } catch (error: Exception) {
                    Log.w(TAG, "registerBannerAd failed", error)
                    try {
                        preloaded.destroy()
                    } catch (_: Exception) {
                    }
                }
            } else if (preloaded != null) {
                try {
                    preloaded.destroy()
                } catch (_: Exception) {
                }
            }
            Log.w(TAG, "Preloaded banner unavailable for $adUnitId")
            invokeSafe(
                "onAdFailedToLoad",
                mapOf(
                    "code" to 3,
                    "message" to "Preloaded banner unavailable",
                ),
            )
            return
        }

        val requestBuilder = BannerAdRequest.Builder(adUnitId, adSize)
            .apply { applyRequest(requestMap) }
        extrasBundle(requestMap)?.let { requestBuilder.setGoogleExtrasBundle(it) }

        view.loadAd(
            requestBuilder.build(),
            object : AdLoadCallback<BannerAd> {
                override fun onAdLoaded(ad: BannerAd) {
                    if (disposed || adView !== view) {
                        ad.destroy()
                        return
                    }
                    wireCallbacks(ad)
                }

                override fun onAdFailedToLoad(adError: LoadAdError) {
                    if (disposed || adView !== view) return
                    Log.w(TAG, "Banner failed to load: ${adError.code} ${adError.message}")
                    invokeSafe("onAdFailedToLoad", adError.toFlutterMap())
                }
            },
        )
    }
}
