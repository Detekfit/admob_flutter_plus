import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PictureInPictureAdOptions.toMap', () {
    test('defaults serialize to defaultPosition and screen', () {
      expect(const PictureInPictureAdOptions().toMap(), {
        'position': 'defaultPosition',
        'presentationScope': 'screen',
      });
    });

    test('includes explicit position and scope', () {
      const options = PictureInPictureAdOptions(
        position: PictureInPictureAdPosition.topLeft,
        presentationScope: PictureInPictureAdPresentationScope.application,
      );
      expect(options.toMap(), {
        'position': 'topLeft',
        'presentationScope': 'application',
      });
    });

    test('every position name is non-empty', () {
      for (final position in PictureInPictureAdPosition.values) {
        expect(position.name, isNotEmpty);
      }
    });

    test('every scope name is non-empty', () {
      for (final scope in PictureInPictureAdPresentationScope.values) {
        expect(scope.name, isNotEmpty);
      }
    });
  });
}
