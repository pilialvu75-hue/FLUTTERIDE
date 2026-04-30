# MobileIde – Flutter Offline-First App

A fully **offline-first**, multiplatform code-editor built with Flutter.  
No internet connection is required at any point (no HTTP calls, no WebView, no hardcoded URLs).

## Architecture

```
flutter_app/
├── lib/
│   ├── core/
│   │   ├── app_constants.dart        # App-wide constants & language list
│   │   ├── orchestrator.dart         # Business logic (creates/edits/deletes projects)
│   │   └── theme/
│   │       └── app_theme.dart        # Material 3 light + dark theme
│   ├── data/
│   │   ├── database/
│   │   │   └── hive_database.dart    # Hive initialisation & box management
│   │   ├── models/
│   │   │   ├── project.dart          # @HiveType model
│   │   │   └── project.g.dart        # Pre-generated Hive adapter
│   │   └── repositories/
│   │       └── project_repository.dart  # CRUD on the Hive box
│   ├── ui/
│   │   ├── screens/
│   │   │   ├── dashboard_screen.dart # Project list + stats
│   │   │   ├── editor_screen.dart    # Monospace code editor
│   │   │   └── new_project_screen.dart # Create-project form
│   │   └── widgets/
│   │       ├── project_card.dart     # Card with rename/delete menu
│   │       └── language_badge.dart   # Coloured language chip
│   └── main.dart                     # Entry point + Hive init
├── test/
│   └── project_test.dart             # Unit tests (no network needed)
└── pubspec.yaml
```

## Prerequisites

| Tool | Minimum version |
|------|----------------|
| Flutter SDK | 3.19.x (Dart ≥ 3.3) |
| Android SDK | API 24+ |
| Windows | Windows 10+ (Visual Studio 2022 with "Desktop development with C++") |
| Linux | CMake ≥ 3.14, GTK 3 dev libs, Ninja |

Install Flutter: <https://docs.flutter.dev/get-started/install>

## 1 · Get dependencies

```bash
cd flutter_app
flutter pub get
```

> The `project.g.dart` file is already included (pre-generated).  
> Only re-run the generator if you modify the `Project` model:
> ```bash
> dart run build_runner build --delete-conflicting-outputs
> ```

## 2 · Run on Android

```bash
# Connect a device or start an emulator
flutter run -d android
```

Build a release APK:

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

Build an App Bundle (Play Store):

```bash
flutter build appbundle --release
```

## 3 · Run on Windows

```bash
flutter run -d windows
```

Build a release executable:

```bash
flutter build windows --release
# Output: build/windows/x64/runner/Release/
```

## 4 · Run on Linux

Install GTK development dependencies first (Ubuntu/Debian):

```bash
sudo apt-get install -y libgtk-3-dev libblkid-dev liblzma-dev
```

Then:

```bash
flutter run -d linux
```

Build a release binary:

```bash
flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

## 5 · Run on macOS / iOS

```bash
flutter run -d macos    # macOS desktop
flutter run -d ios      # iPhone simulator or device
```

## 6 · Run unit tests

```bash
flutter test
```

## Offline guarantee

- **No HTTP client** is imported anywhere (`http`, `dio`, etc. are absent from `pubspec.yaml`).
- **No WebView** widget is used.
- **No URLs** are hardcoded in the source.
- All data is persisted locally via [Hive](https://pub.dev/packages/hive) in the device's application documents directory.
- The app operates identically in **Airplane Mode**.

## Local data (Hive)

Projects are stored in a Hive box named `projects`.  
The box file is located at `<ApplicationDocumentsDirectory>/projects.hive`.

| Field | Type | Description |
|-------|------|-------------|
| `id` | String (UUID v4) | Unique identifier |
| `name` | String | Project name |
| `language` | String | Programming language |
| `content` | String | Source code text |
| `createdAt` | DateTime | Creation timestamp |
| `updatedAt` | DateTime | Last save timestamp |
