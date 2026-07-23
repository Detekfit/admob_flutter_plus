import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdRequest.toMap', () {
    test('empty request serializes to empty map', () {
      expect(const AdRequest().toMap(), isEmpty);
    });

    test('includes all provided fields', () {
      const request = AdRequest(
        keywords: ['games', 'puzzle'],
        customTargeting: {'level': '5', 'genres': ['rpg', 'action']},
        contentUrl: 'https://example.com',
        neighboringContentUrls: {'https://a.com', 'https://b.com'},
        requestAgent: 'my_agent',
        categoryExclusions: ['gambling'],
        publisherProvidedId: 'ppid-123',
        placementId: 'placement-1',
        extras: {'collapsible': 'bottom'},
      );
      final map = request.toMap();
      expect(map['keywords'], ['games', 'puzzle']);
      expect(map['customTargeting'], {
        'level': '5',
        'genres': ['rpg', 'action'],
      });
      expect(map['contentUrl'], 'https://example.com');
      expect((map['neighboringContentUrls'] as List).length, 2);
      expect(map['requestAgent'], 'my_agent');
      expect(map['categoryExclusions'], ['gambling']);
      expect(map['publisherProvidedId'], 'ppid-123');
      expect(map['placementId'], 'placement-1');
      expect(map['extras'], {'collapsible': 'bottom'});
    });

    test('collapsible extras are preserved', () {
      const request = AdRequest(extras: {'collapsible': 'top'});
      expect(request.toMap()['extras'], {'collapsible': 'top'});
    });

    test('omitted fields are not present', () {
      const request = AdRequest(keywords: ['a']);
      final map = request.toMap();
      expect(map.containsKey('contentUrl'), isFalse);
      expect(map.containsKey('extras'), isFalse);
    });
  });

  group('RequestConfiguration.toMap', () {
    test('maps enum values by name', () {
      const config = RequestConfiguration(
        testDeviceIds: ['ABC123'],
        maxAdContentRating: MaxAdContentRating.pg,
        ageRestrictedTreatment: AgeRestrictedTreatment.teen,
      );
      final map = config.toMap();
      expect(map['testDeviceIds'], ['ABC123']);
      expect(map['maxAdContentRating'], 'pg');
      expect(map['ageRestrictedTreatment'], 'teen');
    });

    test('still serializes deprecated COPPA tags', () {
      const config = RequestConfiguration(
        // ignore: deprecated_member_use_from_same_package
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
        // ignore: deprecated_member_use_from_same_package
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
      );
      final map = config.toMap();
      expect(map['tagForChildDirectedTreatment'], 'no');
      expect(map['tagForUnderAgeOfConsent'], 'yes');
    });

    test('empty configuration serializes to empty map', () {
      expect(const RequestConfiguration().toMap(), isEmpty);
    });
  });

  group('AdError', () {
    test('fromMap parses code, message, domain', () {
      final error = AdError.fromMap({
        'code': 3,
        'message': 'No fill',
        'domain': 'com.google.android.gms.ads',
      });
      expect(error.code, 3);
      expect(error.message, 'No fill');
      expect(error.domain, 'com.google.android.gms.ads');
    });

    test('fromMap tolerates missing fields', () {
      final error = AdError.fromMap({});
      expect(error.code, -1);
      expect(error.message, 'Unknown error');
      expect(error.domain, isNull);
    });
  });

  group('RewardItem', () {
    test('fromMap parses amount and type', () {
      final reward = RewardItem.fromMap({'amount': 10, 'type': 'coins'});
      expect(reward.amount, 10);
      expect(reward.type, 'coins');
    });
  });
}
