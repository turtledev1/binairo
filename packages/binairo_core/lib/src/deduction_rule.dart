/// Deductions a person can make, ordered from simplest to hardest.
enum DeductionRule {
  /// `00_` or `_00` forces a `1` next to the pair.
  adjacentPair,

  /// `0_0` forces a `1` in the gap.
  gapBetweenTwo,

  /// A line that already has half its cells as `0` gets `1` everywhere else.
  lineCountComplete,

  /// A value is forced when every legal way to finish the line puts it there.
  lineCompletionLookahead,

  /// Like [lineCompletionLookahead], but also rejects completions that copy
  /// a full line in the same direction.
  duplicateLineElimination,
}
