# Flutter iOS App with MobAI ios-builder Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Scaffold a clean Material 3 Flutter application targeting iOS, install the MobAI `builder` CLI on Windows, configure remote GitHub Actions macOS workflows, and establish the on-device live development and hot reload pipeline for `https://github.com/a23mg/iostestapp`.

**Architecture:** A modular Flutter app (`models`, `services`, `views/widgets`) with theme switching and device diagnostics, coupled with the local `builder.exe` CLI and `.github/workflows/ios-build.yml` configured for automated cloud builds and MobAI device hot reload.

**Tech Stack:** Flutter 3.32.5 / Dart 3.8.1, `device_info_plus`, MobAI `builder` v0.9.0, GitHub Actions (`macos-latest`).

**Spec:** [docs/superpowers/specs/2026-09-14-ios-flutter-builder-design.md](file:///D:/mgproject/testflutter/docs/superpowers/specs/2026-09-14-ios-flutter-builder-design.md)

## Global Constraints
- Target workspace: `D:/mgproject/testflutter`
- Remote Git repository: `https://github.com/a23mg/iostestapp`
- Flutter version floor: `3.32.5`
- MobAI builder version: `v0.9.0`
- Operating System: Windows 11 (PowerShell)

---

### Task 1: Install and Configure MobAI `builder` CLI

**Files:**
- Create: `C:\Users\5A09_xx\bin\builder.exe`

**Interfaces:**
- Consumes: GitHub Releases API for `MobAI-App/ios-builder` v0.9.0
- Produces: Global `builder` command in PowerShell PATH

- [ ] **Step 1: Download `builder-windows-amd64.exe` to `C:\Users\5A09_xx\bin\builder.exe`**

```powershell
New-Item -ItemType Directory -Force -Path "C:\Users\5A09_xx\bin"
Invoke-WebRequest -Uri "https://github.com/MobAI-App/ios-builder/releases/download/v0.9.0/builder-windows-amd64.exe" -OutFile "C:\Users\5A09_xx\bin\builder.exe"
```

- [ ] **Step 2: Add `C:\Users\5A09_xx\bin` to User PATH if not present**

```powershell
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*C:\Users\5A09_xx\bin*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;C:\Users\5A09_xx\bin", "User")
}
$env:Path = "$env:Path;C:\Users\5A09_xx\bin"
```

- [ ] **Step 3: Verify builder CLI execution**

Run: `& "C:\Users\5A09_xx\bin\builder.exe" help`
Expected: Outputs `builder - iOS development without a Mac` with command descriptions (`auth`, `init`, `ios build`, `dev flutter`).

---

### Task 2: Scaffold Flutter Project & Configure Dependencies

**Files:**
- Create: `pubspec.yaml`
- Create: `ios/` directory & iOS Runner project
- Create: `android/` directory
- Create: `lib/main.dart`

**Interfaces:**
- Consumes: Flutter SDK 3.32.5
- Produces: Runnable Flutter workspace targeting iOS

- [ ] **Step 1: Scaffold Flutter project targeting iOS and Android**

```powershell
flutter create --org com.a23mg --project-name testflutter --platforms ios,android,web .
```

- [ ] **Step 2: Update `pubspec.yaml` with required dependencies**

Add `device_info_plus: ^11.3.0` and ensure `cupertino_icons: ^1.0.8` is listed under dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  device_info_plus: ^11.3.0
```

- [ ] **Step 3: Fetch dependencies and verify**

Run: `flutter pub get`
Expected: Resolves dependencies and returns exit code 0.

- [ ] **Step 4: Commit scaffolding**

```powershell
git add .
git commit -m "chore: scaffold flutter project with ios target and dependencies"
```

---

### Task 3: Implement Diagnostic Models, Services, and UI Components

**Files:**
- Create: `lib/models/device_info_model.dart`
- Create: `lib/services/device_service.dart`
- Create: `lib/views/widgets/device_card.dart`
- Create: `lib/views/widgets/counter_card.dart`
- Create: `lib/views/widgets/mobai_status_card.dart`
- Create: `lib/views/home_view.dart`
- Modify: `lib/main.dart`
- Create: `test/device_service_test.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes: `device_info_plus`, Flutter Material 3
- Produces: Complete showcase UI with live theme toggling, diagnostic cards, and responsive state

- [ ] **Step 1: Write unit test for `device_service.dart`**

Create `test/device_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:testflutter/models/device_info_model.dart';
import 'package:testflutter/services/device_service.dart';

void main() {
  test('AppDeviceInfo fallback constructor initializes default fields', () {
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
}
```

- [ ] **Step 2: Verify unit test fails before implementation**

Run: `flutter test test/device_service_test.dart`
Expected: FAIL due to missing imports.

- [ ] **Step 3: Implement `device_info_model.dart` and `device_service.dart`**

Create `lib/models/device_info_model.dart`:
```dart
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
```

Create `lib/services/device_service.dart`:
```dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/device_info_model.dart';

class DeviceService {
  final DeviceInfoPlugin _plugin;

  DeviceService({DeviceInfoPlugin? plugin})
      : _plugin = plugin ?? DeviceInfoPlugin();

  Future<AppDeviceInfo> getDeviceInfo() async {
    try {
      if (Platform.isIOS) {
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
```

- [ ] **Step 4: Run unit test to verify it passes**

Run: `flutter test test/device_service_test.dart`
Expected: PASS.

- [ ] **Step 5: Create UI Widgets and `home_view.dart`**

Create `lib/views/widgets/device_card.dart`, `lib/views/widgets/counter_card.dart`, `lib/views/widgets/mobai_status_card.dart`, and `lib/views/home_view.dart`.

- [ ] **Step 6: Update `lib/main.dart` with Material 3 and theme management**

Integrate `ValueNotifier<ThemeMode>` for dynamic Light/Dark mode toggling and connect `HomeView`.

- [ ] **Step 7: Update `test/widget_test.dart` and run tests**

Run: `flutter test` and `flutter analyze`
Expected: 0 errors, all tests pass.

- [ ] **Step 8: Commit UI implementation**

```powershell
git add lib test
git commit -m "feat: implement modern showcase UI with device diagnostics and theme toggle"
```

---

### Task 4: Configure MobAI ios-builder & GitHub Actions CI/CD

**Files:**
- Create: `builder.json`
- Create: `.github/workflows/ios-build.yml`

**Interfaces:**
- Consumes: MobAI builder specification
- Produces: Automated remote iOS compilation pipeline on GitHub Actions

- [ ] **Step 1: Create `builder.json` in project root**

```json
{
  "ios": {
    "path": "ios",
    "scheme": "Runner",
    "configuration": "Release"
  },
  "flutter": {
    "version": "3.32.5"
  }
}
```

- [ ] **Step 2: Create `.github/workflows/ios-build.yml`**

Create workflow targeting `macos-latest` with `workflow_dispatch` and tag `ios-build/*` triggers that builds the iOS IPA without local Mac requirement and uploads the `ipa` artifact.

- [ ] **Step 3: Commit builder configuration and CI/CD workflow**

```powershell
git add builder.json .github/workflows/ios-build.yml
git commit -m "ci: add mobai builder configuration and github actions ios build workflow"
```

---

### Task 5: Developer Runbook & Validation

**Files:**
- Create: `README.md`
- Modify: `.gitignore`

**Interfaces:**
- Consumes: Complete project setup
- Produces: Developer documentation and guide for `builder dev flutter` and `builder ios build`

- [ ] **Step 1: Update `.gitignore` for Flutter, MobAI builder artifacts (`dist/`), and caches**
- [ ] **Step 2: Write comprehensive `README.md` with step-by-step instructions for GitHub push, MobAI app pairing, and CLI commands**
- [ ] **Step 3: Run final checks (`flutter analyze`, `git status`)**
- [ ] **Step 4: Commit documentation**

```powershell
git add README.md .gitignore
git commit -m "docs: add comprehensive developer runbook for ios builder"
```
