import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/device_info_model.dart';

class DeviceService {
  final DeviceInfoPlugin _plugin;

  DeviceService({DeviceInfoPlugin? plugin})
      : _plugin = plugin ?? DeviceInfoPlugin();

  Future<AppDeviceInfo> getDeviceInfo() async {
    try {
      if (kIsWeb) {
        final web = await _plugin.webBrowserInfo;
        return AppDeviceInfo(
          platform: 'Web',
          model: web.browserName.name,
          systemVersion: web.userAgent ?? 'Web Browser',
          isPhysicalDevice: true,
        );
      } else if (Platform.isIOS) {
        final ios = await _plugin.iosInfo;
        return AppDeviceInfo(
          platform: 'iOS',
          model: ios.utsname.machine,
          systemVersion: '${ios.systemName} ${ios.systemVersion}',
          isPhysicalDevice: ios.isPhysicalDevice,
        );
      } else if (Platform.isAndroid) {
        final android = await _plugin.androidInfo;
        return AppDeviceInfo(
          platform: 'Android',
          model: '${android.brand} ${android.model}',
          systemVersion: 'Android ${android.version.release}',
          isPhysicalDevice: android.isPhysicalDevice,
        );
      } else {
        return AppDeviceInfo(
          platform: Platform.operatingSystem,
          model: Platform.localHostname,
          systemVersion: Platform.operatingSystemVersion,
          isPhysicalDevice: true,
        );
      }
    } catch (_) {
      return const AppDeviceInfo(
        platform: 'Unknown',
        model: 'Generic Device',
        systemVersion: 'N/A',
        isPhysicalDevice: true,
      );
    }
  }
}
