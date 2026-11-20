import 'board.dart';
import 'deduction_engine.dart';
import 'deduction_rule.dart';

abstract final class SolutionCounter {
  static int countSolutions(Board board, {int stopCountingAt = 2}) =>
      _countSolutions(board.size, cellCodesFromBoard(board), stopCountingAt);

  static bool hasExactlyOneSolution(Board board) =>
      countSolutions(board, stopCountingAt: 2) == 1;

  static int _countSolutions(
    int size,
    List<int> cellCodes,
    int stopCountingAt,
  ) {
    final engine = DeductionEngine(
      size,
      cellCodes,
      DeductionRule.values.toSet(),
    );
    if (!engine.deduceUntilStuck()) {
      return 0;
    }
    final firstEmptyCellIndex = cellCodes.indexOf(emptyCellCode);
    if (firstEmptyCellIndex == -1) {
      return 1;
    }
    var solutionsFound = 0;
    for (final guessedCode in [zeroCellCode, oneCellCode]) {
      final cellCodesWithGuess = List.of(cellCodes);
      cellCodesWithGuess[firstEmptyCellIndex] = guessedCode;
      solutionsFound += _countSolutions(
        size,
        cellCodesWithGuess,
        stopCountingAt - solutionsFound,
      );
      if (solutionsFound >= stopCountingAt) {
        break;
      }
    }
    return solutionsFound;
  }
}
