import 'package:flutter/material.dart';
import 'views/home_view.dart';

final ValueNotifier<ThemeMode> themeModeNotifier =
    HomeView.defaultThemeNotifier;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final ValueNotifier<ThemeMode>? themeNotifier;

  const MyApp({super.key, this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    final notifier = themeNotifier ?? themeModeNotifier;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: notifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'iOS Builder Demo',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          ),
          home: HomeView(themeNotifier: notifier),
        );
      },
    );
  }
}
