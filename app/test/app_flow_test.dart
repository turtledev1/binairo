import 'package:binairo_app/game/saved_game_repository.dart';
import 'package:binairo_app/screens/new_game_screen.dart';
import 'package:binairo_app/widgets/board_cell.dart';
import 'package:binairo_app/widgets/celebration.dart';
import 'package:binairo_core/binairo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_puzzles.dart';

void main() {
  final puzzleMissingTwoCells = fourByFourPuzzleMissingCells(const [
    CellPosition(0, 0),
    CellPosition(3, 3),
  ]);

  Widget buildApp({
    List<(int, Difficulty)>? requestedPuzzles,
    Puzzle? puzzleToServe,
  }) => MaterialApp(
    home: NewGameScreen(
      savedGameRepository: SavedGameRepository(),
      puzzleFactory: (size, difficulty) async {
        requestedPuzzles?.add((size, difficulty));
        return puzzleToServe ?? puzzleMissingTwoCells;
      },
    ),
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('starting a game asks for the chosen size and level', (
    tester,
  ) async {
    final requestedPuzzles = <(int, Difficulty)>[];
    await tester.pumpWidget(buildApp(requestedPuzzles: requestedPuzzles));

    await tester.tap(find.text('12'));
    await tester.tap(find.text('Hard'));
    await tester.tap(find.text('New game'));
    await tester.pumpAndSettle();

    expect(requestedPuzzles, [(12, Difficulty.hard)]);
    expect(find.byKey(const ValueKey('cell-0-0')), findsOneWidget);
  });

  testWidgets('tapping an empty cell shows a zero, then a one', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('New game'));
    await tester.pumpAndSettle();
    final firstCell = find.byKey(const ValueKey('cell-0-0'));

    await tester.tap(firstCell);
    await tester.pump();
    expect(
      find.descendant(of: firstCell, matching: find.text('0')),
      findsOneWidget,
    );

    await tester.tap(firstCell);
    await tester.pump();
    expect(
      find.descendant(of: firstCell, matching: find.text('1')),
      findsOneWidget,
    );
  });

  testWidgets('filling the last cells correctly shows the solved dialog', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('New game'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('cell-0-0')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('cell-3-3')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('cell-3-3')));
    await tester.pumpAndSettle();

    expect(find.text('Solved!'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'New game'));
    await tester.pumpAndSettle();
    expect(find.text('Size'), findsOneWidget);
    expect(find.textContaining('Continue'), findsNothing);
  });

  testWidgets('leaving an unfinished game offers to continue it', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('New game'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cell-0-0')));
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Continue'));
    await tester.pumpAndSettle();

    final firstCell = find.byKey(const ValueKey('cell-0-0'));
    expect(
      find.descendant(of: firstCell, matching: find.text('0')),
      findsOneWidget,
    );
  });

  Future<void> openGameAndPlayFirstCell(WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('New game'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cell-0-0')));
    await tester.pump();
  }

  Finder digitInFirstCell(String digit) => find.descendant(
    of: find.byKey(const ValueKey('cell-0-0')),
    matching: find.text(digit),
  );

  testWidgets('cancelling the restart dialog keeps the moves', (tester) async {
    await openGameAndPlayFirstCell(tester);

    await tester.tap(find.byTooltip('Restart'));
    await tester.pumpAndSettle();
    expect(find.text('Restart puzzle?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(digitInFirstCell('0'), findsOneWidget);
  });

  testWidgets('confirming the restart dialog clears the moves', (tester) async {
    await openGameAndPlayFirstCell(tester);

    await tester.tap(find.byTooltip('Restart'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Restart'));
    await tester.pumpAndSettle();

    expect(digitInFirstCell('0'), findsNothing);
  });

  testWidgets(
    'given cells and player cells holding the same digit look different',
    (tester) async {
      await openGameAndPlayFirstCell(tester);
      Color backgroundOf(String cellKey) {
        final tile = tester.widget<Container>(
          find
              .descendant(
                of: find.byKey(ValueKey(cellKey)),
                matching: find.byType(Container),
              )
              .last,
        );
        return (tile.decoration! as BoxDecoration).color!;
      }

      expect(backgroundOf('cell-0-0'), isNot(backgroundOf('cell-0-2')));
    },
  );

  testWidgets(
    'a cell that breaks a rule gets a ring in a color no digit uses',
    (tester) async {
      await openGameAndPlayFirstCell(tester);
      await tester.tap(find.byKey(const ValueKey('cell-0-0')));
      await tester.pump();

      final ring = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(const ValueKey('cell-0-0')),
              matching: find.byType(Container),
            )
            .first,
      );
      final ringBorder = (ring.decoration! as BoxDecoration).border! as Border;

      expect(ringBorder.top.color, BoardCell.violationColor);
      expect(
        BoardCell.violationColor,
        isNot(anyOf(BoardCell.zeroColor, BoardCell.oneColor)),
      );
    },
  );

  testWidgets('solving plays the celebration before the solved dialog opens', (
    tester,
  ) async {
    await openGameAndPlayFirstCell(tester);
    await tester.tap(find.byKey(const ValueKey('cell-3-3')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('cell-3-3')));
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 500));
    final poppingCells = find.descendant(
      of: find.byType(CelebrationWave),
      matching: find.byType(Transform),
    );
    expect(poppingCells, findsWidgets);
    expect(find.text('Solved!'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('Solved!'), findsOneWidget);
  });
}
