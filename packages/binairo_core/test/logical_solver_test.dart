import 'package:binairo_core/binairo_core.dart';
import 'package:test/test.dart';

void main() {
  CellValue solveAndReadCell(
    String boardText,
    Set<DeductionRule> rules,
    int row,
    int column,
  ) => LogicalSolver(
    rules,
  ).solve(Board.parse(boardText)).board.cellAt(row, column);

  const emptyRowsOfSix = '......\n......\n......\n......\n......';

  test('adjacent pair forces the opposite value on both sides', () {
    final result = LogicalSolver({
      DeductionRule.adjacentPair,
    }).solve(Board.parse('..00..\n$emptyRowsOfSix'));

    expect(result.board.cellAt(0, 1), CellValue.one);
    expect(result.board.cellAt(0, 4), CellValue.one);
  });

  test('gap between two equal values is filled with the opposite value', () {
    expect(
      solveAndReadCell(
        '1.1...\n$emptyRowsOfSix',
        {DeductionRule.gapBetweenTwo},
        0,
        1,
      ),
      CellValue.zero,
    );
  });

  test('a line with half zeros gets ones in every empty cell', () {
    final result = LogicalSolver({
      DeductionRule.lineCountComplete,
    }).solve(Board.parse('0.0..0\n$emptyRowsOfSix'));

    expect(result.board.row(0), [
      CellValue.zero,
      CellValue.one,
      CellValue.zero,
      CellValue.one,
      CellValue.one,
      CellValue.zero,
    ]);
  });

  test('lookahead fills cells that simple rules cannot', () {
    const boardText = '0....0\n$emptyRowsOfSix';
    final simpleRulesBoard = LogicalSolver(
      Difficulty.easy.allowedRules,
    ).solve(Board.parse(boardText)).board;
    final lookaheadBoard = LogicalSolver({
      DeductionRule.lineCompletionLookahead,
    }).solve(Board.parse(boardText)).board;

    expect(simpleRulesBoard.filledCellCount, 2);
    expect(
      lookaheadBoard.row(0),
      Board.parse('01..10\n$emptyRowsOfSix').row(0),
    );
  });

  test(
    'duplicate line elimination rejects the completion that copies a full row',
    () {
      final board = Board.parse(
        '010101\n0101..\n......\n......\n......\n......',
      );
      final withoutDuplicateRule = LogicalSolver({
        DeductionRule.lineCompletionLookahead,
      }).solve(board);
      final withDuplicateRule = LogicalSolver({
        DeductionRule.duplicateLineElimination,
      }).solve(board);

      expect(withoutDuplicateRule.board.cellAt(1, 4), CellValue.empty);
      expect(withDuplicateRule.board.cellAt(1, 4), CellValue.one);
      expect(withDuplicateRule.board.cellAt(1, 5), CellValue.zero);
    },
  );

  test('reports a contradiction for a board that breaks a rule', () {
    final result = LogicalSolver(
      Difficulty.hard.allowedRules,
    ).solve(Board.parse('000...\n$emptyRowsOfSix'));

    expect(result.hasContradiction, isTrue);
    expect(result.isSolved, isFalse);
  });

  test('a solved result is always a valid full board', () {
    final puzzle = PuzzleGenerator().generate(
      size: 8,
      difficulty: Difficulty.hard,
    );

    final result = LogicalSolver(
      Difficulty.hard.allowedRules,
    ).solve(puzzle.givenBoard);

    expect(result.isSolved, isTrue);
    expect(BoardValidator.isSolved(result.board), isTrue);
  });
}
