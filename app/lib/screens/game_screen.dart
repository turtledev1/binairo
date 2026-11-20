import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../game/saved_game_repository.dart';
import '../widgets/board_grid.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.controller,
    required this.savedGameRepository,
  });

  final GameController controller;
  final SavedGameRepository savedGameRepository;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final AppLifecycleListener _appLifecycleListener;
  bool _hasShownSolvedDialog = false;

  GameController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onGameChanged);
    _appLifecycleListener = AppLifecycleListener(onPause: _saveProgress);
    _saveProgress();
  }

  @override
  void dispose() {
    _saveProgress();
    _appLifecycleListener.dispose();
    _controller.removeListener(_onGameChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onGameChanged() {
    _saveProgress();
    if (_controller.isSolved && !_hasShownSolvedDialog) {
      _hasShownSolvedDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _showSolvedDialog());
    }
  }

  void _saveProgress() {
    if (_controller.isSolved) {
      widget.savedGameRepository.clear();
      return;
    }
    widget.savedGameRepository.save(
      SavedGame(
        puzzle: _controller.puzzle,
        currentBoard: _controller.currentBoard,
        elapsed: _controller.elapsed,
      ),
    );
  }

  Future<void> _showSolvedDialog() async {
    final startNewGame = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Solved!'),
        content: Text('Time: ${formatElapsedTime(_controller.elapsed)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Look at board'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('New game'),
          ),
        ],
      ),
    );
    if (startNewGame == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmRestart() async {
    final shouldRestart = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restart puzzle?'),
        content: const Text('This clears all your moves.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Restart'),
          ),
        ],
      ),
    );
    if (shouldRestart == true) {
      _controller.restart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = _controller.puzzle;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(
            '${puzzle.size}×${puzzle.size} · ${capitalize(puzzle.difficulty.name)}',
          ),
          actions: [
            IconButton(
              tooltip: 'Undo',
              icon: const Icon(Icons.undo),
              onPressed: _controller.canUndo ? _controller.undo : null,
            ),
            IconButton(
              tooltip: 'Restart',
              icon: const Icon(Icons.restart_alt),
              onPressed: _controller.canRestart ? _confirmRestart : null,
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Center(child: BoardGrid(controller: _controller)),
          ),
        ),
      ),
    );
  }
}

String formatElapsedTime(Duration elapsed) {
  final minutes = elapsed.inMinutes;
  final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String capitalize(String word) =>
    word.isEmpty ? word : word[0].toUpperCase() + word.substring(1);
