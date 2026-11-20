import 'package:binairo_core/binairo_core.dart';
import 'package:flutter/material.dart';

class BoardCell extends StatelessWidget {
  const BoardCell({
    super.key,
    required this.value,
    required this.isGiven,
    required this.isInViolation,
    required this.onTap,
  });

  static const Color zeroColor = Color(0xFFF4A259);
  static const Color oneColor = Color(0xFF3D7DD8);
  static const Color violationColor = Color(0xFFFF1744);
  static const double violationRingWidth = 2.5;

  final CellValue value;
  final bool isGiven;
  final bool isInViolation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = switch ((value, isGiven)) {
      (CellValue.empty, _) => colorScheme.surfaceContainerHighest,
      (_, true) => colorScheme.onSurfaceVariant,
      (CellValue.zero, false) => zeroColor,
      (CellValue.one, false) => oneColor,
    };
    final digitColor = isGiven ? colorScheme.surface : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(1.5),
        padding: EdgeInsets.all(isInViolation ? violationRingWidth : 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isInViolation
              ? Border.all(color: violationColor, width: violationRingWidth)
              : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(isInViolation ? 4 : 6),
          ),
          alignment: Alignment.center,
          child: value.isEmpty
              ? null
              : FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      value == CellValue.zero ? '0' : '1',
                      style: TextStyle(
                        color: digitColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
