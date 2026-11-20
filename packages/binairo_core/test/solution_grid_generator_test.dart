import 'dart:math';

import 'package:binairo_core/binairo_core.dart';
import 'package:test/test.dart';

void main() {
  for (final size in [4, 6, 8, 10, 12, 14]) {
    test('generates a full valid board of size $size', () {
      final board = SolutionGridGenerator(Random(size)).generate(size);

      expect(board.size, size);
      expect(BoardValidator.isSolved(board), isTrue);
    });
  }

  test('the same seed gives the same board', () {
    expect(
      SolutionGridGenerator(Random(99)).generate(10),
      SolutionGridGenerator(Random(99)).generate(10),
    );
  });

  test('different seeds give different boards', () {
    expect(
      SolutionGridGenerator(Random(1)).generate(10),
      isNot(SolutionGridGenerator(Random(2)).generate(10)),
    );
  });
}
