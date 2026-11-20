import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_services.dart';
import '../game/game_controller.dart';
import '../game/game_options.dart';
import '../game/saved_game_repository.dart';
import '../widgets/board_grid.dart';
import '../widgets/celebration.dart';
import 'how_to_play_screen.dart';
import 'settings_screen.dart';

enum _GameMenuAction { restart, howToPlay, settings }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  static const Duration celebrationDuration = Duration(milliseconds: 1800);

  late final AppLifecycleListener _appLifecycleListener;
  late final AnimationController _celebrationController = AnimationController(
    vsync: this,
    duration: celebrationDuration,
  );
  AppServices? _services;
  bool _hasCelebrated = false;

  GameController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onGameChanged);
    _appLifecycleListener = AppLifecycleListener(onPause: _saveProgress);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isFirstDependencyChange = _services == null;
    _services = AppScope.of(context);
    if (isFirstDependencyChange) {
      _saveProgress();
    }
  }

  @override
  void dispose() {
    _saveProgress();
    _appLifecycleListener.dispose();
    _celebrationController.dispose();
    _controller.removeListener(_onGameChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onGameChanged() {
    _saveProgress();
    if (_controller.isSolved && !_hasCelebrated) {
      _hasCelebrated = true;
      _celebrateThenShowSolvedDialog();
    }
  }

  Future<void> _celebrateThenShowSolvedDialog() async {
    final services = _services!;
    final solveTime = _controller.elapsed;
    final isNewBestTime = services.statisticsRepository.recordSolve(
      _controller.size,
      _controller.puzzle.difficulty,
      solveTime,
    );
    if (services.settingsController.settings.vibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
    await _celebrationController.forward();
    if (mounted) {
      await _showSolvedDialog(solveTime, await isNewBestTime);
    }
  }

  void _saveProgress() {
    final savedGameRepository = _services?.savedGameRepository;
    if (savedGameRepository == null) return;
    if (_controller.isSolved) {
      savedGameRepository.clear();
      return;
    }
    savedGameRepository.save(
      SavedGame(
        puzzle: _controller.puzzle,
        currentBoard: _controller.currentBoard,
        elapsed: _controller.elapsed,
      ),
    );
  }

  Future<void> _showSolvedDialog(Duration solveTime, bool isNewBestTime) async {
    if (!mounted) return;
    final startNewGame = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          isNewBestTime ? Icons.emoji_events : Icons.check_circle,
          size: 48,
        ),
        title: const Text('Solved!'),
        content: Text(
          isNewBestTime
              ? 'New best time: ${formatElapsedTime(solveTime)}'
              : 'Time: ${formatElapsedTime(solveTime)}',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Look at board'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Home'),
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

  void _onMenuSelected(_GameMenuAction action) {
    switch (action) {
      case _GameMenuAction.restart:
        _confirmRestart();
      case _GameMenuAction.howToPlay:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const HowToPlayScreen()),
        );
      case _GameMenuAction.settings:
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = _controller.puzzle;
    final settingsController = AppScope.of(context).settingsController;
    return ListenableBuilder(
      listenable: Listenable.merge([_controller, settingsController]),
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
            PopupMenuButton<_GameMenuAction>(
              tooltip: 'Menu',
              onSelected: _onMenuSelected,
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _GameMenuAction.restart,
                  enabled: _controller.canRestart,
                  child: const ListTile(
                    leading: Icon(Icons.restart_alt),
                    title: Text('Restart'),
                  ),
                ),
                const PopupMenuItem(
                  value: _GameMenuAction.howToPlay,
                  child: ListTile(
                    leading: Icon(Icons.school_outlined),
                    title: Text('How to play'),
                  ),
                ),
                const PopupMenuItem(
                  value: _GameMenuAction.settings,
                  child: ListTile(
                    leading: Icon(Icons.settings_outlined),
                    title: Text('Settings'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Stack(
              children: [
                Center(
                  child: BoardGrid(
                    controller: _controller,
                    celebration: _celebrationController,
                    showRuleErrors: settingsController.settings.showRuleErrors,
                    showLineCounters:
                        settingsController.settings.showLineCounters,
                    tapFeedbackEnabled:
                        settingsController.settings.vibrationEnabled,
                  ),
                ),
                Positioned.fill(
                  child: ConfettiOverlay(celebration: _celebrationController),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
