import 'package:binairo_core/binairo_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/game_options.dart';
import 'app_settings.dart';

class SettingsController extends ChangeNotifier {
  SettingsController._(this._settings);

  static const String _themeModeKey = 'settings.theme_mode';
  static const String _vibrationEnabledKey = 'settings.vibration_enabled';
  static const String _showRuleErrorsKey = 'settings.show_rule_errors';
  static const String _showLineCountersKey = 'settings.show_line_counters';
  static const String _lastBoardSizeKey = 'settings.last_board_size';
  static const String _lastDifficultyKey = 'settings.last_difficulty';

  static Future<SettingsController> load() async {
    final preferences = await SharedPreferences.getInstance();
    const defaults = AppSettings();
    final savedBoardSize = preferences.getInt(_lastBoardSizeKey);
    return SettingsController._(
      AppSettings(
        themeMode: _enumByNameOrDefault(
          ThemeMode.values,
          preferences.getString(_themeModeKey),
          defaults.themeMode,
        ),
        vibrationEnabled:
            preferences.getBool(_vibrationEnabledKey) ??
            defaults.vibrationEnabled,
        showRuleErrors:
            preferences.getBool(_showRuleErrorsKey) ?? defaults.showRuleErrors,
        showLineCounters:
            preferences.getBool(_showLineCountersKey) ??
            defaults.showLineCounters,
        lastBoardSize: availableBoardSizes.contains(savedBoardSize)
            ? savedBoardSize!
            : defaults.lastBoardSize,
        lastDifficulty: _enumByNameOrDefault(
          Difficulty.values,
          preferences.getString(_lastDifficultyKey),
          defaults.lastDifficulty,
        ),
      ),
    );
  }

  AppSettings _settings;

  AppSettings get settings => _settings;

  Future<void> update(AppSettings Function(AppSettings current) change) async {
    _settings = change(_settings);
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeModeKey, _settings.themeMode.name);
    await preferences.setBool(_vibrationEnabledKey, _settings.vibrationEnabled);
    await preferences.setBool(_showRuleErrorsKey, _settings.showRuleErrors);
    await preferences.setBool(_showLineCountersKey, _settings.showLineCounters);
    await preferences.setInt(_lastBoardSizeKey, _settings.lastBoardSize);
    await preferences.setString(
      _lastDifficultyKey,
      _settings.lastDifficulty.name,
    );
  }

  static T _enumByNameOrDefault<T extends Enum>(
    List<T> values,
    String? name,
    T defaultValue,
  ) => values.where((value) => value.name == name).firstOrNull ?? defaultValue;
}
