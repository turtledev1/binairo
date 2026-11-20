import 'package:binairo_app/game/saved_game_repository.dart';
import 'package:binairo_core/binairo_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_puzzles.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('loading with nothing saved returns null', () async {
    expect(await SavedGameRepository().load(), isNull);
  });

  test(
    'a saved game loads back with the same puzzle, board and time',
    () async {
      final puzzle = fourByFourPuzzleMissingCells(const [CellPosition(0, 0)]);
      final repository = SavedGameRepository();

      await repository.save(
        SavedGame(
          puzzle: puzzle,
          currentBoard: puzzle.givenBoard.withCell(0, 0, CellValue.one),
          elapsed: const Duration(seconds: 75),
        ),
      );
      final loaded = await repository.load();

      expect(loaded!.puzzle.givenBoard, puzzle.givenBoard);
      expect(loaded.puzzle.solutionBoard, puzzle.solutionBoard);
      expect(loaded.puzzle.difficulty, Difficulty.easy);
      expect(loaded.currentBoard.cellAt(0, 0), CellValue.one);
      expect(loaded.elapsed, const Duration(seconds: 75));
    },
  );

  test('clearing removes the saved game', () async {
    final repository = SavedGameRepository();
    final puzzle = fourByFourPuzzleMissingCells(const []);
    await repository.save(
      SavedGame(
        puzzle: puzzle,
        currentBoard: puzzle.givenBoard,
        elapsed: Duration.zero,
      ),
    );

    await repository.clear();

    expect(await repository.load(), isNull);
  });

  test('a corrupt saved game is dropped instead of crashing the app', () async {
    SharedPreferences.setMockInitialValues({
      'saved_game.difficulty': 'easy',
      'saved_game.given_board': 'not a board',
      'saved_game.solution_board': '0101\n1010\n0110\n1001',
      'saved_game.current_board': '0101\n1010\n0110\n1001',
    });

    expect(await SavedGameRepository().load(), isNull);
  });
}
