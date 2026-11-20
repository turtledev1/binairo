import 'dart:isolate';

import 'package:binairo_core/binairo_core.dart';
import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../game/saved_game_repository.dart';
import 'game_screen.dart';

typedef PuzzleFactory =
    Future<Puzzle> Function(int size, Difficulty difficulty);

Future<Puzzle> generatePuzzleInBackground(int size, Difficulty difficulty) =>
    Isolate.run(
      () => PuzzleGenerator().generate(size: size, difficulty: difficulty),
    );

class NewGameScreen extends StatefulWidget {
  const NewGameScreen({
    super.key,
    required this.savedGameRepository,
    this.puzzleFactory = generatePuzzleInBackground,
  });

  static const List<int> availableSizes = [6, 8, 10, 12];

  final SavedGameRepository savedGameRepository;
  final PuzzleFactory puzzleFactory;

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  int _selectedSize = 8;
  Difficulty _selectedDifficulty = Difficulty.easy;
  bool _isGenerating = false;
  SavedGame? _savedGame;

  @override
  void initState() {
    super.initState();
    _loadSavedGame();
  }

  Future<void> _loadSavedGame() async {
    final savedGame = await widget.savedGameRepository.load();
    if (mounted) {
      setState(() => _savedGame = savedGame);
    }
  }

  Future<void> _startNewGame() async {
    setState(() => _isGenerating = true);
    final puzzle = await widget.puzzleFactory(
      _selectedSize,
      _selectedDifficulty,
    );
    if (!mounted) return;
    setState(() => _isGenerating = false);
    await _openGame(GameController(puzzle: puzzle));
  }

  Future<void> _continueSavedGame(SavedGame savedGame) => _openGame(
    GameController(
      puzzle: savedGame.puzzle,
      currentBoard: savedGame.currentBoard,
      elapsedBeforeThisSession: savedGame.elapsed,
    ),
  );

  Future<void> _openGame(GameController controller) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(
          controller: controller,
          savedGameRepository: widget.savedGameRepository,
        ),
      ),
    );
    await _loadSavedGame();
  }

  @override
  Widget build(BuildContext context) {
    final savedGame = _savedGame;
    return Scaffold(
      appBar: AppBar(title: const Text('Binairo')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (savedGame != null) ...[
                  FilledButton.tonalIcon(
                    onPressed: _isGenerating
                        ? null
                        : () => _continueSavedGame(savedGame),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      'Continue ${savedGame.puzzle.size}×${savedGame.puzzle.size} '
                      '${savedGame.puzzle.difficulty.name}',
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                Text('Size', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: [
                    for (final size in NewGameScreen.availableSizes)
                      ButtonSegment(value: size, label: Text('$size')),
                  ],
                  selected: {_selectedSize},
                  onSelectionChanged: _isGenerating
                      ? null
                      : (selection) =>
                            setState(() => _selectedSize = selection.single),
                ),
                const SizedBox(height: 24),
                Text('Level', style: Theme.of(context).textTheme.titleMedium),
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
                  onSelectionChanged: _isGenerating
                      ? null
                      : (selection) => setState(
                          () => _selectedDifficulty = selection.single,
                        ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _isGenerating ? null : _startNewGame,
                  child: _isGenerating
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('New game'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
