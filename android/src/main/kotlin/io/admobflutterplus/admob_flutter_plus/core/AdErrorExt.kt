package io.admobflutterplus.admob_flutter_plus.core

import com.google.android.libraries.ads.mobile.sdk.common.FullScreenContentError
import com.google.android.libraries.ads.mobile.sdk.common.LoadAdError

/** Maps a [LoadAdError] (load-time failure) to a Flutter-friendly map. */
fun LoadAdError.toFlutterMap(): Map<String, Any?> = mapOf(
    "code" to code.value,
    "codeName" to code.name,
    "message" to message,
)

/** Maps a [FullScreenContentError] (show-time failure) to a Flutter map. */
fun FullScreenContentError.toFlutterMap(): Map<String, Any?> = mapOf(
    "code" to code.value,
    "codeName" to code.name,
    "message" to message,
)
