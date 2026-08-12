# Ascend Mobile

Flutter iOS/Android client. See `../docs/ARCHITECTURE.md` and `../docs/DESIGN_SYSTEM.md`.

## Quick start

```bash
cd mobile
flutter pub get
flutter run
flutter test
```

## Foundation (Phase 3)

- `AscendTheme` design tokens (colors, spacing, radius, glass, typography, animations)
- Riverpod + GoRouter shell
- Floating glass hotbar: Home · Learn · Knowledge · Progress · Profile
- Home preview screen with glass cards
- Light / Dark / System theme toggle in Profile

## Structure

```
lib/
  app.dart
  core/theme/       # AscendTheme system
  core/routing/     # GoRouter
  core/widgets/     # glass + background
  features/         # feature modules
  shared/
```
