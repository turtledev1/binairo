import 'dart:math';

import 'package:binairo_core/binairo_core.dart';
import 'package:test/test.dart';

void main() {
  void expectPuzzleIsFairAndUnique(Puzzle puzzle) {
    final givenBoard = puzzle.givenBoard;
    expect(BoardValidator.isSolved(puzzle.solutionBoard), isTrue);
    for (var row = 0; row < puzzle.size; row++) {
      for (var column = 0; column < puzzle.size; column++) {
        final givenCell = givenBoard.cellAt(row, column);
        if (givenCell.isFilled) {
          expect(givenCell, puzzle.solutionBoard.cellAt(row, column));
        }
      }
    }
    expect(SolutionCounter.hasExactlyOneSolution(givenBoard), isTrue);
    final logicalResult = LogicalSolver(
      puzzle.difficulty.allowedRules,
    ).solve(givenBoard);
    expect(logicalResult.isSolved, isTrue);
    expect(logicalResult.board, puzzle.solutionBoard);
  }

  for (final difficulty in Difficulty.values) {
    for (final size in [6, 8, 10, 12]) {
      test('a $size x $size ${difficulty.name} puzzle has one solution '
          'reachable with ${difficulty.name} deductions only', () {
        final puzzle = PuzzleGenerator(
          random: Random(size),
        ).generate(size: size, difficulty: difficulty);

        expect(puzzle.size, size);
        expect(puzzle.difficulty, difficulty);
        expectPuzzleIsFairAndUnique(puzzle);
      });
    }
  }

  test('a hard puzzle cannot be solved with easy deductions alone', () {
    final puzzle = PuzzleGenerator(
      random: Random(3),
    ).generate(size: 10, difficulty: Difficulty.hard);

    expect(
      LogicalSolver(
        Difficulty.easy.allowedRules,
      ).canSolveCompletely(puzzle.givenBoard),
      isFalse,
    );
  });

  test(
    'removing any one more clue from a puzzle makes it unsolvable at its level',
    () {
      final puzzle = PuzzleGenerator(
        random: Random(5),
      ).generate(size: 8, difficulty: Difficulty.easy);
      final solver = LogicalSolver(Difficulty.easy.allowedRules);

      for (var row = 0; row < 8; row++) {
        for (var column = 0; column < 8; column++) {
          if (puzzle.givenBoard.cellAt(row, column).isEmpty) continue;
          final boardWithOneLessClue = puzzle.givenBoard.withCell(
            row,
            column,
            CellValue.empty,
          );
          expect(solver.canSolveCompletely(boardWithOneLessClue), isFalse);
        }
      }
    },
  );

  test('the same seed gives the same puzzle', () {
    Puzzle generateWithSeed(int seed) => PuzzleGenerator(
      random: Random(seed),
    ).generate(size: 10, difficulty: Difficulty.hard);

    expect(generateWithSeed(42).givenBoard, generateWithSeed(42).givenBoard);
  });

  group('stress', tags: 'slow', () {
    for (final difficulty in Difficulty.values) {
      for (final size in [6, 8, 10, 12]) {
        test(
          '200 ${difficulty.name} $size x $size puzzles are all fair and unique',
          () {
            final generator = PuzzleGenerator(random: Random(1000 + size));
            for (var puzzleNumber = 0; puzzleNumber < 200; puzzleNumber++) {
              expectPuzzleIsFairAndUnique(
                generator.generate(size: size, difficulty: difficulty),
              );
            }
          },
        );
      }
    }
  });
}
