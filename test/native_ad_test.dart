import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NativeAdOptions.toMap', () {
    test('defaults', () {
      final map = const NativeAdOptions().toMap();
      expect(map['startVideoMuted'], isTrue);
      expect(map['requestCustomMuteThisAd'], isFalse);
      expect(map['requestMultipleImages'], isFalse);
    });

    test('custom values', () {
      final map = const NativeAdOptions(
        startVideoMuted: false,
        requestMultipleImages: true,
      ).toMap();
      expect(map['startVideoMuted'], isFalse);
      expect(map['requestMultipleImages'], isTrue);
    });
  });

  group('NativeAdViewStyle.toMap', () {
    test('serializes colors to ARGB ints and preserves badge text', () {
      const style = NativeAdViewStyle(
        cardColor: Color(0xFF112233),
        titleColor: Color(0xFFAABBCC),
        ctaCornerRadius: 12,
        adBadgeText: 'Sponsored',
      );
      final map = style.toMap();
      expect(map['cardColor'], 0xFF112233);
      expect(map['titleColor'], 0xFFAABBCC);
      expect(map['ctaCornerRadius'], 12);
      expect(map['adBadgeText'], 'Sponsored');
    });

    test('omits unset color fields', () {
      final map = const NativeAdViewStyle().toMap();
      expect(map.containsKey('cardColor'), isFalse);
      expect(map['adBadgeText'], 'Ad');
    });
  });
}
