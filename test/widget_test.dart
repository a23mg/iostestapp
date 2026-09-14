import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testflutter/main.dart';
import 'package:testflutter/models/device_info_model.dart';
import 'package:testflutter/views/widgets/counter_card.dart';
import 'package:testflutter/views/widgets/device_card.dart';
import 'package:testflutter/views/widgets/mobai_status_card.dart';

void main() {
  group('HomeView & Showcase Widget Tests', () {
    testWidgets('HomeView loads and displays title and cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('iOS Builder Demo'), findsOneWidget);
      expect(find.byType(DeviceCard), findsOneWidget);
      expect(find.byType(CounterCard), findsOneWidget);
      expect(find.byType(MobAIStatusCard), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('Counter buttons increment, decrement, and reset',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);

      // Increment
      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsNothing);

      // Increment again
      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);

      // Decrement
      await tester.tap(find.byKey(const Key('decrement_button')));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      // Reset
      await tester.tap(find.byKey(const Key('reset_button')));
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('Theme toggle cycles through system, light, and dark modes',
        (WidgetTester tester) async {
      final notifier = ValueNotifier<ThemeMode>(ThemeMode.system);
      await tester.pumpWidget(MyApp(themeNotifier: notifier));
      await tester.pumpAndSettle();

      expect(notifier.value, ThemeMode.system);

      // Tap to toggle to Light
      await tester.tap(find.byKey(const Key('theme_toggle_button')));
      await tester.pumpAndSettle();
      expect(notifier.value, ThemeMode.light);

      // Tap to toggle to Dark
      await tester.tap(find.byKey(const Key('theme_toggle_button')));
      await tester.pumpAndSettle();
      expect(notifier.value, ThemeMode.dark);

      // Tap to toggle back to System
      await tester.tap(find.byKey(const Key('theme_toggle_button')));
      await tester.pumpAndSettle();
      expect(notifier.value, ThemeMode.system);
    });

    testWidgets('DeviceCard displays device details and badge correctly',
        (WidgetTester tester) async {
      const physicalInfo = AppDeviceInfo(
        platform: 'iOS',
        model: 'iPhone 15 Pro',
        systemVersion: 'iOS 18.0',
        isPhysicalDevice: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeviceCard(deviceInfo: physicalInfo),
          ),
        ),
      );

      expect(find.text('Platform'), findsOneWidget);
      expect(find.text('iOS'), findsOneWidget);
      expect(find.text('iPhone 15 Pro'), findsOneWidget);
      expect(find.text('iOS 18.0'), findsOneWidget);
      expect(find.text('Physical'), findsOneWidget);

      const simInfo = AppDeviceInfo(
        platform: 'iOS',
        model: 'iPhone 14',
        systemVersion: 'iOS 17.0',
        isPhysicalDevice: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeviceCard(deviceInfo: simInfo),
          ),
        ),
      );

      expect(find.text('Simulator'), findsOneWidget);
    });
  });
}
