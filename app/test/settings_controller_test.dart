import 'package:binairo_app/settings/settings_controller.dart';
import 'package:binairo_core/binairo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('first launch uses the defaults', () async {
    final settings = (await SettingsController.load()).settings;

    expect(settings.themeMode, ThemeMode.system);
    expect(settings.vibrationEnabled, isTrue);
    expect(settings.showRuleErrors, isTrue);
    expect(settings.showLineCounters, isTrue);
    expect(settings.lastBoardSize, 8);
    expect(settings.lastDifficulty, Difficulty.easy);
  });

  test('changed settings are still there after the app restarts', () async {
    final controller = await SettingsController.load();

    await controller.update(
      (settings) => settings.copyWith(
        themeMode: ThemeMode.dark,
        vibrationEnabled: false,
        showRuleErrors: false,
        showLineCounters: false,
        lastBoardSize: 12,
        lastDifficulty: Difficulty.hard,
      ),
    );
    final reloaded = (await SettingsController.load()).settings;

    expect(reloaded.themeMode, ThemeMode.dark);
    expect(reloaded.vibrationEnabled, isFalse);
    expect(reloaded.showRuleErrors, isFalse);
    expect(reloaded.showLineCounters, isFalse);
    expect(reloaded.lastBoardSize, 12);
    expect(reloaded.lastDifficulty, Difficulty.hard);
  });

  test('updating notifies listeners so the screens rebuild', () async {
    final controller = await SettingsController.load();
    var notificationCount = 0;
    controller.addListener(() => notificationCount++);

    await controller.update(
      (settings) => settings.copyWith(vibrationEnabled: false),
    );

    expect(notificationCount, 1);
  });

  test('unknown saved values fall back to the defaults', () async {
    SharedPreferences.setMockInitialValues({
      'settings.theme_mode': 'purple',
      'settings.last_board_size': 7,
      'settings.last_difficulty': 'impossible',
    });

    final settings = (await SettingsController.load()).settings;

    expect(settings.themeMode, ThemeMode.system);
    expect(settings.lastBoardSize, 8);
    expect(settings.lastDifficulty, Difficulty.easy);
  });
}
