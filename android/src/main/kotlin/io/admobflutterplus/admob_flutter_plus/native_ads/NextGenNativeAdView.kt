package io.admobflutterplus.admob_flutter_plus.native_ads

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import com.google.android.libraries.ads.mobile.sdk.nativead.MediaView
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAd
import com.google.android.libraries.ads.mobile.sdk.nativead.NativeAdView
import io.admobflutterplus.admob_flutter_plus.R
import io.flutter.plugin.platform.PlatformView

/** Native template variants (built-in plugin layouts). */
enum class NativeTemplate(val layoutRes: Int) {
    BANNER(R.layout.native_banner_ad),
    SMALL(R.layout.native_small_ad),
    LARGE(R.layout.native_large_ad),
}

/**
 * PlatformView that binds a loaded [NativeAd] to a template layout.
 *
 * Supports built-in [NativeTemplate] layouts and custom Flutter-asset XML
 * templates (see [NativeTemplateAssetInflater]).
 *
 * Native Validator compliance:
 * - Templates without a media view register with `null` media.
 * - Templates with media defer `registerNativeAd` until the [MediaView] has a
 *   measured, non-zero size.
 * - Registration is guarded so it never runs after the view is disposed.
 */
class NextGenNativeAdView private constructor(
    context: Context,
    private val nativeAd: NativeAd?,
    private val style: Map<String, Any?>?,
    rootView: View,
) : PlatformView {

    private var disposed = false
    private val root: View = rootView

    constructor(
        context: Context,
        template: NativeTemplate,
        nativeAd: NativeAd?,
        style: Map<String, Any?>?,
    ) : this(
        context = context,
        nativeAd = nativeAd,
        style = style,
        rootView = LayoutInflater.from(context).inflate(template.layoutRes, null, false),
    )

    constructor(
        context: Context,
        templateAsset: String,
        templatePackage: String?,
        nativeAd: NativeAd?,
        style: Map<String, Any?>?,
        templateXml: String? = null,
    ) : this(
        context = context,
        nativeAd = nativeAd,
        style = style,
        rootView = NativeTemplateAssetInflater.inflate(
            context,
            templateAsset,
            templatePackage,
            templateXml,
        ),
    )

    init {
        bind()
    }

    override fun getView(): View = root

    override fun dispose() {
        disposed = true
    }

    private fun bind() {
        val ad = nativeAd ?: return
        NativeAdViewBinder.bind(
            root = root,
            ad = ad,
            style = style,
            disposed = { disposed },
            registerWithMedia = ::registerWithMedia,
        )
    }

    private fun registerWithMedia(adView: NativeAdView, mediaView: MediaView) {
        if (disposed) return
        val ad = nativeAd ?: return
        adView.registerNativeAd(ad, mediaView)
    }
}
