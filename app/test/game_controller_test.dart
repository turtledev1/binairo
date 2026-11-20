import 'package:binairo_app/game/game_controller.dart';
import 'package:binairo_core/binairo_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_puzzles.dart';

void main() {
  late GameController controller;

  setUp(() {
    controller = GameController(
      puzzle: fourByFourPuzzleMissingCells(const [
        CellPosition(0, 0),
        CellPosition(0, 1),
        CellPosition(3, 3),
      ]),
    );
  });

  tearDown(() => controller.dispose());

  test(
    'tapping an empty cell cycles it through zero, one and back to empty',
    () {
      controller.tapCell(0, 0);
      expect(controller.currentBoard.cellAt(0, 0), CellValue.zero);
      controller.tapCell(0, 0);
      expect(controller.currentBoard.cellAt(0, 0), CellValue.one);
      controller.tapCell(0, 0);
      expect(controller.currentBoard.cellAt(0, 0), CellValue.empty);
    },
  );

  test('tapping a given cell does nothing and does not notify listeners', () {
    var notificationCount = 0;
    controller.addListener(() => notificationCount++);

    controller.tapCell(1, 1);

    expect(controller.currentBoard.cellAt(1, 1), CellValue.zero);
    expect(notificationCount, 0);
    expect(controller.canUndo, isFalse);
  });

  test('undo brings back the board from before the last tap', () {
    controller.tapCell(0, 0);
    controller.tapCell(0, 1);

    controller.undo();

    expect(controller.currentBoard.cellAt(0, 1), CellValue.empty);
    expect(controller.currentBoard.cellAt(0, 0), CellValue.zero);
  });

  test('restart clears player moves and can itself be undone', () {
    controller.tapCell(0, 0);

    controller.restart();
    expect(controller.currentBoard, controller.puzzle.givenBoard);

    controller.undo();
    expect(controller.currentBoard.cellAt(0, 0), CellValue.zero);
  });

  test('cells that break a rule are listed as violations', () {
    controller.tapCell(0, 1);

    expect(controller.cellsInViolation, contains(const CellPosition(0, 1)));
  });

  test('the board is solved only when full and every rule holds', () {
    controller.tapCell(0, 0);
    controller.tapCell(0, 1);
    controller.tapCell(0, 1);
    expect(controller.isSolved, isFalse);

    controller.tapCell(3, 3);
    controller.tapCell(3, 3);

    expect(controller.isSolved, isTrue);
    expect(controller.canUndo, isFalse);
  });

  test('a solved board ignores further taps', () {
    controller.tapCell(0, 0);
    controller.tapCell(0, 1);
    controller.tapCell(0, 1);
    controller.tapCell(3, 3);
    controller.tapCell(3, 3);

    controller.tapCell(0, 0);

    expect(controller.currentBoard.cellAt(0, 0), CellValue.zero);
  });

  test('line counters show how many zeros and ones are still missing', () {
    expect(controller.zerosLeftInRow(0), 1);
    expect(controller.onesLeftInRow(0), 1);
    expect(controller.zerosLeftInColumn(3), 0);
    expect(controller.onesLeftInColumn(3), 1);
  });

  test('elapsed time includes time from a previous session', () {
    final resumedController = GameController(
      puzzle: controller.puzzle,
      elapsedBeforeThisSession: const Duration(minutes: 3),
    );
    addTearDown(resumedController.dispose);

    expect(
      resumedController.elapsed,
      greaterThanOrEqualTo(const Duration(minutes: 3)),
    );
  });
}
