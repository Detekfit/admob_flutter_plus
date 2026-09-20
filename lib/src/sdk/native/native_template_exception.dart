/// Thrown when a custom native ad template cannot be loaded or is invalid.
///
/// Typical causes:
/// * the Flutter asset path is missing from `pubspec.yaml` / not found
/// * the XML is malformed
/// * required tags (`ad_view`, `ad_headline`, `ad_call_to_action`) are absent
class NativeTemplateException implements Exception {
  /// Creates a [NativeTemplateException] with a human-readable [message].
  const NativeTemplateException(this.message, {this.assetPath});

  /// Human-readable description of the failure.
  final String message;

  /// Optional Flutter asset path that failed to resolve.
  final String? assetPath;

  @override
  String toString() {
    final path = assetPath;
    if (path == null || path.isEmpty) {
      return 'NativeTemplateException: $message';
    }
    return 'NativeTemplateException: $message (asset: $path)';
  }
}
