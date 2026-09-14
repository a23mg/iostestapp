# Design Specification: Flutter iOS Development with MobAI ios-builder

- **Date**: 2026-09-14
- **Target OS / Host**: Windows 11 / PowerShell
- **Target Mobile Platform**: iOS (iPhone/iPad)
- **Framework**: Flutter 3.32.5 (Dart 3.8.1)
- **Build / Dev Tool**: MobAI `ios-builder` (v0.9.0)
- **GitHub Repository**: https://github.com/a23mg/iostestapp

---

## 1. Overview & Goals

The objective of this project is to build and develop a modern Flutter mobile application primarily targeting iOS from a Windows environment without requiring a local macOS machine. 

To achieve this:
1. A modern, cleanly architected Flutter application with Material 3 theming (light/dark switch), Cupertino styling touches, and device diagnostic indicators will be created in `D:/mgproject/testflutter`.
2. The official `builder-windows-amd64.exe` (v0.9.0) binary from `MobAI-App/ios-builder` will be installed and added to the user's environment `PATH` (`C:\Users\5A09_xx\bin\builder.exe`).
3. GitHub Actions configuration (`.github/workflows/ios-build.yml`) and `builder.json` will be initialized to automate remote iOS compilation on macOS cloud runners.
4. On-device development, live inspection, and hot-reload workflows will be integrated via the MobAI app on the user's physical iOS device.

---

## 2. Architecture & Components

### 2.1 Project Layout
```
D:/mgproject/testflutter/
├── .github/
│   └── workflows/
│       └── ios-build.yml          # GitHub Actions remote iOS build workflow
├── android/                       # Android native project
├── ios/                           # iOS native project (Runner.xcworkspace, Podfile, Info.plist)
├── lib/
│   ├── main.dart                  # App entry point, theme management & routing
│   ├── models/
│   │   └── device_info_model.dart # Holds iOS device properties
│   ├── services/
│   │   └── device_service.dart    # Reads platform and hardware diagnostics
│   └── views/
│       ├── home_view.dart         # Main dashboard screen
│       └── widgets/
│           ├── device_card.dart   # Displays iOS device info & scale
│           ├── counter_card.dart  # Interactive hot-reload verification widget
│           └── mobai_status_card.dart # Development tips & MobAI connection guide
├── pubspec.yaml                   # Flutter dependencies & assets configuration
├── builder.json                   # MobAI ios-builder configuration
└── .gitignore                     # Git ignore rules for Flutter & builder
```

### 2.2 Application Features
- **Design System**: Material 3 with adaptive Cupertino styling where appropriate.
- **Theme Modes**: Dynamic theme switcher with support for System Default, Light, and Dark modes.
- **Diagnostics**: Real-time display of platform name (`iOS`), device model name, iOS system version, and screen dimensions using `device_info_plus`.
- **Interactive State**: Stateful counter card with increment/decrement/reset buttons to instantly test and verify state preservation during live hot reload (`builder dev flutter`).

### 2.3 Dependencies
- `flutter`: Flutter SDK (v3.32.5).
- `cupertino_icons`: ^1.0.8 (iOS style iconography).
- `device_info_plus`: ^11.3.0 (Device hardware & OS version query).

---

## 3. Remote CI/CD & MobAI Toolchain

### 3.1 MobAI Builder CLI
- **Binary**: `builder-windows-amd64.exe` (v0.9.0) downloaded from `https://github.com/MobAI-App/ios-builder/releases/download/v0.9.0/builder-windows-amd64.exe`.
- **Location**: Installed at `C:\Users\5A09_xx\bin\builder.exe`.
- **System PATH**: Added to User `Path` environment variable.

### 3.2 Configuration File (`builder.json`)
```json
{
  "project": "fitdee",
  "platform": "flutter",
  "github": {
    "owner": "a23mg",
    "repo": "iostestapp"
  },
  "ios": {
    "path": "ios",
    "scheme": "Runner",
    "configuration": "Debug"
  },
  "flutter": {
    "version": "3.32.5"
  }
}
```

### 3.3 Remote macOS Pipeline (`.github/workflows/ios-build.yml`)
- Runs on `macos-latest` GitHub Actions runners.
- Supported triggers:
  - `workflow_dispatch`: triggered directly by `builder ios build` CLI command via GitHub API.
  - `push` on tags `ios-build/*`: triggered directly by git push for headless environments.
- Build Steps:
  1. Checks out repository source.
  2. Sets up Flutter `3.32.5`.
  3. Installs CocoaPods dependencies.
  4. Runs `flutter build ipa --no-codesign` (or signed if credentials are provided).
  5. Uploads `./build/ios/ipa/*.ipa` as artifact named `ipa`.

---

## 4. On-Device Development & Hot Reload

### 4.1 Prerequisites on Physical iOS Device
1. Install **MobAI** app on iPhone/iPad (available on iOS App Store or [mobai.run](https://mobai.run)).
2. Pair the iOS device with MobAI account or ensure iPhone and PC are on the same local network / connected via MobAI tunnel.

### 4.2 Local Dev Commands
- **Authenticate GitHub**: `builder auth github` (stores token in local config).
- **Trigger Remote IPA Build**: `builder ios build` (downloads IPA artifact to `./dist/`).
- **Interactive Cloud Simulator**: `builder ios share` (free simulator session streamed to MobAI).
- **Live On-Device Dev & Hot Reload**: `builder dev flutter`
  - Watches Dart files in `lib/`.
  - Injects delta changes into the running app on iOS device.
  - Interactive terminal keys: `r` (hot reload), `R` (hot restart), `q` (quit).

---

## 5. Testing & Verification

1. **Local Flutter Verification**: Run `flutter analyze` and `flutter test` to ensure zero compilation or lint errors.
2. **CLI Verification**: Execute `builder help` in PowerShell to ensure binary responds correctly and is on PATH.
3. **Repository State**: `git status` verifies clean tracking of all source code, `builder.json`, and `.github/workflows/ios-build.yml`.
