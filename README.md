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

Override API base URL:

```bash
fvm flutter run --dart-define=API_BASE_URL=https://your-api.example.com
```

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
