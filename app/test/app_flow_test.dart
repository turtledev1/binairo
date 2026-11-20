import 'package:binairo_app/widgets/board_cell.dart';
import 'package:binairo_app/widgets/celebration.dart';
import 'package:binairo_core/binairo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_app.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('home', () {
    testWidgets('shows the title, new game and the three shortcuts', (
      tester,
    ) async {
      await pumpBinairoApp(tester);

      expect(find.text('Binairo'), findsOneWidget);
      expect(find.text('New game'), findsOneWidget);
      expect(find.text('How to play'), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
    });

    testWidgets('each shortcut opens its screen', (tester) async {
      await pumpBinairoApp(tester);

      for (final (shortcut, textOnScreen) in [
        ('How to play', 'Rule 1 · No three in a row'),
        ('Statistics', 'Average'),
        ('Settings', 'Show rule errors'),
      ]) {
        await tester.tap(find.text(shortcut));
        await tester.pumpAndSettle();
        expect(find.textContaining(textOnScreen), findsWidgets);
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('starting a game asks for the chosen size and level and '
        'remembers them for next time', (tester) async {
      final requestedPuzzles = <(int, Difficulty)>[];
      final services = await pumpBinairoApp(
        tester,
        requestedPuzzles: requestedPuzzles,
      );

      await startNewGameFromHome(
        tester,
        sizeLabel: '12×12',
        levelLabel: 'Hard',
      );

      expect(requestedPuzzles, [(12, Difficulty.hard)]);
      expect(find.byKey(const ValueKey('cell-0-0')), findsOneWidget);
      expect(services.settingsController.settings.lastBoardSize, 12);
      expect(
        services.settingsController.settings.lastDifficulty,
        Difficulty.hard,
      );
    });

    testWidgets(
      'leaving an unfinished game shows a continue card that resumes it',
      (tester) async {
        await pumpBinairoApp(tester);
        await startNewGameFromHome(tester);
        await tapCell(tester, 0, 0);

        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.text('50%'), findsOneWidget);
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        expect(digitInCell(0, 0, '0'), findsOneWidget);
      },
    );

    testWidgets(
      'starting a new game over a saved one asks first and cancel keeps it',
      (tester) async {
        final requestedPuzzles = <(int, Difficulty)>[];
        await pumpBinairoApp(tester, requestedPuzzles: requestedPuzzles);
        await startNewGameFromHome(tester);
        await tapCell(tester, 0, 0);
        await tester.pageBack();
        await tester.pumpAndSettle();

        await startNewGameFromHome(tester);
        expect(find.text('Start a new game?'), findsOneWidget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(requestedPuzzles, hasLength(1));
        expect(find.text('Continue'), findsOneWidget);
      },
    );
  });

  group('game', () {
    testWidgets('tapping an empty cell shows a zero, then a one', (
      tester,
    ) async {
      await pumpBinairoApp(tester);
      await startNewGameFromHome(tester);

      await tapCell(tester, 0, 0);
      expect(digitInCell(0, 0, '0'), findsOneWidget);

      await tapCell(tester, 0, 0);
      expect(digitInCell(0, 0, '1'), findsOneWidget);
    });

    testWidgets('restart from the menu asks first and cancel keeps the moves', (
      tester,
    ) async {
      await pumpBinairoApp(tester);
      await startNewGameFromHome(tester);
      await tapCell(tester, 0, 0);

      await openGameMenuItem(tester, 'Restart');
      expect(find.text('Restart puzzle?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(digitInCell(0, 0, '0'), findsOneWidget);
    });

    testWidgets('confirming restart from the menu clears the moves', (
      tester,
    ) async {
      await pumpBinairoApp(tester);
      await startNewGameFromHome(tester);
      await tapCell(tester, 0, 0);

      await openGameMenuItem(tester, 'Restart');
      await tester.tap(find.widgetWithText(FilledButton, 'Restart'));
      await tester.pumpAndSettle();

      expect(digitInCell(0, 0, '0'), findsNothing);
    });

    testWidgets('the menu opens how to play and settings', (tester) async {
      await pumpBinairoApp(tester);
      await startNewGameFromHome(tester);

      await openGameMenuItem(tester, 'How to play');
      expect(find.text('Rule 1 · No three in a row'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await openGameMenuItem(tester, 'Settings');
      expect(find.text('Show counters'), findsOneWidget);
    });

    testWidgets(
      'given cells and player cells holding the same digit look different',
      (tester) async {
        await pumpBinairoApp(tester);
        await startNewGameFromHome(tester);
        await tapCell(tester, 0, 0);

        Color backgroundOf(int row, int column) {
          final tile = tester.widget<Container>(
            find
                .descendant(
                  of: find.byKey(ValueKey('cell-$row-$column')),
                  matching: find.byType(Container),
                )
                .last,
          );
          return (tile.decoration! as BoxDecoration).color!;
        }

        expect(backgroundOf(0, 0), isNot(backgroundOf(0, 2)));
      },
    );

    testWidgets(
      'a cell that breaks a rule gets a ring in a color no digit uses',
      (tester) async {
        await pumpBinairoApp(tester);
        await startNewGameFromHome(tester);
        await tapCell(tester, 0, 0);
        await tapCell(tester, 0, 0);

        final ring = tester.widget<Container>(
          find
              .descendant(
                of: find.byKey(const ValueKey('cell-0-0')),
                matching: find.byType(Container),
              )
              .first,
        );
        final ringBorder =
            (ring.decoration! as BoxDecoration).border! as Border;

        expect(ringBorder.top.color, BoardCell.violationColor);
        expect(
          BoardCell.violationColor,
          isNot(anyOf(BoardCell.zeroColor, BoardCell.oneColor)),
        );
      },
    );

    testWidgets('turning off rule errors in settings removes the red ring', (
      tester,
    ) async {
      final services = await pumpBinairoApp(tester);
      await startNewGameFromHome(tester);
      await tapCell(tester, 0, 0);
      await tapCell(tester, 0, 0);

      await services.settingsController.update(
        (settings) => settings.copyWith(showRuleErrors: false),
      );
      await tester.pump();

      final ring = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(const ValueKey('cell-0-0')),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((ring.decoration! as BoxDecoration).border, isNull);
    });

    testWidgets('turning off counters in settings hides them', (tester) async {
      final services = await pumpBinairoApp(tester);
      await startNewGameFromHome(tester);
      expect(find.byKey(const ValueKey('row-counter-0')), findsOneWidget);

      await services.settingsController.update(
        (settings) => settings.copyWith(showLineCounters: false),
      );
      await tester.pump();

      expect(find.byKey(const ValueKey('row-counter-0')), findsNothing);
      expect(find.byKey(const ValueKey('column-counter-0')), findsNothing);
    });

    testWidgets('solving plays the celebration, then shows a first best time', (
      tester,
    ) async {
      await pumpBinairoApp(tester);
      await startNewGameFromHome(tester);

      await solvePuzzleMissingTwoCells(tester);
      await tester.pump(const Duration(milliseconds: 500));
      final poppingCells = find.descendant(
        of: find.byType(CelebrationWave),
        matching: find.byType(Transform),
      );
      expect(poppingCells, findsWidgets);
      expect(find.text('Solved!'), findsNothing);

      await tester.pumpAndSettle();
      expect(find.text('Solved!'), findsOneWidget);
      expect(find.textContaining('New best time'), findsOneWidget);
    });

    testWidgets(
      'after solving, home has no continue card and statistics count the solve',
      (tester) async {
        final services = await pumpBinairoApp(tester);
        await startNewGameFromHome(tester);
        await solvePuzzleMissingTwoCells(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(FilledButton, 'Home'));
        await tester.pumpAndSettle();

        expect(find.text('Continue'), findsNothing);
        final statistics = await services.statisticsRepository.load(
          4,
          Difficulty.easy,
        );
        expect(statistics.solvedCount, 1);
      },
    );
  });

  testWidgets('choosing dark theme in settings changes the app theme', (
    tester,
  ) async {
    await pumpBinairoApp(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  group('tap feedback', () {
    late List<String> hapticTypes;

    setUp(() {
      hapticTypes = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'HapticFeedback.vibrate') {
              hapticTypes.add(call.arguments as String);
            }
            return null;
          });
    });

    tearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    testWidgets('tapping a cell you can change gives one keyboard-like buzz', (
      tester,
    ) async {
      await pumpBinairoApp(tester);
      await startNewGameFromHome(tester);

      await tapCell(tester, 0, 0);

      expect(hapticTypes, ['HapticFeedbackType.mediumImpact']);
    });

    testWidgets('tapping a locked clue cell gives no buzz', (tester) async {
      await pumpBinairoApp(tester);
      await startNewGameFromHome(tester);

      await tapCell(tester, 1, 1);

      expect(hapticTypes, isEmpty);
    });

    testWidgets('turning vibration off stops the tap buzz', (tester) async {
      final services = await pumpBinairoApp(tester);
      await services.settingsController.update(
        (settings) => settings.copyWith(vibrationEnabled: false),
      );
      await startNewGameFromHome(tester);

      await tapCell(tester, 0, 0);

      expect(hapticTypes, isEmpty);
    });
  });
}
