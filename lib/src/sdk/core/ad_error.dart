/// Describes a failure reported by the underlying Google Mobile Ads SDK.
///
/// The [code] values mirror the GMA `AdError`/`LoadAdError` error codes:
///
/// * `0` — internal error
/// * `1` — invalid request
/// * `2` — network error
/// * `3` — no fill
class AdError {
  /// Creates an [AdError] with a native [code] and human readable [message].
  const AdError({
    required this.code,
    required this.message,
    this.domain,
  });

  /// Builds an [AdError] from the map payload sent by the native side.
  factory AdError.fromMap(Map<dynamic, dynamic> map) {
    return AdError(
      code: (map['code'] as num?)?.toInt() ?? -1,
      message: map['message'] as String? ?? 'Unknown error',
      domain: map['domain'] as String?,
    );
  }

  /// GMA error code.
  final int code;

  /// Human readable description of the error.
  final String message;

  /// Optional error domain reported by the SDK.
  final String? domain;

  @override
  String toString() =>
      'AdError(code: $code, message: $message${domain != null ? ', domain: $domain' : ''})';
}

/// Thrown when an ad fails to load.
///
/// Load APIs in this package are Future-first: a failed load completes the
/// returned [Future] with this exception rather than invoking a listener.
class AdLoadException implements Exception {
  /// Creates an [AdLoadException] wrapping [error].
  const AdLoadException(this.error);

  /// The underlying [AdError].
  final AdError error;

  @override
  String toString() => 'AdLoadException: $error';
}

/// Thrown when opening the Ad Inspector fails.
class AdInspectorException implements Exception {
  /// Creates an [AdInspectorException] wrapping [error].
  const AdInspectorException(this.error);

  /// The underlying [AdError].
  final AdError error;

  @override
  String toString() => 'AdInspectorException: $error';
}
