import 'dart:math';

import 'board.dart';
import 'deduction_engine.dart';
import 'deduction_rule.dart';

class SolutionGridGenerator {
  SolutionGridGenerator(this._random);

  final Random _random;

  Board generate(int size) {
    final emptyBoard = Board.empty(size);
    final solvedCellCodes = _fillRandomly(size, cellCodesFromBoard(emptyBoard));
    if (solvedCellCodes == null) {
      throw StateError('No valid board exists for size $size.');
    }
    return boardFromCellCodes(size, solvedCellCodes);
  }

  List<int>? _fillRandomly(int size, List<int> cellCodes) {
    final engine = DeductionEngine(
      size,
      cellCodes,
      DeductionRule.values.toSet(),
    );
    if (!engine.deduceUntilStuck()) {
      return null;
    }
    final emptyCellIndexes = [
      for (var index = 0; index < cellCodes.length; index++)
        if (cellCodes[index] == emptyCellCode) index,
    ];
    if (emptyCellIndexes.isEmpty) {
      return cellCodes;
    }
    final chosenCellIndex =
        emptyCellIndexes[_random.nextInt(emptyCellIndexes.length)];
    final firstCodeToTry = _random.nextBool() ? oneCellCode : zeroCellCode;
    for (final code in [firstCodeToTry, 1 - firstCodeToTry]) {
      final cellCodesWithChoice = List.of(cellCodes);
      cellCodesWithChoice[chosenCellIndex] = code;
      final filled = _fillRandomly(size, cellCodesWithChoice);
      if (filled != null) {
        return filled;
      }
    }
    return null;
  }
}
