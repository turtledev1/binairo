import 'package:binairo_core/binairo_core.dart';
import 'package:test/test.dart';

void main() {
  Set<BinairoRule> brokenRules(String boardText) => {
    for (final violation in BoardValidator.findViolations(
      Board.parse(boardText),
    ))
      violation.brokenRule,
  };

  test('a correct full board has no violations and counts as solved', () {
    final board = Board.parse('0101\n1010\n0110\n1001');

    expect(BoardValidator.findViolations(board), isEmpty);
    expect(BoardValidator.isSolved(board), isTrue);
  });

  test('an empty board has no violations but is not solved', () {
    final board = Board.empty(6);

    expect(BoardValidator.findViolations(board), isEmpty);
    expect(BoardValidator.isSolved(board), isFalse);
  });

  test('three equal values in a row are reported with exactly those cells', () {
    final violations = BoardValidator.findViolations(
      Board.parse('111...\n......\n......\n......\n......\n......'),
    );

    expect(violations, hasLength(1));
    expect(violations.single.brokenRule, BinairoRule.noThreeInARow);
    expect(violations.single.cellsInvolved, {
      const CellPosition(0, 0),
      const CellPosition(0, 1),
      const CellPosition(0, 2),
    });
  });

  test('three equal values in a column are reported', () {
    expect(
      brokenRules('0...\n0...\n0...\n....'),
      contains(BinairoRule.noThreeInARow),
    );
  });

  test('a run of four equal values is reported once with all four cells', () {
    final violations = BoardValidator.findViolations(
      Board.parse('.0000.\n......\n......\n......\n......\n......'),
    ).where((violation) => violation.brokenRule == BinairoRule.noThreeInARow);

    expect(violations, hasLength(1));
    expect(violations.single.cellsInvolved, hasLength(4));
  });

  test('more than half of one value in a partly filled line is reported', () {
    expect(
      brokenRules(
        '1.1.1.11\n........\n........\n........\n........\n........\n........\n........',
      ),
      contains(BinairoRule.balancedLine),
    );
  });

  test('exactly half of one value in a partly filled line is allowed', () {
    expect(
      brokenRules(
        '1.1.1.1.\n........\n........\n........\n........\n........\n........\n........',
      ),
      isNot(contains(BinairoRule.balancedLine)),
    );
  });

  test('two identical full rows are reported with the cells of both rows', () {
    final violations = BoardValidator.findViolations(
      Board.parse('0110\n0110\n....\n....'),
    ).where((violation) => violation.brokenRule == BinairoRule.uniqueLines);

    expect(violations, hasLength(1));
    expect(violations.single.cellsInvolved, hasLength(8));
  });

  test('two identical full columns are reported', () {
    expect(
      brokenRules('00..\n11..\n11..\n00..'),
      contains(BinairoRule.uniqueLines),
    );
  });

  test('identical rows that are not yet full are not reported', () {
    expect(
      brokenRules('011.\n011.\n....\n....'),
      isNot(contains(BinairoRule.uniqueLines)),
    );
  });
}
