import 'cell_position.dart';
import 'cell_value.dart';

class Board {
  Board._(this.size, List<CellValue> cells) : _cells = List.unmodifiable(cells);

  factory Board.empty(int size) {
    _throwIfSizeIsUnsupported(size);
    return Board._(size, List.filled(size * size, CellValue.empty));
  }

  factory Board.fromCells(int size, List<CellValue> cells) {
    _throwIfSizeIsUnsupported(size);
    if (cells.length != size * size) {
      throw ArgumentError(
        'A board of size $size needs ${size * size} cells, got ${cells.length}.',
      );
    }
    return Board._(size, cells);
  }

  /// One row per line; cells are `0`, `1`, or `.` for empty.
  factory Board.parse(String text) {
    final rows = text
        .split('\n')
        .map((row) => row.trim())
        .where((row) => row.isNotEmpty)
        .toList();
    final size = rows.length;
    final cells = <CellValue>[];
    for (final row in rows) {
      if (row.length != size) {
        throw FormatException('Every row must have $size cells.', row);
      }
      for (final character in row.split('')) {
        cells.add(switch (character) {
          '0' => CellValue.zero,
          '1' => CellValue.one,
          '.' => CellValue.empty,
          _ => throw FormatException('Unknown cell character.', character),
        });
      }
    }
    return Board.fromCells(size, cells);
  }

  static const int smallestSupportedSize = 4;
  static const int largestSupportedSize = 16;

  final int size;
  final List<CellValue> _cells;

  List<CellValue> get cells => _cells;

  int get halfSize => size ~/ 2;

  CellValue cellAt(int row, int column) => _cells[row * size + column];

  CellValue cellAtPosition(CellPosition position) =>
      cellAt(position.row, position.column);

  Board withCell(int row, int column, CellValue value) {
    final updatedCells = List.of(_cells);
    updatedCells[row * size + column] = value;
    return Board._(size, updatedCells);
  }

  List<CellValue> row(int rowIndex) =>
      _cells.sublist(rowIndex * size, rowIndex * size + size);

  List<CellValue> column(int columnIndex) => [
    for (var rowIndex = 0; rowIndex < size; rowIndex++)
      cellAt(rowIndex, columnIndex),
  ];

  bool get isFull => _cells.every((cell) => cell.isFilled);

  int get filledCellCount => _cells.where((cell) => cell.isFilled).length;

  String toText() {
    final buffer = StringBuffer();
    for (var rowIndex = 0; rowIndex < size; rowIndex++) {
      for (final cell in row(rowIndex)) {
        buffer.write(switch (cell) {
          CellValue.zero => '0',
          CellValue.one => '1',
          CellValue.empty => '.',
        });
      }
      if (rowIndex < size - 1) {
        buffer.write('\n');
      }
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is Board &&
      other.size == size &&
      _cellsAreEqual(other._cells, _cells);

  @override
  int get hashCode => Object.hash(size, Object.hashAll(_cells));

  @override
  String toString() => toText();

  static bool _cellsAreEqual(List<CellValue> first, List<CellValue> second) {
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) {
        return false;
      }
    }
    return true;
  }

  static void _throwIfSizeIsUnsupported(int size) {
    if (size.isOdd ||
        size < smallestSupportedSize ||
        size > largestSupportedSize) {
      throw ArgumentError.value(
        size,
        'size',
        'Must be even and between $smallestSupportedSize and $largestSupportedSize.',
      );
    }
  }
}
