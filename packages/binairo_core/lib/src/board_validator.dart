import 'board.dart';
import 'cell_position.dart';
import 'cell_value.dart';

enum BinairoRule { noThreeInARow, balancedLine, uniqueLines }

class RuleViolation {
  const RuleViolation(this.brokenRule, this.cellsInvolved);

  final BinairoRule brokenRule;
  final Set<CellPosition> cellsInvolved;

  @override
  String toString() => 'RuleViolation($brokenRule, $cellsInvolved)';
}

abstract final class BoardValidator {
  static List<RuleViolation> findViolations(Board board) => [
    ..._findThreeInARowViolations(board),
    ..._findUnbalancedLineViolations(board),
    ..._findDuplicateLineViolations(board),
  ];

  static Set<CellPosition> findCellsInViolation(Board board) => {
    for (final violation in findViolations(board)) ...violation.cellsInvolved,
  };

  static bool isSolved(Board board) =>
      board.isFull && findViolations(board).isEmpty;

  static List<_Line> _allLines(Board board) => [
    for (var rowIndex = 0; rowIndex < board.size; rowIndex++)
      _Line.row(board, rowIndex),
    for (var columnIndex = 0; columnIndex < board.size; columnIndex++)
      _Line.column(board, columnIndex),
  ];

  static Iterable<RuleViolation> _findThreeInARowViolations(Board board) sync* {
    for (final line in _allLines(board)) {
      var runStart = 0;
      for (var position = 1; position <= board.size; position++) {
        final runContinues =
            position < board.size &&
            line.values[position].isFilled &&
            line.values[position] == line.values[runStart];
        if (runContinues) {
          continue;
        }
        final runLength = position - runStart;
        if (line.values[runStart].isFilled && runLength >= 3) {
          yield RuleViolation(BinairoRule.noThreeInARow, {
            for (
              var runPosition = runStart;
              runPosition < position;
              runPosition++
            )
              line.positions[runPosition],
          });
        }
        runStart = position;
      }
    }
  }

  static Iterable<RuleViolation> _findUnbalancedLineViolations(
    Board board,
  ) sync* {
    for (final line in _allLines(board)) {
      for (final value in [CellValue.zero, CellValue.one]) {
        final positionsWithValue = [
          for (var position = 0; position < board.size; position++)
            if (line.values[position] == value) line.positions[position],
        ];
        if (positionsWithValue.length > board.halfSize) {
          yield RuleViolation(
            BinairoRule.balancedLine,
            positionsWithValue.toSet(),
          );
        }
      }
    }
  }

  static Iterable<RuleViolation> _findDuplicateLineViolations(
    Board board,
  ) sync* {
    final rows = [
      for (var index = 0; index < board.size; index++) _Line.row(board, index),
    ];
    final columns = [
      for (var index = 0; index < board.size; index++)
        _Line.column(board, index),
    ];
    for (final linesOfOneDirection in [rows, columns]) {
      final completeLines = linesOfOneDirection
          .where((line) => line.isComplete)
          .toList();
      for (var first = 0; first < completeLines.length; first++) {
        for (var second = first + 1; second < completeLines.length; second++) {
          if (completeLines[first].hasSameValuesAs(completeLines[second])) {
            yield RuleViolation(BinairoRule.uniqueLines, {
              ...completeLines[first].positions,
              ...completeLines[second].positions,
            });
          }
        }
      }
    }
  }
}

class _Line {
  _Line(this.values, this.positions);

  factory _Line.row(Board board, int rowIndex) => _Line(board.row(rowIndex), [
    for (var column = 0; column < board.size; column++)
      CellPosition(rowIndex, column),
  ]);

  factory _Line.column(Board board, int columnIndex) => _Line(
    board.column(columnIndex),
    [for (var row = 0; row < board.size; row++) CellPosition(row, columnIndex)],
  );

  final List<CellValue> values;
  final List<CellPosition> positions;

  bool get isComplete => values.every((value) => value.isFilled);

  bool hasSameValuesAs(_Line other) {
    for (var position = 0; position < values.length; position++) {
      if (values[position] != other.values[position]) {
        return false;
      }
    }
    return true;
  }
}
