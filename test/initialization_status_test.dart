import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdapterStatus.fromMap', () {
    test('parses Next-Gen COMPLETE state', () {
      final status = AdapterStatus.fromMap({
        'state': 'COMPLETE',
        'description': 'ok',
        'latency': 12,
      });
      expect(status.state, AdapterInitializationState.complete);
      expect(status.isComplete, isTrue);
      expect(status.description, 'ok');
      expect(status.latency, 12);
    });

    test('parses all known InitializationState names', () {
      expect(
        parseAdapterInitializationState('FAILED'),
        AdapterInitializationState.failed,
      );
      expect(
        parseAdapterInitializationState('INITIALIZING'),
        AdapterInitializationState.initializing,
      );
      expect(
        parseAdapterInitializationState('NOT_STARTED'),
        AdapterInitializationState.notStarted,
      );
      expect(
        parseAdapterInitializationState('TIMED_OUT'),
        AdapterInitializationState.timedOut,
      );
    });

    test('tolerates missing and unknown fields', () {
      final status = AdapterStatus.fromMap({});
      expect(status.state, AdapterInitializationState.unknown);
      expect(status.isComplete, isFalse);
      expect(status.description, '');
      expect(status.latency, 0);

      expect(
        parseAdapterInitializationState('READY'),
        AdapterInitializationState.unknown,
      );
    });
  });

  group('InitializationStatus.fromMap', () {
    test('parses adapterStatuses map', () {
      final status = InitializationStatus.fromMap({
        'adapterStatuses': {
          'com.google.android.gms.ads.MobileAds': {
            'state': 'COMPLETE',
            'description': 'done',
            'latency': 5,
          },
          'com.google.ads.mediation.facebook.FacebookMediationAdapter': {
            'state': 'FAILED',
            'description': 'missing',
            'latency': 0,
          },
        },
      });
      expect(status.adapterStatuses.length, 2);
      expect(
        status.adapterStatuses['com.google.android.gms.ads.MobileAds']?.state,
        AdapterInitializationState.complete,
      );
      expect(
        status.adapterStatuses['com.google.android.gms.ads.MobileAds']?.isComplete,
        isTrue,
      );
      expect(
        status
            .adapterStatuses[
                'com.google.ads.mediation.facebook.FacebookMediationAdapter']
            ?.description,
        'missing',
      );
      expect(
        status
            .adapterStatuses[
                'com.google.ads.mediation.facebook.FacebookMediationAdapter']
            ?.isComplete,
        isFalse,
      );
    });

    test('empty when adapterStatuses absent', () {
      final status = InitializationStatus.fromMap({});
      expect(status.adapterStatuses, isEmpty);
    });
  });
}
