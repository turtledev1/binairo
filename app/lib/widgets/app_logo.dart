import 'package:flutter/material.dart';

import 'board_cell.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    final gap = size * 0.06;
    final tileSize = (size - gap) / 2;
    Widget tile(String digit, Color color) => Container(
      width: tileSize,
      height: tileSize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(tileSize * 0.2),
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: TextStyle(
          color: Colors.white,
          fontSize: tileSize * 0.6,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
    return SizedBox.square(
      dimension: size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              tile('0', BoardCell.zeroColor),
              tile('1', BoardCell.oneColor),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              tile('1', BoardCell.oneColor),
              tile('0', BoardCell.zeroColor),
            ],
          ),
        ],
      ),
    );
  }
}
