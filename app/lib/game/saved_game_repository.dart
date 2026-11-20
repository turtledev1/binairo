import 'package:binairo_core/binairo_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedGame {
  const SavedGame({
    required this.puzzle,
    required this.currentBoard,
    required this.elapsed,
  });

  final Puzzle puzzle;
  final Board currentBoard;
  final Duration elapsed;
}

class SavedGameRepository {
  static const String _difficultyKey = 'saved_game.difficulty';
  static const String _givenBoardKey = 'saved_game.given_board';
  static const String _solutionBoardKey = 'saved_game.solution_board';
  static const String _currentBoardKey = 'saved_game.current_board';
  static const String _elapsedSecondsKey = 'saved_game.elapsed_seconds';

  Future<SavedGame?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final difficultyName = preferences.getString(_difficultyKey);
    final givenBoardText = preferences.getString(_givenBoardKey);
    final solutionBoardText = preferences.getString(_solutionBoardKey);
    final currentBoardText = preferences.getString(_currentBoardKey);
    if (difficultyName == null ||
        givenBoardText == null ||
        solutionBoardText == null ||
        currentBoardText == null) {
      return null;
    }
    try {
      return SavedGame(
        puzzle: Puzzle(
          difficulty: Difficulty.values.byName(difficultyName),
          givenBoard: Board.parse(givenBoardText),
          solutionBoard: Board.parse(solutionBoardText),
        ),
        currentBoard: Board.parse(currentBoardText),
        elapsed: Duration(seconds: preferences.getInt(_elapsedSecondsKey) ?? 0),
      );
    } on FormatException {
      await clear();
      return null;
    } on ArgumentError {
      await clear();
      return null;
    }
  }

  Future<void> save(SavedGame savedGame) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _difficultyKey,
      savedGame.puzzle.difficulty.name,
    );
    await preferences.setString(
      _givenBoardKey,
      savedGame.puzzle.givenBoard.toText(),
    );
    await preferences.setString(
      _solutionBoardKey,
      savedGame.puzzle.solutionBoard.toText(),
    );
    await preferences.setString(
      _currentBoardKey,
      savedGame.currentBoard.toText(),
    );
    await preferences.setInt(_elapsedSecondsKey, savedGame.elapsed.inSeconds);
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    for (final key in [
      _difficultyKey,
      _givenBoardKey,
      _solutionBoardKey,
      _currentBoardKey,
      _elapsedSecondsKey,
    ]) {
      await preferences.remove(key);
    }
  }
}
