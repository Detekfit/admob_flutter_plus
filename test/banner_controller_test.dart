import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BannerAdController', () {
    test('defaults to detached', () {
      final controller = BannerAdController();
      expect(controller.isAttached, isFalse);
    });

    test('attach/detach toggles isAttached and refresh delegates', () async {
      final controller = BannerAdController();
      var refreshCount = 0;
      controller.attach(() async => refreshCount++);
      expect(controller.isAttached, isTrue);
      await controller.refresh();
      expect(refreshCount, 1);
      controller.detach();
      expect(controller.isAttached, isFalse);
      await controller.refresh(); // no-op after detach
      expect(refreshCount, 1);
    });

    test('deprecated reload() forwards to refresh()', () async {
      final controller = BannerAdController();
      var refreshCount = 0;
      controller.attach(() async => refreshCount++);
      // ignore: deprecated_member_use_from_same_package
      await controller.reload();
      expect(refreshCount, 1);
    });
  });
}
