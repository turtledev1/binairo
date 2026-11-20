import 'package:binairo_app/app/app_services.dart';
import 'package:binairo_app/app/binairo_app.dart';
import 'package:binairo_app/game/saved_game_repository.dart';
import 'package:binairo_app/settings/settings_controller.dart';
import 'package:binairo_app/statistics/statistics_repository.dart';
import 'package:binairo_core/binairo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_puzzles.dart';

final Puzzle puzzleMissingTwoCells = fourByFourPuzzleMissingCells(const [
  CellPosition(0, 0),
  CellPosition(3, 3),
]);

Future<AppServices> pumpBinairoApp(
  WidgetTester tester, {
  List<(int, Difficulty)>? requestedPuzzles,
}) async {
  final settingsController = await SettingsController.load();
  final services = AppServices(
    savedGameRepository: SavedGameRepository(),
    statisticsRepository: StatisticsRepository(),
    settingsController: settingsController,
    puzzleFactory: (size, difficulty) async {
      requestedPuzzles?.add((size, difficulty));
      return puzzleMissingTwoCells;
    },
  );
  await tester.pumpWidget(BinairoApp(services: services));
  await tester.pumpAndSettle();
  return services;
}

Future<void> startNewGameFromHome(
  WidgetTester tester, {
  String? sizeLabel,
  String? levelLabel,
}) async {
  await tester.tap(find.text('New game'));
  await tester.pumpAndSettle();
  if (sizeLabel != null) await tester.tap(find.text(sizeLabel));
  if (levelLabel != null) await tester.tap(find.text(levelLabel));
  await tester.pump();
  await tester.tap(find.text('Start'));
  await tester.pumpAndSettle();
}

Future<void> tapCell(WidgetTester tester, int row, int column) async {
  await tester.tap(find.byKey(ValueKey('cell-$row-$column')));
  await tester.pump();
}

Finder digitInCell(int row, int column, String digit) => find.descendant(
  of: find.byKey(ValueKey('cell-$row-$column')),
  matching: find.text(digit),
);

Future<void> solvePuzzleMissingTwoCells(WidgetTester tester) async {
  await tapCell(tester, 0, 0);
  await tapCell(tester, 3, 3);
  await tapCell(tester, 3, 3);
}

Future<void> openGameMenuItem(WidgetTester tester, String label) async {
  await tester.tap(find.byTooltip('Menu'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}
