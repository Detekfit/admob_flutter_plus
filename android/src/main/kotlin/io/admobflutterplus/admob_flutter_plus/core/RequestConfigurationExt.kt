package io.admobflutterplus.admob_flutter_plus.core

import com.google.android.libraries.ads.mobile.sdk.MobileAds
import com.google.android.libraries.ads.mobile.sdk.common.AgeRestrictedTreatment
import com.google.android.libraries.ads.mobile.sdk.common.RequestConfiguration
import com.google.android.libraries.ads.mobile.sdk.common.RequestConfiguration.MaxAdContentRating

/** Builds and applies a global [RequestConfiguration] from the Dart map. */
fun applyRequestConfiguration(map: Map<String, Any?>) {
    val builder = RequestConfiguration.Builder()

    (map["testDeviceIds"] as? List<*>)?.let { ids ->
        builder.setTestDeviceIds(ids.filterIsInstance<String>())
    }

    (map["maxAdContentRating"] as? String)?.let { rating ->
        val value = when (rating) {
            "g" -> MaxAdContentRating.MAX_AD_CONTENT_RATING_G
            "pg" -> MaxAdContentRating.MAX_AD_CONTENT_RATING_PG
            "t" -> MaxAdContentRating.MAX_AD_CONTENT_RATING_T
            "ma" -> MaxAdContentRating.MAX_AD_CONTENT_RATING_MA
            else -> MaxAdContentRating.MAX_AD_CONTENT_RATING_UNSPECIFIED
        }
        builder.setMaxAdContentRating(value)
    }

    resolveAgeRestrictedTreatment(map)?.let { treatment ->
        builder.setAgeRestrictedTreatment(treatment)
    }

    MobileAds.setRequestConfiguration(builder.build())
}

/**
 * Prefers the Next-Gen `ageRestrictedTreatment` field. Falls back to the
 * deprecated COPPA / TFUA tags for older Dart callers.
 */
private fun resolveAgeRestrictedTreatment(map: Map<String, Any?>): AgeRestrictedTreatment? {
    (map["ageRestrictedTreatment"] as? String)?.let { value ->
        return when (value) {
            "child" -> AgeRestrictedTreatment.CHILD
            "teen" -> AgeRestrictedTreatment.TEEN
            "unspecified" -> AgeRestrictedTreatment.UNSPECIFIED
            else -> null
        }
    }

    val child = map["tagForChildDirectedTreatment"] as? String
    val underAge = map["tagForUnderAgeOfConsent"] as? String
    return when {
        child == "yes" -> AgeRestrictedTreatment.CHILD
        underAge == "yes" -> AgeRestrictedTreatment.TEEN
        child != null || underAge != null -> AgeRestrictedTreatment.UNSPECIFIED
        else -> null
    }
}
