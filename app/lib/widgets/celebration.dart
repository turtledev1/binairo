import 'dart:math';

import 'package:flutter/material.dart';

import 'board_cell.dart';

class CelebrationWave extends StatelessWidget {
  const CelebrationWave({
    super.key,
    required this.celebration,
    required this.row,
    required this.column,
    required this.boardSize,
    required this.child,
  });

  static const double waveTravelShare = 0.45;
  static const double popShare = 0.3;
  static const double popScaleIncrease = 0.18;

  final Animation<double> celebration;
  final int row;
  final int column;
  final int boardSize;
  final Widget child;

  double _popStrength(double celebrationProgress) {
    final waveArrival =
        (row + column) / (2 * (boardSize - 1)) * waveTravelShare;
    final popProgress = ((celebrationProgress - waveArrival) / popShare).clamp(
      0.0,
      1.0,
    );
    return sin(pi * popProgress);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: celebration,
      child: child,
      builder: (context, child) {
        final popStrength = _popStrength(celebration.value);
        if (popStrength == 0) {
          return child!;
        }
        return Transform.scale(
          scale: 1 + popScaleIncrease * popStrength,
          child: Container(
            foregroundDecoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5 * popStrength),
              borderRadius: BorderRadius.circular(8),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key, required this.celebration});

  static const int pieceCount = 140;

  final Animation<double> celebration;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  late final List<_ConfettiPiece> _pieces = _createPieces(Random());
  late final CurvedAnimation _celebrationAfterWaveStarts = CurvedAnimation(
    parent: widget.celebration,
    curve: const Interval(0.2, 1),
  );

  @override
  void dispose() {
    _celebrationAfterWaveStarts.dispose();
    super.dispose();
  }

  static List<_ConfettiPiece> _createPieces(Random random) {
    const colors = [
      BoardCell.zeroColor,
      BoardCell.oneColor,
      Color(0xFF4CD964),
      Color(0xFFFFD60A),
      Color(0xFFFF6FB5),
    ];
    return [
      for (var index = 0; index < ConfettiOverlay.pieceCount; index++)
        _ConfettiPiece(
          horizontalSpeed: (random.nextDouble() - 0.5) * 1.3,
          upwardSpeed: 0.5 + random.nextDouble() * 0.8,
          spinTurns: (random.nextDouble() - 0.5) * 6,
          width: 6 + random.nextDouble() * 8,
          height: 4 + random.nextDouble() * 5,
          color: colors[random.nextInt(colors.length)],
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ConfettiPainter(
          celebration: _celebrationAfterWaveStarts,
          pieces: _pieces,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _ConfettiPiece {
  const _ConfettiPiece({
    required this.horizontalSpeed,
    required this.upwardSpeed,
    required this.spinTurns,
    required this.width,
    required this.height,
    required this.color,
  });

  final double horizontalSpeed;
  final double upwardSpeed;
  final double spinTurns;
  final double width;
  final double height;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.celebration, required this.pieces})
    : super(repaint: celebration);

  static const double gravity = 1.7;
  static const double fadeOutStart = 0.75;

  final Animation<double> celebration;
  final List<_ConfettiPiece> pieces;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = celebration.value;
    if (progress == 0 || progress == 1) {
      return;
    }
    final opacity = progress < fadeOutStart
        ? 1.0
        : 1 - (progress - fadeOutStart) / (1 - fadeOutStart);
    final burstCenter = size.center(Offset.zero);
    final paint = Paint();
    for (final piece in pieces) {
      final position =
          burstCenter +
          Offset(
            piece.horizontalSpeed * progress * size.width,
            (-piece.upwardSpeed * progress + gravity * progress * progress) *
                size.height *
                0.6,
          );
      paint.color = piece.color.withValues(alpha: opacity);
      canvas
        ..save()
        ..translate(position.dx, position.dy)
        ..rotate(piece.spinTurns * 2 * pi * progress)
        ..drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.width,
            height: piece.height,
          ),
          paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.pieces != pieces || oldDelegate.celebration != celebration;
}
