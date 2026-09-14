import 'package:flutter_test/flutter_test.dart';
import 'package:testflutter/models/device_info_model.dart';
import 'package:testflutter/services/device_service.dart';

void main() {
  group('DeviceService & AppDeviceInfo Tests', () {
    test('AppDeviceInfo model initializes all fields correctly', () {
      const info = AppDeviceInfo(
        platform: 'iOS',
        model: 'iPhone 15 Pro',
        systemVersion: 'iOS 18.0',
        isPhysicalDevice: true,
      );

      expect(info.platform, 'iOS');
      expect(info.model, 'iPhone 15 Pro');
      expect(info.systemVersion, 'iOS 18.0');
      expect(info.isPhysicalDevice, isTrue);
    });

    test('DeviceService returns non-null fallback or device info', () async {
      final service = DeviceService();
      final info = await service.getDeviceInfo();
      expect(info.platform, isNotEmpty);
      expect(info.model, isNotEmpty);
      expect(info.systemVersion, isNotEmpty);
    });
  });
}
