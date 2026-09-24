# Taekworld

Flutter app built with **feature-first Clean Architecture**, Riverpod, Dio, and a centralized design system.

- **Flutter**: 3.38.5 (via FVM)
- **State management**: Riverpod
- **Networking**: Dio
- **Immutable models / unions**: Freezed

---

## Architecture

```text
Presentation → Application → Domain ← Data
```

| Concern | Location |
| --- | --- |
| API call | `features/<feature>/data/datasources` |
| API model | `features/<feature>/data/models` |
| Repository implementation | `features/<feature>/data/repositories` |
| Repository contract | `features/<feature>/domain/repositories` |
| Business entity | `features/<feature>/domain/entities` |
| State / controller | `features/<feature>/application/controllers` |
| Screen | `features/<feature>/presentation/screens` |
| Feature widget | `features/<feature>/presentation/widgets` |
| Shared infrastructure | `lib/core/` |
| Design system | `lib/config/` |

Do **not** call Dio/APIs/repository implementations from widgets.

---

## Folder structure

```text
lib/
├── core/
│   ├── network/
│   ├── constants/
│   ├── errors/
│   ├── extensions/
│   ├── utils/
│   └── widgets/
├── config/
│   ├── app_colors.dart
│   ├── app_scale.dart
│   ├── app_size.dart
│   ├── app_text_style.dart
│   ├── app_assets.dart
│   └── app_theme.dart
├── features/
│   └── login/
│       ├── data/
│       ├── domain/
│       ├── application/
│       └── presentation/
└── main.dart
```

Future features (`home`, `profile`, `leads`, `settings`, …) follow the same layout.

---

## Design system

| File | Responsibility |
| --- | --- |
| `AppColors` | Semantic colors only |
| `AppScale` | Responsive calculations |
| `AppSize` | Spacing / radius / icon / component tokens |
| `AppTextStyle` | Typography (`h*`, `t*`, `b*`, `l*`) |
| `AppAssets` | Asset path constants |
| `AppTheme` | Material 3 `ThemeData` integration (no duplicated tokens) |

---

## Getting started

```bash
fvm use 3.38.5
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter run
```

### API environment (UAT / production)

Hosts live in `lib/core/network/api_env.dart`. Default is **UAT**.

```bash
# UAT (default)
fvm flutter run --dart-define=API_ENV=uat

# Production
fvm flutter run --dart-define=API_ENV=production

# Optional full URL override (wins over API_ENV)
fvm flutter run --dart-define=API_BASE_URL=https://api.taekworld.com
```

| Flavour | Base URL |
| --- | --- |
| `uat` (default) | `https://api-uat-433251623503.us-east4.run.app` |
| `production` | `https://api.taekworld.com` |

Auth tokens are stored in the platform secure store (`flutter_secure_storage`), not SharedPreferences.

---

## Release builds (UAT / production)

Version is set in `pubspec.yaml` (`2.0.0+6` and up). Do **not** commit keystores, `android/key.properties`, or Firebase service-account keys.

### Android App Bundle (`.aab`)

Taekworld re-signs for Play Console. If `android/key.properties` is absent, the release build is signed with the **debug** key (acceptable for hand-over).

```bash
fvm flutter pub get

# Production (required dart-define for store / hand-over AAB)
fvm flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://api.taekworld.com

# UAT (QA / internal testing)
fvm flutter build appbundle --release \
  --dart-define=API_ENV=uat
# or:
# fvm flutter build appbundle --release \
#   --dart-define=API_BASE_URL=https://api-uat-433251623503.us-east4.run.app
```

Output:

```text
build/app/outputs/bundle/release/app-release.aab
```

Optional APK for sideload testing:

```bash
fvm flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.taekworld.com
```

### iOS (Xcode archive)

Taekworld archives and signs with team **DGLC43XKDD**, then uploads to App Store Connect / TestFlight. Vendor delivers an Xcode-archivable project (no store upload required from vendor).

```bash
fvm flutter pub get

# Production
fvm flutter build ipa --release \
  --dart-define=API_BASE_URL=https://api.taekworld.com \
  --no-codesign

# UAT
fvm flutter build ipa --release \
  --dart-define=API_ENV=uat \
  --no-codesign
```

Or open `ios/Runner.xcworkspace` in Xcode → select a generic iOS Device → **Product → Archive**. Pass the same `--dart-define` via Xcode / `flutter build ios` before archiving:

```bash
fvm flutter build ios --release \
  --dart-define=API_BASE_URL=https://api.taekworld.com \
  --no-codesign
```

Bundle ID: `com.taekworld.master`.

---

## Code generation

After changing Freezed / JSON models:

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

Generated files stay next to their sources (`*.freezed.dart`, `*.g.dart`). Never edit them by hand.

---

## Adding a new feature

1. Create `lib/features/<name>/` with `data`, `domain`, `application`, `presentation`.
2. Define domain entities + repository contracts.
3. Implement datasources, models, and repository in `data/`.
4. Add a Riverpod controller in `application/controllers/`.
5. Build screens/widgets in `presentation/` using `config/` + `core/widgets/`.
