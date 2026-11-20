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

  final CellValue value;
  final bool isGiven;
  final bool isInViolation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fillColor = switch (value) {
      CellValue.zero => zeroColor,
      CellValue.one => oneColor,
      CellValue.empty => colorScheme.surfaceContainerHighest,
    };
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: isGiven || value.isEmpty
              ? fillColor
              : fillColor.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(6),
          border: isInViolation
              ? Border.all(color: colorScheme.error, width: 3)
              : null,
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
                      color: Colors.white,
                      fontWeight: isGiven ? FontWeight.w900 : FontWeight.w400,
                      decoration: isGiven ? TextDecoration.underline : null,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
