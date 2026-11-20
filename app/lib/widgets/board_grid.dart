import 'dart:math';

import 'package:binairo_core/binairo_core.dart';
import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import 'board_cell.dart';
import 'celebration.dart';

/// The board, with a column of row counters on the right and a row of
/// column counters at the bottom. Each counter shows zeros and ones left.
class BoardGrid extends StatelessWidget {
  const BoardGrid({
    super.key,
    required this.controller,
    this.celebration = kAlwaysDismissedAnimation,
  });

  final GameController controller;
  final Animation<double> celebration;

  @override
  Widget build(BuildContext context) {
    final size = controller.size;
    return LayoutBuilder(
      builder: (context, constraints) {
        final slotsPerSide = size + 1;
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
                              isInViolation: controller.cellsInViolation
                                  .contains(CellPosition(row, column)),
                              onTap: () => controller.tapCell(row, column),
                            ),
                          ),
                        ),
                      SizedBox.square(
                        dimension: slotSize,
                        child: _LineCounter(
                          zerosLeft: controller.zerosLeftInRow(row),
                          onesLeft: controller.onesLeftInRow(row),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                height: slotSize,
                child: Row(
                  children: [
                    for (var column = 0; column < size; column++)
                      SizedBox.square(
                        dimension: slotSize,
                        child: _LineCounter(
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
  const _LineCounter({required this.zerosLeft, required this.onesLeft});

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
