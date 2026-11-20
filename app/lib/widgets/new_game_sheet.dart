import 'package:binairo_core/binairo_core.dart';
import 'package:flutter/material.dart';

import '../game/game_options.dart';

typedef NewGameChoice = ({int size, Difficulty difficulty});

Future<NewGameChoice?> showNewGameSheet(
  BuildContext context, {
  required int initialSize,
  required Difficulty initialDifficulty,
}) => showModalBottomSheet<NewGameChoice>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => _NewGameSheet(
    initialSize: initialSize,
    initialDifficulty: initialDifficulty,
  ),
);

class _NewGameSheet extends StatefulWidget {
  const _NewGameSheet({
    required this.initialSize,
    required this.initialDifficulty,
  });

  final int initialSize;
  final Difficulty initialDifficulty;

  @override
  State<_NewGameSheet> createState() => _NewGameSheetState();
}

class _NewGameSheetState extends State<_NewGameSheet> {
  late int _selectedSize = widget.initialSize;
  late Difficulty _selectedDifficulty = widget.initialDifficulty;

  static String _describe(Difficulty difficulty) => switch (difficulty) {
    Difficulty.easy => 'Simple steps only: pairs, gaps and line counts.',
    Difficulty.hard => 'You need to look ahead to finish each line.',
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('New game', style: textTheme.headlineSmall),
            const SizedBox(height: 24),
            Text('Size', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: [
                for (final size in availableBoardSizes)
                  ButtonSegment(value: size, label: Text('$size×$size')),
              ],
              selected: {_selectedSize},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _selectedSize = selection.single),
            ),
            const SizedBox(height: 24),
            Text('Level', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<Difficulty>(
              segments: [
                for (final difficulty in Difficulty.values)
                  ButtonSegment(
                    value: difficulty,
                    label: Text(capitalize(difficulty.name)),
                  ),
              ],
              selected: {_selectedDifficulty},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _selectedDifficulty = selection.single),
            ),
            const SizedBox(height: 8),
            Text(_describe(_selectedDifficulty), style: textTheme.bodySmall),
            const SizedBox(height: 32),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: () => Navigator.of(
                context,
              ).pop((size: _selectedSize, difficulty: _selectedDifficulty)),
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
