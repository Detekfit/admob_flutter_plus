import 'package:flutter/foundation.dart' show immutable;

/// Initialization lifecycle of a mediation adapter (GMA Next-Gen).
///
/// Mirrors Android `AdapterStatus.InitializationState`. Prefer comparing
/// against these values (or [isComplete]) instead of legacy
/// `READY` / `NOT_READY` names from the older Mobile Ads SDK.
enum AdapterInitializationState {
  /// Adapter finished initializing successfully.
  complete,

  /// Adapter initialization failed.
  failed,

  /// Adapter is currently initializing.
  initializing,

  /// Adapter has not started initializing.
  notStarted,

  /// Adapter initialization timed out.
  timedOut,

  /// Unrecognized native state string.
  unknown,
}

/// Status of a single mediation adapter after [MobileAds.initialize].
@immutable
class AdapterStatus {
  /// Creates an [AdapterStatus].
  const AdapterStatus({
    required this.state,
    required this.description,
    required this.latency,
  });

  /// Builds from the map payload sent by the native side.
  factory AdapterStatus.fromMap(Map<dynamic, dynamic> map) {
    return AdapterStatus(
      state: parseAdapterInitializationState(map['state'] as String?),
      description: map['description'] as String? ?? '',
      latency: (map['latency'] as num?)?.toInt() ?? 0,
    );
  }

  /// Adapter initialization state from the native SDK.
  final AdapterInitializationState state;

  /// Human-readable description of the adapter status.
  final String description;

  /// Time spent initializing the adapter, in milliseconds.
  final int latency;

  /// Whether the adapter finished initializing successfully ([complete]).
  bool get isComplete => state == AdapterInitializationState.complete;

  @override
  String toString() =>
      'AdapterStatus(state: $state, description: $description, latency: $latency)';
}

/// Parses a native `InitializationState.name` (for example `COMPLETE`).
AdapterInitializationState parseAdapterInitializationState(String? raw) {
  switch (raw) {
    case 'COMPLETE':
      return AdapterInitializationState.complete;
    case 'FAILED':
      return AdapterInitializationState.failed;
    case 'INITIALIZING':
      return AdapterInitializationState.initializing;
    case 'NOT_STARTED':
      return AdapterInitializationState.notStarted;
    case 'TIMED_OUT':
      return AdapterInitializationState.timedOut;
    default:
      return AdapterInitializationState.unknown;
  }
}

/// Aggregate result of [MobileAds.initialize], including mediation adapters.
@immutable
class InitializationStatus {
  /// Creates an [InitializationStatus].
  const InitializationStatus({required this.adapterStatuses});

  /// Builds from the map payload sent by the native side.
  factory InitializationStatus.fromMap(Map<dynamic, dynamic> map) {
    final raw = map['adapterStatuses'];
    final statuses = <String, AdapterStatus>{};
    if (raw is Map) {
      for (final entry in raw.entries) {
        final key = entry.key;
        final value = entry.value;
        if (key is String && value is Map) {
          statuses[key] = AdapterStatus.fromMap(value);
        }
      }
    }
    return InitializationStatus(adapterStatuses: statuses);
  }

  /// Map of adapter class name → [AdapterStatus].
  final Map<String, AdapterStatus> adapterStatuses;

  @override
  String toString() => 'InitializationStatus(adapterStatuses: $adapterStatuses)';
}
