package io.admobflutterplus.admob_flutter_plus

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import com.google.android.libraries.ads.mobile.sdk.MobileAds
import com.google.android.libraries.ads.mobile.sdk.initialization.InitializationConfig
import io.admobflutterplus.admob_flutter_plus.app_open.AppOpenAdManager
import io.admobflutterplus.admob_flutter_plus.app_state.AppStateNotifier
import io.admobflutterplus.admob_flutter_plus.banner.BannerAdViewFactory
import io.admobflutterplus.admob_flutter_plus.consent.ConsentManager
import io.admobflutterplus.admob_flutter_plus.core.EventDispatcher
import io.admobflutterplus.admob_flutter_plus.core.applyRequestConfiguration
import io.admobflutterplus.admob_flutter_plus.helper.AdCoordinator
import io.admobflutterplus.admob_flutter_plus.interstitial.InterstitialAdManager
import io.admobflutterplus.admob_flutter_plus.native_ads.NativeAdManager
import io.admobflutterplus.admob_flutter_plus.native_ads.NativeAdViewFactory
import io.admobflutterplus.admob_flutter_plus.native_ads.NativeTemplate
import io.admobflutterplus.admob_flutter_plus.preload.PreloaderManager
import io.admobflutterplus.admob_flutter_plus.rewarded.RewardedAdManager
import io.admobflutterplus.admob_flutter_plus.rewarded.rewarded_interstitial.RewardedInterstitialAdManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** Main plugin: routes method calls and hosts per-format managers. */
class AdmobFlutterPlusPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context
    private lateinit var dispatcher: EventDispatcher

    private lateinit var interstitialManager: InterstitialAdManager
    private lateinit var rewardedManager: RewardedAdManager
    private lateinit var rewardedInterstitialManager: RewardedInterstitialAdManager
    private lateinit var appOpenManager: AppOpenAdManager
    private lateinit var nativeManager: NativeAdManager
    private lateinit var preloaderManager: PreloaderManager
    private lateinit var appStateNotifier: AppStateNotifier
    private lateinit var consentManager: ConsentManager

    private var activity: Activity? = null
    private var initialized = false

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "admob_flutter_plus")
        channel.setMethodCallHandler(this)
        dispatcher = EventDispatcher(channel)

        interstitialManager = InterstitialAdManager(dispatcher)
        rewardedManager = RewardedAdManager(dispatcher)
        rewardedInterstitialManager = RewardedInterstitialAdManager(dispatcher)
        appOpenManager = AppOpenAdManager(dispatcher)
        nativeManager = NativeAdManager(dispatcher)
        preloaderManager = PreloaderManager(
            interstitialManager,
            rewardedManager,
            rewardedInterstitialManager,
        )
        appStateNotifier = AppStateNotifier(binding.binaryMessenger)
        consentManager = ConsentManager(binding.binaryMessenger, applicationContext)

        val registry = binding.platformViewRegistry
        registry.registerViewFactory(
            "admob_flutter_plus/banner_ad",
            BannerAdViewFactory(
                messenger = binding.binaryMessenger,
                isInitialized = { initialized },
                activityProvider = { activity },
            ),
        )
        registry.registerViewFactory(
            "admob_flutter_plus/native_banner",
            NativeAdViewFactory(NativeTemplate.BANNER, nativeManager),
        )
        registry.registerViewFactory(
            "admob_flutter_plus/native_small",
            NativeAdViewFactory(NativeTemplate.SMALL, nativeManager),
        )
        registry.registerViewFactory(
            "admob_flutter_plus/native_large",
            NativeAdViewFactory(NativeTemplate.LARGE, nativeManager),
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        appStateNotifier.detach()
        consentManager.detach()
        interstitialManager.disposeAll()
        rewardedManager.disposeAll()
        rewardedInterstitialManager.disposeAll()
        appOpenManager.disposeAll()
        nativeManager.disposeAll()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<*, *>
        fun adId() = args?.get("adId") as? String ?: ""
        fun adUnitId() = args?.get("adUnitId") as? String ?: ""

        @Suppress("UNCHECKED_CAST")
        fun request() = args?.get("request") as? Map<String, Any?>

        when (call.method) {
            "initialize" -> initialize(result)
            "getVersion" -> result.success(MobileAds.getVersion().toString())
            "setRequestConfiguration" -> {
                @Suppress("UNCHECKED_CAST")
                applyRequestConfiguration((args ?: emptyMap<String, Any?>()) as Map<String, Any?>)
                result.success(null)
            }
            "openAdInspector" -> openAdInspector(result)

            // Interstitial
            "loadInterstitial" ->
                interstitialManager.load(adId(), adUnitId(), request(), result)
            "showInterstitial" -> {
                interstitialManager.show(adId(), activity)
                result.success(null)
            }
            "disposeInterstitial" -> {
                interstitialManager.dispose(adId())
                result.success(null)
            }

            // Rewarded
            "loadRewarded" ->
                rewardedManager.load(adId(), adUnitId(), request(), result)
            "showRewarded" -> {
                rewardedManager.show(adId(), activity)
                result.success(null)
            }
            "disposeRewarded" -> {
                rewardedManager.dispose(adId())
                result.success(null)
            }

            // Rewarded interstitial
            "loadRewardedInterstitial" ->
                rewardedInterstitialManager.load(adId(), adUnitId(), request(), result)
            "showRewardedInterstitial" -> {
                rewardedInterstitialManager.show(adId(), activity)
                result.success(null)
            }
            "disposeRewardedInterstitial" -> {
                rewardedInterstitialManager.dispose(adId())
                result.success(null)
            }

            // App open
            "loadAppOpen" ->
                appOpenManager.load(adId(), adUnitId(), request(), result)
            "showAppOpen" -> {
                appOpenManager.show(adId(), activity)
                result.success(null)
            }
            "disposeAppOpen" -> {
                appOpenManager.dispose(adId())
                result.success(null)
            }

            // Native
            "loadNative" -> {
                @Suppress("UNCHECKED_CAST")
                val options = args?.get("options") as? Map<String, Any?>
                nativeManager.load(adId(), adUnitId(), request(), options, result)
            }
            "disposeNative" -> {
                nativeManager.dispose(adId())
                result.success(null)
            }

            // Interstitial preload
            "startInterstitialPreload" -> {
                preloaderManager.startInterstitial(adUnitId(), bufferSize(args), request())
                result.success(null)
            }
            "pollInterstitialPreload" ->
                result.success(mapOf("polled" to preloaderManager.pollInterstitial(adUnitId(), adId())))
            "isInterstitialPreloadAvailable" ->
                result.success(preloaderManager.isInterstitialAvailable(adUnitId()))
            "interstitialPreloadCount" ->
                result.success(preloaderManager.interstitialCount(adUnitId()))
            "destroyInterstitialPreload" -> {
                preloaderManager.destroyInterstitial(adUnitId())
                result.success(null)
            }

            // Rewarded preload
            "startRewardedPreload" -> {
                preloaderManager.startRewarded(adUnitId(), bufferSize(args), request())
                result.success(null)
            }
            "pollRewardedPreload" ->
                result.success(mapOf("polled" to preloaderManager.pollRewarded(adUnitId(), adId())))
            "isRewardedPreloadAvailable" ->
                result.success(preloaderManager.isRewardedAvailable(adUnitId()))
            "rewardedPreloadCount" ->
                result.success(preloaderManager.rewardedCount(adUnitId()))
            "destroyRewardedPreload" -> {
                preloaderManager.destroyRewarded(adUnitId())
                result.success(null)
            }

            // Rewarded interstitial preload
            "startRewardedInterstitialPreload" -> {
                preloaderManager.startRewardedInterstitial(adUnitId(), bufferSize(args), request())
                result.success(null)
            }
            "pollRewardedInterstitialPreload" ->
                result.success(
                    mapOf("polled" to preloaderManager.pollRewardedInterstitial(adUnitId(), adId())),
                )
            "isRewardedInterstitialPreloadAvailable" ->
                result.success(preloaderManager.isRewardedInterstitialAvailable(adUnitId()))
            "rewardedInterstitialPreloadCount" ->
                result.success(preloaderManager.rewardedInterstitialCount(adUnitId()))
            "destroyRewardedInterstitialPreload" -> {
                preloaderManager.destroyRewardedInterstitial(adUnitId())
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    private fun bufferSize(args: Map<*, *>?): Int =
        (args?.get("bufferSize") as? Number)?.toInt() ?: 2

    private fun initialize(result: Result) {
        val config = InitializationConfig.Builder(readApplicationId()).build()
        MobileAds.initialize(applicationContext, config) {
            initialized = true
            dispatcher.runOnMain { result.success(null) }
        }
    }

    /** Reads the AdMob app id from the host app's manifest meta-data. */
    private fun readApplicationId(): String = try {
        val info = applicationContext.packageManager.getApplicationInfo(
            applicationContext.packageName,
            PackageManager.GET_META_DATA,
        )
        info.metaData?.getString("com.google.android.gms.ads.APPLICATION_ID") ?: ""
    } catch (_: Exception) {
        ""
    }

    private fun openAdInspector(result: Result) {
        // On SDK 1.0.x openAdInspector takes only a listener (no Context arg).
        MobileAds.openAdInspector { error ->
            dispatcher.runOnMain {
                if (error != null) {
                    result.error(error.code.toString(), error.message, null)
                } else {
                    result.success(null)
                }
            }
        }
    }

    // --- ActivityAware ---

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        consentManager.activity = binding.activity
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        consentManager.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
        consentManager.activity = null
    }

    override fun onDetachedFromActivity() {
        activity = null
        consentManager.activity = null
        AdCoordinator.release()
    }
}
