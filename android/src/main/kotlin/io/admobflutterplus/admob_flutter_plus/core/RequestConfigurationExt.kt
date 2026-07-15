package io.admobflutterplus.admob_flutter_plus.core

import com.google.android.libraries.ads.mobile.sdk.MobileAds
import com.google.android.libraries.ads.mobile.sdk.common.RequestConfiguration
import com.google.android.libraries.ads.mobile.sdk.common.RequestConfiguration.MaxAdContentRating
import com.google.android.libraries.ads.mobile.sdk.common.RequestConfiguration.TagForChildDirectedTreatment
import com.google.android.libraries.ads.mobile.sdk.common.RequestConfiguration.TagForUnderAgeOfConsent

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

    (map["tagForChildDirectedTreatment"] as? String)?.let { tag ->
        builder.setTagForChildDirectedTreatment(tag.toChildTag())
    }

    (map["tagForUnderAgeOfConsent"] as? String)?.let { tag ->
        builder.setTagForUnderAgeOfConsent(tag.toUnderAgeTag())
    }

    MobileAds.setRequestConfiguration(builder.build())
}

private fun String.toChildTag(): TagForChildDirectedTreatment = when (this) {
    "yes" -> TagForChildDirectedTreatment.TAG_FOR_CHILD_DIRECTED_TREATMENT_TRUE
    "no" -> TagForChildDirectedTreatment.TAG_FOR_CHILD_DIRECTED_TREATMENT_FALSE
    else -> TagForChildDirectedTreatment.TAG_FOR_CHILD_DIRECTED_TREATMENT_UNSPECIFIED
}

private fun String.toUnderAgeTag(): TagForUnderAgeOfConsent = when (this) {
    "yes" -> TagForUnderAgeOfConsent.TAG_FOR_UNDER_AGE_OF_CONSENT_TRUE
    "no" -> TagForUnderAgeOfConsent.TAG_FOR_UNDER_AGE_OF_CONSENT_FALSE
    else -> TagForUnderAgeOfConsent.TAG_FOR_UNDER_AGE_OF_CONSENT_UNSPECIFIED
}
