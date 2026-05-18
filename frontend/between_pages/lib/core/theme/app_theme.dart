import 'package:flutter/material.dart';
import 'app_colors.dart';

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.statusReading,
    required this.statusPending,
    required this.statusFinished,
    required this.statusAbandoned,
    required this.colorLibro,
    required this.colorFanfic,
    required this.colorManga,
  });

  final Color? statusReading;
  final Color? statusPending;
  final Color? statusFinished;
  final Color? statusAbandoned;
  final Color? colorLibro;
  final Color? colorFanfic;
  final Color? colorManga;


  @override
  CustomColors copyWith({
    Color? statusReading,
    Color? statusPending,
    Color? statusFinished,
    Color? statusAbandoned,
    Color? colorLibro,
    Color? colorFanfic,
    Color? colorManga,
  }) {
    return CustomColors(
      statusReading: statusReading ?? this.statusReading,
      statusPending: statusPending ?? this.statusPending,
      statusFinished: statusFinished ?? this.statusFinished,
      statusAbandoned: statusAbandoned ?? this.statusAbandoned,
      colorLibro: colorLibro ?? this.colorLibro,
      colorFanfic: colorFanfic ?? this.colorFanfic,
      colorManga: colorManga ?? this.colorManga,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      statusReading: Color.lerp(statusReading, other.statusReading, t),
      statusPending: Color.lerp(statusPending, other.statusPending, t),
      statusFinished: Color.lerp(statusFinished, other.statusFinished, t),
      statusAbandoned: Color.lerp(statusAbandoned, other.statusAbandoned, t),
      colorLibro: Color.lerp(colorLibro, other.colorLibro, t),
      colorFanfic: Color.lerp(colorFanfic, other.colorFanfic, t),
      colorManga: Color.lerp(colorManga, other.colorManga, t),
    );
  }
}

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightAccent,
      secondary: AppColors.lightEmphasis,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      primaryContainer: AppColors.lightCard,
      onPrimaryContainer: AppColors.lightTextPrimary,
      secondaryContainer: AppColors.lightBorder,
    ),
    textTheme: _textTheme(AppColors.lightTextPrimary, AppColors.lightTextSecondary),
    extensions: const <ThemeExtension<dynamic>>[
      CustomColors(
        statusReading: AppColors.statusReading,
        statusPending: AppColors.statusPending,
        statusFinished: AppColors.statusFinished,
        statusAbandoned: AppColors.statusAbandoned,
        colorLibro: AppColors.colorLibro,
        colorFanfic: AppColors.colorFanfic,
        colorManga: AppColors.colorManga,
      ),
    ],
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkAccent,
      secondary: AppColors.darkEmphasis,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      primaryContainer: AppColors.darkCard,
      onPrimaryContainer: AppColors.darkTextPrimary,
      secondaryContainer: AppColors.darkBorder,
    ),
    textTheme: _textTheme(AppColors.darkTextPrimary, AppColors.darkTextSecondary),
    extensions: const <ThemeExtension<dynamic>>[
      CustomColors(
        statusReading: AppColors.statusReading,
        statusPending: AppColors.statusPending,
        statusFinished: AppColors.statusFinished,
        statusAbandoned: AppColors.statusAbandoned,
        colorLibro: AppColors.colorLibro,
        colorFanfic: AppColors.colorFanfic,
        colorManga: AppColors.colorManga,
      ),
    ],
  );

  static TextTheme _textTheme(Color primaryColor, Color secondaryColor) {
    // Material 3: keep TextTheme keys that exist on your Flutter version.
    // Some widgets in this repo still reference legacy Material 2 names.
    return const TextTheme().apply(
      bodyColor: primaryColor,
      displayColor: primaryColor,
      decorationColor: primaryColor,
    ).copyWith(
      labelSmall: TextStyle(color: secondaryColor),
      labelMedium: TextStyle(color: secondaryColor),
      labelLarge: TextStyle(color: secondaryColor),
    );
  }


}

extension CustomTheme on BuildContext {
  CustomColors get customColors => Theme.of(this).extension<CustomColors>()!;
}
