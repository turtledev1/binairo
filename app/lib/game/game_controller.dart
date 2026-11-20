import 'package:binairo_core/binairo_core.dart';
import 'package:flutter/foundation.dart';

class GameController extends ChangeNotifier {
  GameController({
    required this.puzzle,
    Board? currentBoard,
    this._elapsedBeforeThisSession = Duration.zero,
  }) : _currentBoard = currentBoard ?? puzzle.givenBoard {
    _refreshDerivedState();
    if (!_isSolved) {
      _sessionStopwatch.start();
    }
  }

  final Puzzle puzzle;
  final List<Board> _previousBoards = [];
  final Stopwatch _sessionStopwatch = Stopwatch();
  final Duration _elapsedBeforeThisSession;
  Board _currentBoard;
  Set<CellPosition> _cellsInViolation = const {};
  bool _isSolved = false;

  Board get currentBoard => _currentBoard;

  Set<CellPosition> get cellsInViolation => _cellsInViolation;

  bool get isSolved => _isSolved;

  bool get canUndo => _previousBoards.isNotEmpty && !_isSolved;

  int get size => puzzle.size;

  Duration get elapsed => _elapsedBeforeThisSession + _sessionStopwatch.elapsed;

  bool isGivenCell(int row, int column) =>
      puzzle.givenBoard.cellAt(row, column).isFilled;

  void tapCell(int row, int column) {
    if (_isSolved || isGivenCell(row, column)) {
      return;
    }
    final nextValue = _currentBoard.cellAt(row, column).nextInTapCycle;
    _previousBoards.add(_currentBoard);
    _currentBoard = _currentBoard.withCell(row, column, nextValue);
    _refreshDerivedState();
    notifyListeners();
  }

  void undo() {
    if (!canUndo) {
      return;
    }
    _currentBoard = _previousBoards.removeLast();
    _refreshDerivedState();
    notifyListeners();
  }

  void restart() {
    if (_isSolved || _currentBoard == puzzle.givenBoard) {
      return;
    }
    _previousBoards.add(_currentBoard);
    _currentBoard = puzzle.givenBoard;
    _refreshDerivedState();
    notifyListeners();
  }

  int zerosLeftInRow(int row) =>
      _valuesLeft(_currentBoard.row(row), CellValue.zero);

  int onesLeftInRow(int row) =>
      _valuesLeft(_currentBoard.row(row), CellValue.one);

  int zerosLeftInColumn(int column) =>
      _valuesLeft(_currentBoard.column(column), CellValue.zero);

  int onesLeftInColumn(int column) =>
      _valuesLeft(_currentBoard.column(column), CellValue.one);

  int _valuesLeft(List<CellValue> line, CellValue value) =>
      _currentBoard.halfSize - line.where((cell) => cell == value).length;

  void _refreshDerivedState() {
    _cellsInViolation = BoardValidator.findCellsInViolation(_currentBoard);
    _isSolved = _currentBoard.isFull && _cellsInViolation.isEmpty;
    if (_isSolved) {
      _sessionStopwatch.stop();
    }
  }

  @override
  void dispose() {
    _sessionStopwatch.stop();
    super.dispose();
  }
}
