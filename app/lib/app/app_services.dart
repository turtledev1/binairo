import 'dart:isolate';

import 'package:binairo_core/binairo_core.dart';
import 'package:flutter/widgets.dart';

import '../game/saved_game_repository.dart';
import '../settings/settings_controller.dart';
import '../statistics/statistics_repository.dart';

typedef PuzzleFactory =
    Future<Puzzle> Function(int size, Difficulty difficulty);

Future<Puzzle> generatePuzzleInBackground(int size, Difficulty difficulty) =>
    Isolate.run(
      () => PuzzleGenerator().generate(size: size, difficulty: difficulty),
    );

class AppServices {
  const AppServices({
    required this.savedGameRepository,
    required this.statisticsRepository,
    required this.settingsController,
    this.puzzleFactory = generatePuzzleInBackground,
  });

  final SavedGameRepository savedGameRepository;
  final StatisticsRepository statisticsRepository;
  final SettingsController settingsController;
  final PuzzleFactory puzzleFactory;
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  static AppServices of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.services;

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}
