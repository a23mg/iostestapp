class AppDeviceInfo {
  final String platform;
  final String model;
  final String systemVersion;
  final bool isPhysicalDevice;

  const AppDeviceInfo({
    required this.platform,
    required this.model,
    required this.systemVersion,
    required this.isPhysicalDevice,
  });
}
