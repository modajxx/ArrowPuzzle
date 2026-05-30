import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'prefs_provider.dart';

class Settings {
  final bool soundEnabled;
  final bool hapticsEnabled;
  final ThemeMode themeMode;
  const Settings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.themeMode = ThemeMode.system,
  });

  Settings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    ThemeMode? themeMode,
  }) =>
      Settings(
        soundEnabled: soundEnabled ?? this.soundEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        themeMode: themeMode ?? this.themeMode,
      );
}

class SettingsNotifier extends Notifier<Settings> {
  static const _soundKey = 'pref_sound';
  static const _hapticsKey = 'pref_haptics';
  static const _themeKey = 'pref_theme';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  Settings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return Settings(
      soundEnabled: prefs.getBool(_soundKey) ?? true,
      hapticsEnabled: prefs.getBool(_hapticsKey) ?? true,
      themeMode: _parseTheme(prefs.getString(_themeKey)),
    );
  }

  Future<void> setSoundEnabled(bool v) async {
    state = state.copyWith(soundEnabled: v);
    await _prefs.setBool(_soundKey, v);
  }

  Future<void> setHapticsEnabled(bool v) async {
    state = state.copyWith(hapticsEnabled: v);
    await _prefs.setBool(_hapticsKey, v);
  }

  Future<void> setThemeMode(ThemeMode m) async {
    state = state.copyWith(themeMode: m);
    await _prefs.setString(_themeKey, _themeString(m));
  }

  static ThemeMode _parseTheme(String? s) => switch (s) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String _themeString(ThemeMode m) => switch (m) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);
