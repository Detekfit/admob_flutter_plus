package io.admobflutterplus.admob_flutter_plus.native_ads

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/** Factory producing native template PlatformViews for one built-in [template]. */
class NativeAdViewFactory(
    private val template: NativeTemplate,
    private val manager: NativeAdManager,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<*, *>
        val adId = params?.get("adId") as? String
        @Suppress("UNCHECKED_CAST")
        val style = params?.get("style") as? Map<String, Any?>
        return NextGenNativeAdView(
            context = context,
            template = template,
            nativeAd = adId?.let { manager.getAd(it) },
            style = style,
        )
    }
}

/** Factory for custom Flutter-asset XML native templates. */
class NativeCustomAdViewFactory(
    private val manager: NativeAdManager,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<*, *>
            ?: throw NativeTemplateException("Missing creation params for custom native template.")
        val templateAsset = params["templateAsset"] as? String
            ?: throw NativeTemplateException("templateAsset is required for custom native templates.")
        val templatePackage = params["templatePackage"] as? String
        val adId = params["adId"] as? String
        @Suppress("UNCHECKED_CAST")
        val style = params["style"] as? Map<String, Any?>
        return NextGenNativeAdView(
            context = context,
            templateAsset = templateAsset,
            templatePackage = templatePackage,
            nativeAd = adId?.let { manager.getAd(it) },
            style = style,
        )
    }
}
