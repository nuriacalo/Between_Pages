# TODO - Fix Flutter compile errors

- [ ] Fix `lib/core/theme/app_colors.dart` (file is truncated / syntax + add missing static getters used by UI)
- [ ] Fix DTO compilation: rename title/author fields + getters to match `MediaItem` (`lib/features/catalog/domain/fanfiction_response_dto.dart`, `lib/features/catalog/domain/manga_response_dto.dart`)
- [ ] Fix theme selection in `lib/main.dart` (AppTheme.light/dark -> AppTheme.lightTheme/darkTheme)
- [ ] Fix localization missing getters used in UI (`findSomethingToRead`, `profileDarkMode`) and keep ARB files consistent
- [ ] Fix `ownership_badge.dart` using `_color.shade200` (invalid) -> use proper opacity/color
- [ ] Run `flutter clean && flutter pub get && flutter run` and iterate remaining build errors

