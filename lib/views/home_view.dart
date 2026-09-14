import 'package:flutter/material.dart';
import '../models/device_info_model.dart';
import '../services/device_service.dart';
import 'widgets/counter_card.dart';
import 'widgets/device_card.dart';
import 'widgets/mobai_status_card.dart';

class HomeView extends StatefulWidget {
  static final ValueNotifier<ThemeMode> defaultThemeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  final ValueNotifier<ThemeMode>? themeNotifier;
  final DeviceService? deviceService;

  const HomeView({
    super.key,
    this.themeNotifier,
    this.deviceService,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final DeviceService _deviceService;
  AppDeviceInfo? _deviceInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _deviceService = widget.deviceService ?? DeviceService();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    setState(() {
      _isLoading = true;
    });

    final info = await _deviceService.getDeviceInfo();
    if (mounted) {
      setState(() {
        _deviceInfo = info;
        _isLoading = false;
      });
    }
  }

  void _cycleTheme(ValueNotifier<ThemeMode> notifier) {
    switch (notifier.value) {
      case ThemeMode.system:
        notifier.value = ThemeMode.light;
        break;
      case ThemeMode.light:
        notifier.value = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        notifier.value = ThemeMode.system;
        break;
    }
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = widget.themeNotifier ?? HomeView.defaultThemeNotifier;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'iOS Builder Demo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            key: const Key('refresh_button'),
            tooltip: 'Refresh Diagnostics',
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeviceInfo,
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: notifier,
            builder: (context, mode, _) {
              return IconButton(
                key: const Key('theme_toggle_button'),
                tooltip: 'Theme: ${mode.name}',
                icon: Icon(_getThemeIcon(mode)),
                onPressed: () => _cycleTheme(notifier),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        key: const Key('refresh_indicator'),
        onRefresh: _loadDeviceInfo,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            DeviceCard(
              deviceInfo: _deviceInfo,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            const CounterCard(),
            const SizedBox(height: 16),
            const MobAIStatusCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
