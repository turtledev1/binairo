import 'board.dart';
import 'cell_value.dart';
import 'deduction_rule.dart';

const int emptyCellCode = -1;
const int zeroCellCode = 0;
const int oneCellCode = 1;

List<int> cellCodesFromBoard(Board board) => [
  for (final cell in board.cells)
    switch (cell) {
      CellValue.empty => emptyCellCode,
      CellValue.zero => zeroCellCode,
      CellValue.one => oneCellCode,
    },
];

Board boardFromCellCodes(int size, List<int> cellCodes) =>
    Board.fromCells(size, [
      for (final code in cellCodes)
        switch (code) {
          zeroCellCode => CellValue.zero,
          oneCellCode => CellValue.one,
          _ => CellValue.empty,
        },
    ]);

class DeductionEngine {
  DeductionEngine(this.size, this.cellCodes, Set<DeductionRule> allowedRules)
    : _orderedAllowedRules = DeductionRule.values
          .where(allowedRules.contains)
          .toList(),
      _legalLineMasks = legalLineMasksForSize(size),
      _fullLineMask = (1 << size) - 1;

  final int size;
  final List<int> cellCodes;
  final List<DeductionRule> _orderedAllowedRules;
  final List<int> _legalLineMasks;
  final int _fullLineMask;
  bool _hasFoundContradiction = false;

  int get _halfSize => size ~/ 2;

  int get _lineCount => size * 2;

  bool get isComplete => !cellCodes.contains(emptyCellCode);

  /// Returns `false` when the cells break a Binairo rule.
  bool deduceUntilStuck() {
    var someRuleMadeProgress = true;
    while (someRuleMadeProgress && !_hasFoundContradiction) {
      someRuleMadeProgress = false;
      for (final rule in _orderedAllowedRules) {
        final ruleFilledCells = _applyRuleOnEveryLine(rule);
        if (_hasFoundContradiction) {
          return false;
        }
        if (ruleFilledCells) {
          someRuleMadeProgress = true;
          break;
        }
      }
    }
    return !_hasFoundContradiction;
  }

  bool _applyRuleOnEveryLine(DeductionRule rule) {
    var anyCellFilled = false;
    for (var lineIndex = 0; lineIndex < _lineCount; lineIndex++) {
      final lineCellFilled = switch (rule) {
        DeductionRule.adjacentPair => _applyAdjacentPair(lineIndex),
        DeductionRule.gapBetweenTwo => _applyGapBetweenTwo(lineIndex),
        DeductionRule.lineCountComplete => _applyLineCountComplete(lineIndex),
        DeductionRule.lineCompletionLookahead => _applyLineCompletion(
          lineIndex,
          rejectCopiesOfFullLines: false,
        ),
        DeductionRule.duplicateLineElimination => _applyLineCompletion(
          lineIndex,
          rejectCopiesOfFullLines: true,
        ),
      };
      if (_hasFoundContradiction) {
        return false;
      }
      anyCellFilled = anyCellFilled || lineCellFilled;
    }
    return anyCellFilled;
  }

  int _cellIndex(int lineIndex, int position) => lineIndex < size
      ? lineIndex * size + position
      : position * size + (lineIndex - size);

  int _codeAt(int lineIndex, int position) =>
      cellCodes[_cellIndex(lineIndex, position)];

  bool _assign(int lineIndex, int position, int code) {
    final cellIndex = _cellIndex(lineIndex, position);
    final currentCode = cellCodes[cellIndex];
    if (currentCode == emptyCellCode) {
      cellCodes[cellIndex] = code;
      return true;
    }
    if (currentCode != code) {
      _hasFoundContradiction = true;
    }
    return false;
  }

  bool _applyAdjacentPair(int lineIndex) {
    var anyCellFilled = false;
    for (var position = 0; position < size - 1; position++) {
      final code = _codeAt(lineIndex, position);
      if (code == emptyCellCode || code != _codeAt(lineIndex, position + 1)) {
        continue;
      }
      if (position > 0) {
        anyCellFilled =
            _assign(lineIndex, position - 1, 1 - code) || anyCellFilled;
      }
      if (position + 2 < size) {
        anyCellFilled =
            _assign(lineIndex, position + 2, 1 - code) || anyCellFilled;
      }
      if (_hasFoundContradiction) {
        return false;
      }
    }
    return anyCellFilled;
  }

  bool _applyGapBetweenTwo(int lineIndex) {
    var anyCellFilled = false;
    for (var position = 0; position < size - 2; position++) {
      final code = _codeAt(lineIndex, position);
      if (code == emptyCellCode || code != _codeAt(lineIndex, position + 2)) {
        continue;
      }
      anyCellFilled =
          _assign(lineIndex, position + 1, 1 - code) || anyCellFilled;
      if (_hasFoundContradiction) {
        return false;
      }
    }
    return anyCellFilled;
  }

  bool _applyLineCountComplete(int lineIndex) {
    var numberOfZeros = 0;
    var numberOfOnes = 0;
    for (var position = 0; position < size; position++) {
      final code = _codeAt(lineIndex, position);
      if (code == zeroCellCode) numberOfZeros++;
      if (code == oneCellCode) numberOfOnes++;
    }
    if (numberOfZeros > _halfSize || numberOfOnes > _halfSize) {
      _hasFoundContradiction = true;
      return false;
    }
    final int? codeForEmptyCells;
    if (numberOfZeros == _halfSize && numberOfOnes < _halfSize) {
      codeForEmptyCells = oneCellCode;
    } else if (numberOfOnes == _halfSize && numberOfZeros < _halfSize) {
      codeForEmptyCells = zeroCellCode;
    } else {
      codeForEmptyCells = null;
    }
    if (codeForEmptyCells == null) {
      return false;
    }
    for (var position = 0; position < size; position++) {
      if (_codeAt(lineIndex, position) == emptyCellCode) {
        _assign(lineIndex, position, codeForEmptyCells);
      }
    }
    return true;
  }

  bool _applyLineCompletion(
    int lineIndex, {
    required bool rejectCopiesOfFullLines,
  }) {
    final (:filledMask, :onesMask) = _lineMasks(lineIndex);
    final lineIsComplete = filledMask == _fullLineMask;
    if (lineIsComplete) {
      if (rejectCopiesOfFullLines &&
          _isCopyOfAnotherFullLine(lineIndex, onesMask)) {
        _hasFoundContradiction = true;
      }
      return false;
    }
    final fullLinesInSameDirection = rejectCopiesOfFullLines
        ? _fullLineMasksInSameDirectionAs(lineIndex)
        : const <int>{};

    var positionsOneInEveryCompletion = _fullLineMask;
    var positionsZeroInEveryCompletion = _fullLineMask;
    var numberOfCompletions = 0;
    for (final candidate in _legalLineMasks) {
      final matchesFilledCells = (candidate ^ onesMask) & filledMask == 0;
      if (!matchesFilledCells || fullLinesInSameDirection.contains(candidate)) {
        continue;
      }
      numberOfCompletions++;
      positionsOneInEveryCompletion &= candidate;
      positionsZeroInEveryCompletion &= ~candidate & _fullLineMask;
    }
    if (numberOfCompletions == 0) {
      _hasFoundContradiction = true;
      return false;
    }

    var anyCellFilled = false;
    final emptyMask = ~filledMask & _fullLineMask;
    for (var position = 0; position < size; position++) {
      final positionBit = 1 << position;
      if (emptyMask & positionBit == 0) continue;
      if (positionsOneInEveryCompletion & positionBit != 0) {
        anyCellFilled =
            _assign(lineIndex, position, oneCellCode) || anyCellFilled;
      } else if (positionsZeroInEveryCompletion & positionBit != 0) {
        anyCellFilled =
            _assign(lineIndex, position, zeroCellCode) || anyCellFilled;
      }
    }
    return anyCellFilled;
  }

  ({int filledMask, int onesMask}) _lineMasks(int lineIndex) {
    var filledMask = 0;
    var onesMask = 0;
    for (var position = 0; position < size; position++) {
      final code = _codeAt(lineIndex, position);
      if (code == emptyCellCode) continue;
      filledMask |= 1 << position;
      if (code == oneCellCode) onesMask |= 1 << position;
    }
    return (filledMask: filledMask, onesMask: onesMask);
  }

  Set<int> _fullLineMasksInSameDirectionAs(int lineIndex) {
    final firstLineOfDirection = lineIndex < size ? 0 : size;
    final fullLineMasks = <int>{};
    for (
      var otherLine = firstLineOfDirection;
      otherLine < firstLineOfDirection + size;
      otherLine++
    ) {
      final (:filledMask, :onesMask) = _lineMasks(otherLine);
      if (filledMask == _fullLineMask) {
        fullLineMasks.add(onesMask);
      }
    }
    return fullLineMasks;
  }

  bool _isCopyOfAnotherFullLine(int lineIndex, int onesMask) {
    final firstLineOfDirection = lineIndex < size ? 0 : size;
    for (
      var otherLine = firstLineOfDirection;
      otherLine < firstLineOfDirection + size;
      otherLine++
    ) {
      if (otherLine == lineIndex) continue;
      final otherMasks = _lineMasks(otherLine);
      if (otherMasks.filledMask == _fullLineMask &&
          otherMasks.onesMask == onesMask) {
        return true;
      }
    }
    return false;
  }
}

final Map<int, List<int>> _legalLineMasksBySize = {};

/// Every full line of [size] cells that is balanced and has no three in a row.
List<int> legalLineMasksForSize(int size) =>
    _legalLineMasksBySize.putIfAbsent(size, () {
      final halfSize = size ~/ 2;
      return [
        for (var mask = 0; mask < 1 << size; mask++)
          if (_countOneBits(mask) == halfSize &&
              !_hasThreeEqualInARow(mask, size))
            mask,
      ];
    });

int _countOneBits(int mask) {
  var count = 0;
  for (var remaining = mask; remaining != 0; remaining &= remaining - 1) {
    count++;
  }
  return count;
}

bool _hasThreeEqualInARow(int mask, int size) {
  for (var position = 0; position + 2 < size; position++) {
    final threeBits = (mask >> position) & 0x7;
    if (threeBits == 0x7 || threeBits == 0x0) {
      return true;
    }
  }
  return false;
}
