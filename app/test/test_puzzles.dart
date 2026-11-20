import 'package:binairo_core/binairo_core.dart';

final Board fourByFourSolution = Board.parse('0101\n1010\n0110\n1001');

Puzzle fourByFourPuzzleMissingCells(List<CellPosition> missingCells) {
  var givenBoard = fourByFourSolution;
  for (final position in missingCells) {
    givenBoard = givenBoard.withCell(
      position.row,
      position.column,
      CellValue.empty,
    );
  }
  return Puzzle(
    difficulty: Difficulty.easy,
    givenBoard: givenBoard,
    solutionBoard: fourByFourSolution,
  );
}
