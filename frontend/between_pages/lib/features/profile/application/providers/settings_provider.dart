import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final ThemeMode themeMode;
  final String fontFamily;

  AppSettings({
    this.themeMode = ThemeMode.system,
    this.fontFamily = 'Roboto', // Fuente por defecto
  });

  AppSettings copyWith({ThemeMode? themeMode, String? fontFamily}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    final font = prefs.getString('fontFamily') ?? 'Roboto';
    
    state = AppSettings(
      themeMode: ThemeMode.values[themeIndex],
      fontFamily: font,
    );
  }

  Future<void> updateTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> updateFont(String font) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontFamily', font);
    state = state.copyWith(fontFamily: font);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});