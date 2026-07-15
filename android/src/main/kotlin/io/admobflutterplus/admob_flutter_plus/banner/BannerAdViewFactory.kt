package io.admobflutterplus.admob_flutter_plus.banner

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/** Factory for [NextGenBannerAdView] PlatformViews. */
class BannerAdViewFactory(
    private val messenger: BinaryMessenger,
    private val isInitialized: () -> Boolean,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<*, *>
        return NextGenBannerAdView(
            context = context,
            viewId = viewId,
            creationParams = params,
            messenger = messenger,
            initialized = isInitialized(),
        )
    }
}
