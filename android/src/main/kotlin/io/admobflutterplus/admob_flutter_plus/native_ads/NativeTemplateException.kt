package io.admobflutterplus.admob_flutter_plus.native_ads

/**
 * Thrown when a custom native ad XML template cannot be loaded or fails
 * validation (missing asset, malformed XML, or missing required tags).
 */
class NativeTemplateException(message: String) : IllegalStateException(message)
