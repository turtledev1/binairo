import 'package:binairo_core/binairo_core.dart';
import 'package:test/test.dart';

void main() {
  const fourByFourText = '01.1\n1..0\n....\n0011';

  test('parsing then printing a board gives back the same text', () {
    expect(Board.parse(fourByFourText).toText(), fourByFourText);
  });

  test('reads cells by row and column after parsing', () {
    final board = Board.parse(fourByFourText);

    expect(board.cellAt(0, 1), CellValue.one);
    expect(board.cellAt(1, 1), CellValue.empty);
    expect(board.row(3), [
      CellValue.zero,
      CellValue.zero,
      CellValue.one,
      CellValue.one,
    ]);
    expect(board.column(3), [
      CellValue.one,
      CellValue.zero,
      CellValue.empty,
      CellValue.one,
    ]);
  });

  test('withCell returns a new board and leaves the original unchanged', () {
    final original = Board.empty(4);

    final updated = original.withCell(2, 3, CellValue.one);

    expect(updated.cellAt(2, 3), CellValue.one);
    expect(original.cellAt(2, 3), CellValue.empty);
  });

  test('boards with the same cells are equal and share a hash code', () {
    expect(Board.parse(fourByFourText), Board.parse(fourByFourText));
    expect(
      Board.parse(fourByFourText).hashCode,
      Board.parse(fourByFourText).hashCode,
    );
  });

  test('counts filled cells and knows when the board is full', () {
    expect(Board.parse(fourByFourText).filledCellCount, 9);
    expect(Board.parse(fourByFourText).isFull, isFalse);
    expect(Board.parse('0101\n1010\n0110\n1001').isFull, isTrue);
  });

  test('rejects odd sizes and sizes outside the supported range', () {
    expect(() => Board.empty(5), throwsArgumentError);
    expect(() => Board.empty(2), throwsArgumentError);
    expect(() => Board.empty(18), throwsArgumentError);
  });

  test('rejects text with rows of different lengths or unknown characters', () {
    expect(() => Board.parse('01.\n1..0\n....\n0011'), throwsFormatException);
    expect(() => Board.parse('01x1\n1..0\n....\n0011'), throwsFormatException);
  });
}
