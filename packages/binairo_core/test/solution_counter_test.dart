import 'package:binairo_core/binairo_core.dart';
import 'package:test/test.dart';

void main() {
  test('a full valid board has exactly one solution', () {
    expect(
      SolutionCounter.countSolutions(Board.parse('0101\n1010\n0110\n1001')),
      1,
    );
  });

  test('a full board that breaks a rule has no solution', () {
    expect(
      SolutionCounter.countSolutions(Board.parse('0101\n0101\n1010\n1010')),
      0,
    );
  });

  test('an empty board has many solutions and counting stops at the limit', () {
    expect(
      SolutionCounter.countSolutions(Board.empty(6), stopCountingAt: 5),
      5,
    );
    expect(SolutionCounter.hasExactlyOneSolution(Board.empty(6)), isFalse);
  });

  test('the number of 4x4 solutions matches the known total of 72', () {
    expect(
      SolutionCounter.countSolutions(Board.empty(4), stopCountingAt: 1000),
      72,
    );
  });

  test('the number of 6x6 solutions matches the known total of 4140', () {
    expect(
      SolutionCounter.countSolutions(Board.empty(6), stopCountingAt: 100000),
      4140,
    );
  });

  test('a board with an unfillable line has no solution', () {
    expect(
      SolutionCounter.countSolutions(Board.parse('00..\n....\n00..\n....')),
      0,
    );
  });
}
