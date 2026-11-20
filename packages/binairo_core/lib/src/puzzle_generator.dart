import 'dart:math';

import 'board.dart';
import 'deduction_engine.dart';
import 'difficulty.dart';
import 'solution_grid_generator.dart';

class Puzzle {
  const Puzzle({
    required this.difficulty,
    required this.givenBoard,
    required this.solutionBoard,
  });

  final Difficulty difficulty;
  final Board givenBoard;
  final Board solutionBoard;

  int get size => givenBoard.size;
}

/// No uniqueness check is needed: every deduction is forced, so a board that
/// deductions alone can fill has only one solution.
class PuzzleGenerator {
  PuzzleGenerator({Random? random}) : _random = random ?? Random();

  static const int maximumAttemptsToNeedHardDeductions = 20;

  final Random _random;

  Puzzle generate({required int size, required Difficulty difficulty}) {
    late Puzzle lastPuzzle;
    for (
      var attempt = 0;
      attempt < maximumAttemptsToNeedHardDeductions;
      attempt++
    ) {
      lastPuzzle = _generateOnce(size, difficulty);
      if (difficulty == Difficulty.easy ||
          !_canSolveWith(lastPuzzle.givenBoard, Difficulty.easy)) {
        return lastPuzzle;
      }
    }
    return lastPuzzle;
  }

  Puzzle _generateOnce(int size, Difficulty difficulty) {
    final solutionBoard = SolutionGridGenerator(_random).generate(size);
    final givenCellCodes = cellCodesFromBoard(solutionBoard);
    final cellIndexesInRemovalOrder = List.generate(
      givenCellCodes.length,
      (index) => index,
    )..shuffle(_random);

    for (final cellIndex in cellIndexesInRemovalOrder) {
      final removedCode = givenCellCodes[cellIndex];
      givenCellCodes[cellIndex] = emptyCellCode;
      if (!_canSolveCellCodesWith(size, givenCellCodes, difficulty)) {
        givenCellCodes[cellIndex] = removedCode;
      }
    }

    return Puzzle(
      difficulty: difficulty,
      givenBoard: boardFromCellCodes(size, givenCellCodes),
      solutionBoard: solutionBoard,
    );
  }

  bool _canSolveWith(Board board, Difficulty difficulty) =>
      _canSolveCellCodesWith(board.size, cellCodesFromBoard(board), difficulty);

  bool _canSolveCellCodesWith(
    int size,
    List<int> cellCodes,
    Difficulty difficulty,
  ) {
    final engine = DeductionEngine(
      size,
      List.of(cellCodes),
      difficulty.allowedRules,
    );
    return engine.deduceUntilStuck() && engine.isComplete;
  }
}
