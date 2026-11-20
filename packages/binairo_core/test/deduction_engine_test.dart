import 'package:binairo_core/binairo_core.dart';
import 'package:binairo_core/src/deduction_engine.dart';
import 'package:test/test.dart';

void main() {
  List<Board> allFourByFourSolutions() {
    const legalLines = ['0011', '0101', '0110', '1001', '1010', '1100'];
    return [
      for (final first in legalLines)
        for (final second in legalLines)
          for (final third in legalLines)
            for (final fourth in legalLines)
              Board.parse('$first\n$second\n$third\n$fourth'),
    ].where(BoardValidator.isSolved).toList();
  }

  for (final rule in DeductionRule.values) {
    test('${rule.name} never fills a cell that disagrees with a real solution '
        'and never reports a false contradiction', () {
      for (final solution in allFourByFourSolutions()) {
        for (
          var keptCellsMask = 0;
          keptCellsMask < 1 << 16;
          keptCellsMask += 37
        ) {
          final cellCodes = cellCodesFromBoard(solution);
          for (var cellIndex = 0; cellIndex < 16; cellIndex++) {
            if (keptCellsMask & (1 << cellIndex) == 0) {
              cellCodes[cellIndex] = emptyCellCode;
            }
          }

          final hasNoContradiction = DeductionEngine(4, cellCodes, {
            rule,
          }).deduceUntilStuck();

          expect(hasNoContradiction, isTrue);
          final deducedBoard = boardFromCellCodes(4, cellCodes);
          for (var cellIndex = 0; cellIndex < 16; cellIndex++) {
            if (deducedBoard.cells[cellIndex].isFilled) {
              expect(deducedBoard.cells[cellIndex], solution.cells[cellIndex]);
            }
          }
        }
      }
    });
  }

  test(
    'legal lines of size 6 are the 14 balanced lines with no three in a row',
    () {
      expect(legalLineMasksForSize(6), hasLength(14));
    },
  );
}
