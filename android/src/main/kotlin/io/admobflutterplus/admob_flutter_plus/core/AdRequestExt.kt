package io.admobflutterplus.admob_flutter_plus.core

import android.os.Bundle
import com.google.android.libraries.ads.mobile.sdk.common.BaseAdRequestBuilder

/**
 * Applies the shared targeting fields decoded from Dart onto any concrete
 * request builder.
 *
 * All Next-Gen request builders (`AdRequest.Builder`, `BannerAdRequest.Builder`,
 * `NativeAdRequest.Builder`, ...) extend [BaseAdRequestBuilder], so the common
 * targeting logic lives here in one place.
 *
 * NOTE FOR CONTRIBUTORS: builder method names occasionally change across SDK
 * versions. When bumping `ads-mobile-sdk`, re-verify these calls against the
 * release notes and the API reference.
 */
@Suppress("UNCHECKED_CAST")
fun BaseAdRequestBuilder<*>.applyRequest(map: Map<String, Any?>?) {
    if (map == null) return

    (map["keywords"] as? List<*>)?.forEach { keyword ->
        (keyword as? String)?.let { addKeyword(it) }
    }

    (map["contentUrl"] as? String)?.let { setContentUrl(it) }

    (map["neighboringContentUrls"] as? List<*>)?.let { urls ->
        setNeighboringContentUrls(urls.filterIsInstance<String>().toSet())
    }

    (map["requestAgent"] as? String)?.let { setRequestAgent(it) }

    (map["publisherProvidedId"] as? String)?.let { setPublisherProvidedId(it) }

    (map["customTargeting"] as? Map<*, *>)?.forEach { (key, value) ->
        val k = key as? String ?: return@forEach
        when (value) {
            is String -> putCustomTargeting(k, value)
            is List<*> -> putCustomTargeting(k, value.filterIsInstance<String>())
        }
    }
}

/** Builds the Google network extras [Bundle] from the Dart `extras` map. */
fun extrasBundle(map: Map<String, Any?>?): Bundle? {
    val extras = map?.get("extras") as? Map<*, *> ?: return null
    if (extras.isEmpty()) return null
    val bundle = Bundle()
    extras.forEach { (key, value) ->
        val k = key as? String ?: return@forEach
        bundle.putString(k, value?.toString())
    }
    return bundle
}
