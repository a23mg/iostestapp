# Flutter iOS Development on Windows (MobAI Builder)

[![Flutter](https://img.shields.io/badge/Flutter-3.32.5-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Windows-blue)](https://github.com/a23mg/iostestapp)
[![CI Provider](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF?logo=github-actions)](https://github.com/a23mg/iostestapp/actions)
[![Builder](https://img.shields.io/badge/Powered%20By-MobAI%20Builder-00C853)](https://mobai.run)

A complete Flutter iOS application developed and tested entirely on **Windows without requiring a local Mac**, using [MobAI-App/ios-builder](https://github.com/MobAI-App/ios-builder) and GitHub Actions macOS cloud runners.

- **Repository**: [https://github.com/a23mg/iostestapp](https://github.com/a23mg/iostestapp)
- **Target OS**: iOS 13.0+
- **Flutter SDK**: 3.32.5
- **Bundle Identifier**: `com.example.testflutter`

---

## Table of Contents

- [Overview & Architecture](#overview--architecture)
- [Project Structure](#project-structure)
- [Prerequisites & Tooling](#prerequisites--tooling)
- [Developer Runbook](#developer-runbook)
  - [Step 1: Push Project to GitHub](#step-1-push-project-to-github)
  - [Step 2: Authenticate GitHub in Builder](#step-2-authenticate-github-in-builder)
  - [Step 3: Remote iOS Build (IPA)](#step-3-remote-ios-build-ipa)
  - [Step 4: Live On-Device Development & Hot Reload](#step-4-live-on-device-development--hot-reload)
  - [Step 5: Cloud iOS Simulator Preview](#step-5-cloud-ios-simulator-preview)
  - [Step 6: Optional Code Signing (Zero Mac Required)](#step-6-optional-code-signing-zero-mac-required)
- [Local Testing & Code Quality](#local-testing--code-quality)
- [Troubleshooting & FAQ](#troubleshooting--faq)

---

## Overview & Architecture

Developing Flutter applications for iOS traditionally requires a physical macOS machine with Xcode installed. With **MobAI Builder**, you can develop, build, and test Flutter iOS apps natively on Windows:

```
+-------------------------------------------------------------------------+
|                              Windows PC                                 |
|  - Flutter SDK 3.32.5                                                   |
|  - MobAI Builder CLI (builder.exe)                                      |
|  - Code editing, widget tests, static analysis                          |
+-------------------+--------------------------------+--------------------+
                    |                                |
        git push /  |                    builder dev | Flutter Attach /
  builder ios build |                    flutter     | WebSocket Hot Reload
                    v                                v
+-------------------------------+      +----------------------------------+
|    GitHub Actions (macOS)     |      |       Physical iOS Device        |
|  - Builds Flutter & Xcode     | ---> |  - MobAI App (App Store)         |
|  - Packages unsigned / signed |      |  - Instant UI updates            |
|    .ipa into ./dist/          |      |  - Device diagnostics & preview  |
+-------------------------------+      +----------------------------------+
```

### Key Capabilities
1. **Cloud macOS Compilation**: Compiles the Xcode workspace and Flutter iOS bundle via GitHub Actions (`macos-latest`).
2. **Local Artifact Retrieval**: Automatically streams build logs and downloads compiled `.ipa` packages directly to `./dist/`.
3. **Interactive Device Hot Reload**: Pairs Windows development with a physical iPhone/iPad running the MobAI app over WiFi, supporting real-time Flutter hot reload (`r`) and restart (`R`).
4. **Cloud Simulator Streaming**: Streams interactive cloud iOS simulators straight into the MobAI app.

---

## Project Structure

```
testflutter/
├── .github/
│   └── workflows/
│       ├── ios-build.yml          # GitHub Actions macOS iOS build workflow
│       └── ios-share.yml          # GitHub Actions cloud simulator workflow
├── builder.json                   # MobAI builder configuration (iOS & Flutter specs)
├── lib/
│   ├── main.dart                  # App entry point, ThemeMode management & router
│   ├── models/
│   │   └── device_info.dart       # Device info data model
│   ├── services/
│   │   └── device_service.dart    # Device detection & diagnostics service
│   └── views/
│       └── home_view.dart         # Material 3 UI showcase with interactive counter & diagnostics
├── test/
│   ├── device_service_test.dart   # Unit tests for device models & services
│   └── widget_test.dart           # Widget tests for UI, counter, & theme switching
├── ios/                           # Native iOS Runner project & configurations
├── pubspec.yaml                   # Flutter dependencies & metadata
└── README.md                      # Developer runbook & documentation
```

---

## Prerequisites & Tooling

Before beginning iOS development on Windows, ensure the following tools are installed and configured:

| Tool | Version / Location | Purpose |
|------|--------------------|---------|
| **Flutter SDK** | `3.32.5` | Flutter framework and Dart runtime |
| **MobAI Builder CLI** | `builder.exe` (`C:\Users\5A09_xx\bin\builder.exe`) | CLI orchestrator for remote builds and device bridge |
| **Git** | `git version 2.40+` | Version control and GitHub sync |
| **MobAI iOS App** | Latest (from App Store or [mobai.run](https://mobai.run)) | Physical device client for iOS live preview and hot reload |
| **GitHub Account** | Access to `https://github.com/a23mg/iostestapp` | Hosted repository and CI/CD runner execution |

### Verifying Tools on Windows

Open PowerShell or your preferred terminal:

```powershell
# Verify Flutter SDK
flutter --version

# Verify MobAI Builder CLI
builder --version
```

> **Note**: If `builder` is not recognized immediately, ensure `C:\Users\5A09_xx\bin` is present in your User `PATH` environment variable or restart your terminal session.

---

## Developer Runbook

Follow these steps for remote iOS compilation, local hot reload, and simulator preview.

### Step 1: Push Project to GitHub

Ensure your latest local commits are pushed to the GitHub repository:

```bash
git push -u origin main
```

Confirm that the repository at `https://github.com/a23mg/iostestapp` contains the project files, `builder.json`, and `.github/workflows/`.

### Step 2: Authenticate GitHub in Builder

The MobAI Builder CLI coordinates GitHub Actions workflows on your behalf. Authenticate with your GitHub account:

```bash
builder auth github
```

Follow the browser or personal access token prompt to grant workflow permissions. You can verify authentication status anytime:

```bash
builder auth status
```

### Step 3: Remote iOS Build (IPA)

Trigger an automated iOS build on a GitHub Actions macOS runner:

```bash
builder ios build
```

#### What happens behind the scenes:
1. `builder` creates a working-tree snapshot and triggers the `.github/workflows/ios-build.yml` workflow.
2. The GitHub Actions runner checks out the repository, installs Flutter SDK `3.32.5` (defined in `builder.json`), and installs CocoaPods dependencies.
3. Xcode compiles `Runner.xcworkspace` with the `Release` configuration.
4. The workflow packages the `.ipa` artifact and `builder` downloads it automatically into your local `./dist/` directory (e.g. `./dist/testflutter.ipa`).

#### Helpful Build Flags:
- `--unsigned`: Build an unsigned IPA (skips Apple code signing):
  ```bash
  builder ios build --unsigned
  ```
- `-o, --output <dir>`: Change the output destination directory (default is `dist`):
  ```bash
  builder ios build --output dist
  ```
- `-v, --verbose`: Enable detailed streaming of GitHub Actions build logs:
  ```bash
  builder ios build --verbose
  ```

---

### Step 4: Live On-Device Development & Hot Reload

Develop in real time on a physical iPhone or iPad connected over the local network:

1. **Install MobAI App**: Download and open the MobAI app on your iOS device from the App Store or [mobai.run](https://mobai.run).
2. **Ensure Same Network**: Connect both your Windows PC and your iOS device to the same Wi-Fi network (or iOS Personal Hotspot).
3. **Launch Dev Session**:
   ```bash
   builder dev flutter
   ```

#### Interactive Session Features:
- **Automatic File Watching**: Edits saved in `lib/` trigger an immediate hot reload on the physical device.
- **Terminal Control Keys**:
  - `r` — Hot reload UI state and widget trees.
  - `R` — Full restart (re-initializes application state).
  - `h` — Display interactive help and available shortcuts.
  - `q` — Detach and quit the development session.

#### Optional Dev Flags:
```bash
# Point to a specific IPA if multiple exist in dist/
builder dev flutter --ipa dist/testflutter.ipa

# Skip re-installing if the app is already installed on the phone
builder dev flutter --skip-install --bundle-id com.example.testflutter

# Disable automatic file watcher (manual 'r' reload only)
builder dev flutter --no-watch
```

---

### Step 5: Cloud iOS Simulator Preview

If you do not have a physical iOS device on hand, preview the app using a cloud macOS simulator:

```bash
builder ios share
```

#### How it works:
1. `builder` triggers `.github/workflows/ios-share.yml` on GitHub Actions.
2. A macOS runner boots an iOS Simulator, compiles the simulator build, and initializes a secure WebRTC/WebSocket bridge.
3. The live simulator appears directly inside the MobAI app under the **CI Devices** tab, allowing interactive testing from Windows.
4. The simulator session remains active while in use (default timeout: 30 minutes).

---

### Step 6: Optional Code Signing (Zero Mac Required)

You do not need a Mac or Xcode to create Apple code signing certificates and provisioning profiles. MobAI Builder provides built-in utilities:

1. **Generate Certificate Signing Request (CSR) on Windows**:
   ```bash
   builder signing csr
   ```
   This generates a private key (`private_key.pem`) and a Certificate Signing Request (`request.certSigningRequest`).

2. **Obtain Apple Certificate**:
   - Upload `request.certSigningRequest` to the [Apple Developer Portal](https://developer.apple.com/account/resources/certificates/add).
   - Download the generated `.cer` file (e.g. `ios_distribution.cer`).

3. **Assemble PKCS#12 (.p12) Archive**:
   ```bash
   builder signing p12
   ```
   Combines your private key and the Apple certificate into a password-protected `.p12` file.

4. **Configure CI Secrets**:
   ```bash
   builder signing setup
   ```
   Automatically uploads the required repository secrets (`APPLE_CERTIFICATE_P12`, `APPLE_CERTIFICATE_PASSWORD`, `APPLE_PROVISIONING_PROFILE`) to your GitHub repository so future `builder ios build` runs produce fully signed IPAs.

---

## Local Testing & Code Quality

Maintain high code quality with Flutter's built-in testing and static analysis tools.

### Running Unit & Widget Tests

Execute the complete test suite:

```powershell
flutter test
```

Expected output:
```text
00:01 +6: All tests passed!
```

Test coverage includes:
- `test/device_service_test.dart`: Device info model initialization and diagnostics service fallback behavior.
- `test/widget_test.dart`: HomeView rendering, counter increment/decrement/reset, theme mode toggle (system/light/dark), and device diagnostics cards.

### Running Static Analysis

Analyze the codebase for lint issues, type mismatches, and deprecations:

```powershell
flutter analyze
```

Expected output:
```text
Analyzing testflutter...
No issues found! (ran in 2.0s)
```

---

## Troubleshooting & FAQ

### 1. `builder: The term 'builder' is not recognized`
- **Cause**: The user `bin` directory (`C:\Users\5A09_xx\bin`) has not been loaded into the active terminal's `$env:PATH`.
- **Fix**: Run `$env:PATH += ";C:\Users\5A09_xx\bin"` in PowerShell or restart your terminal / IDE session.

### 2. GitHub Actions Workflow Permission Denied
- **Cause**: GitHub repository default workflow permissions may be set to Read-only.
- **Fix**:
  1. Open your repository on GitHub: `https://github.com/a23mg/iostestapp/settings/actions`.
  2. Under **Workflow permissions**, select **Read and write permissions**.
  3. Check **Allow GitHub Actions to create and approve pull requests** and click **Save**.

### 3. MobAI App Cannot Discover Local Session
- **Cause**: Firewall blocking incoming connection or device is on a different subnet.
- **Fix**:
  - Verify that both your PC and iOS device are on the exact same Wi-Fi network or connected via personal hotspot.
  - Temporarily allow incoming connections for `builder.exe` on Windows Defender Firewall.
  - Verify MobAI API server is accessible on `http://localhost:8686`.

### 4. How to Update MobAI Builder CLI
Update the builder CLI to the latest version at any time:
```bash
builder update
```
