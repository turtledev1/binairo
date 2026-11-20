import 'dart:math';

import 'package:binairo_core/binairo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/game_controller.dart';
import 'board_cell.dart';
import 'celebration.dart';

/// Line counters sit right of each row and below each column, and show the
/// zeros and ones still missing in that line.
class BoardGrid extends StatelessWidget {
  const BoardGrid({
    super.key,
    required this.controller,
    this.celebration = kAlwaysDismissedAnimation,
    this.showRuleErrors = true,
    this.showLineCounters = true,
    this.tapFeedbackEnabled = false,
  });

  final GameController controller;
  final Animation<double> celebration;
  final bool showRuleErrors;
  final bool showLineCounters;
  final bool tapFeedbackEnabled;

  void _onCellTapped(int row, int column) {
    final cellCanChange =
        !controller.isSolved && !controller.isGivenCell(row, column);
    if (tapFeedbackEnabled && cellCanChange) {
      HapticFeedback.mediumImpact();
    }
    controller.tapCell(row, column);
  }

  @override
  Widget build(BuildContext context) {
    final size = controller.size;
    return LayoutBuilder(
      builder: (context, constraints) {
        final slotsPerSide = showLineCounters ? size + 1 : size;
        final slotSize =
            min(constraints.maxWidth, constraints.maxHeight) / slotsPerSide;
        return SizedBox.square(
          dimension: slotSize * slotsPerSide,
          child: Column(
            children: [
              for (var row = 0; row < size; row++)
                SizedBox(
                  height: slotSize,
                  child: Row(
                    children: [
                      for (var column = 0; column < size; column++)
                        SizedBox.square(
                          dimension: slotSize,
                          child: CelebrationWave(
                            celebration: celebration,
                            row: row,
                            column: column,
                            boardSize: size,
                            child: BoardCell(
                              key: ValueKey('cell-$row-$column'),
                              value: controller.currentBoard.cellAt(
                                row,
                                column,
                              ),
                              isGiven: controller.isGivenCell(row, column),
                              isInViolation:
                                  showRuleErrors &&
                                  controller.cellsInViolation.contains(
                                    CellPosition(row, column),
                                  ),
                              onTap: () => _onCellTapped(row, column),
                            ),
                          ),
                        ),
                      if (showLineCounters)
                        SizedBox.square(
                          dimension: slotSize,
                          child: _LineCounter(
                            key: ValueKey('row-counter-$row'),
                            zerosLeft: controller.zerosLeftInRow(row),
                            onesLeft: controller.onesLeftInRow(row),
                          ),
                        ),
                    ],
                  ),
                ),
              if (showLineCounters)
                SizedBox(
                  height: slotSize,
                  child: Row(
                    children: [
                      for (var column = 0; column < size; column++)
                        SizedBox.square(
                          dimension: slotSize,
                          child: _LineCounter(
                            key: ValueKey('column-counter-$column'),
                            zerosLeft: controller.zerosLeftInColumn(column),
                            onesLeft: controller.onesLeftInColumn(column),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LineCounter extends StatelessWidget {
  const _LineCounter({
    super.key,
    required this.zerosLeft,
    required this.onesLeft,
  });

  final int zerosLeft;
  final int onesLeft;

  @override
  Widget build(BuildContext context) {
    Text counterText(int valuesLeft, Color color) => Text(
      '$valuesLeft',
      style: TextStyle(
        color: valuesLeft < 0 ? BoardCell.violationColor : color,
        fontWeight: FontWeight.bold,
      ),
    );
    if (zerosLeft == 0 && onesLeft == 0) {
      return const Icon(Icons.check, color: Colors.green);
    }
    return FittedBox(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            counterText(zerosLeft, BoardCell.zeroColor),
            counterText(onesLeft, BoardCell.oneColor),
          ],
        ),
      ),
    );
  }
}
