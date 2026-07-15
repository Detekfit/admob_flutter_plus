package io.admobflutterplus.admob_flutter_plus.native_ads

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/** Factory producing native template PlatformViews for one [template]. */
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
