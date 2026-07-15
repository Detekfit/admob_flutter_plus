import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdSize fixed sizes', () {
    test('banner is 320x50', () {
      const size = AdSize.banner();
      expect(size.type, AdSizeType.fixed);
      expect(size.width, 320);
      expect(size.height, 50);
      expect(size.suggestedHeightDp, 50);
      expect(size.isAdaptive, isFalse);
    });

    test('largeBanner is 320x100', () {
      const size = AdSize.largeBanner();
      expect(size.width, 320);
      expect(size.height, 100);
      expect(size.suggestedHeightDp, 100);
    });

    test('mediumRectangle is 300x250', () {
      const size = AdSize.mediumRectangle();
      expect(size.width, 300);
      expect(size.height, 250);
    });

    test('fullBanner is 468x60', () {
      const size = AdSize.fullBanner();
      expect(size.width, 468);
      expect(size.height, 60);
    });

    test('leaderboard is 728x90', () {
      const size = AdSize.leaderboard();
      expect(size.width, 728);
      expect(size.height, 90);
    });

    test('custom fixed size', () {
      const size = AdSize.fixed(width: 200, height: 80);
      expect(size.width, 200);
      expect(size.height, 80);
    });
  });

  group('AdSize adaptive sizes', () {
    test('anchored maps to anchored type and is adaptive', () {
      const size = AdSize.anchored();
      expect(size.type, AdSizeType.anchored);
      expect(size.isAdaptive, isTrue);
    });

    test('anchored full-width sentinel is -1', () {
      const size = AdSize.anchored();
      expect(size.width, -1);
    });

    test('anchored with explicit width', () {
      const size = AdSize.anchored(width: 360);
      expect(size.width, 360);
      expect(size.toMap()['width'], 360);
    });

    test('portrait and landscape anchored types', () {
      expect(const AdSize.anchoredPortrait().type, AdSizeType.anchoredPortrait);
      expect(
        const AdSize.anchoredLandscape().type,
        AdSizeType.anchoredLandscape,
      );
    });

    test('inline carries width and maxHeight', () {
      const size = AdSize.inline(width: 360, maxHeight: 200);
      final map = size.toMap();
      expect(map['type'], 'inline');
      expect(map['width'], 360);
      expect(map['maxHeight'], 200);
    });

    test('suggestedHeightDp throws for adaptive sizes', () {
      expect(() => const AdSize.anchored().suggestedHeightDp, throwsStateError);
      expect(
        () => const AdSize.inline(width: 320, maxHeight: 100).suggestedHeightDp,
        throwsStateError,
      );
    });
  });

  group('AdSize serialization and equality', () {
    test('toMap uses the type name', () {
      expect(const AdSize.anchored().toMap()['type'], 'anchored');
      expect(const AdSize.banner().toMap()['type'], 'fixed');
    });

    test('equal sizes are equal', () {
      expect(const AdSize.banner(), const AdSize.banner());
      expect(
        const AdSize.banner().hashCode,
        const AdSize.banner().hashCode,
      );
    });

    test('different sizes are not equal', () {
      expect(const AdSize.banner(), isNot(const AdSize.largeBanner()));
    });
  });
}
