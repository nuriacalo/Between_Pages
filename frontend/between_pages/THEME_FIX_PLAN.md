# Theme fix plan (restore old AppColors look)

## Info gathered
- Current compile blockers were fixed, and the app is running.
- User reports the UI aesthetic changed (buttons/searchbar).
- User provided the exact “old” `AppColors` implementation they want restored.

## Plan
1. Replace `lib/core/theme/app_colors.dart` content with the exact AppColors the user pasted.
2. Ensure this new AppColors still satisfies all getters used by the app UI (it includes isDark/accent/surface/card/border/textPrimary/textSecondary/background/icons/emphasis, plus status colors).
3. Run `flutter run --debug` (or at least `flutter analyze`) to confirm there are no compile errors.

## Dependent files
- `lib/core/theme/app_theme.dart` may not need changes because it already uses `AppColors.lightAccent`, `AppColors.lightEmphasis`, etc.

## Followup steps
- If the aesthetic still differs, adjust `ThemeData` in `app_theme.dart` for `FilledButtonTheme` and `InputDecorationTheme` to match previous styles.

