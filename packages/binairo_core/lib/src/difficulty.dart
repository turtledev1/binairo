import 'deduction_rule.dart';

enum Difficulty {
  easy({
    DeductionRule.adjacentPair,
    DeductionRule.gapBetweenTwo,
    DeductionRule.lineCountComplete,
  }),
  hard({...DeductionRule.values});

  const Difficulty(this.allowedRules);

  final Set<DeductionRule> allowedRules;
}
