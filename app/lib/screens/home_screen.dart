import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../game/game_controller.dart';
import '../game/game_options.dart';
import '../game/saved_game_repository.dart';
import '../widgets/app_logo.dart';
import '../widgets/new_game_sheet.dart';
import 'game_screen.dart';
import 'how_to_play_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AppServices _services;
  SavedGame? _savedGame;
  bool _isGenerating = false;
  bool _hasLoadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _services = AppScope.of(context);
    if (!_hasLoadedOnce) {
      _hasLoadedOnce = true;
      _loadSavedGame();
    }
  }

  Future<void> _loadSavedGame() async {
    final savedGame = await _services.savedGameRepository.load();
    if (mounted) {
      setState(() => _savedGame = savedGame);
    }
  }

  Future<void> _chooseAndStartNewGame() async {
    final settingsController = _services.settingsController;
    final choice = await showNewGameSheet(
      context,
      initialSize: settingsController.settings.lastBoardSize,
      initialDifficulty: settingsController.settings.lastDifficulty,
    );
    if (choice == null || !mounted) return;
    settingsController.update(
      (settings) => settings.copyWith(
        lastBoardSize: choice.size,
        lastDifficulty: choice.difficulty,
      ),
    );
    if (_savedGame != null && !await _confirmReplacingSavedGame()) return;

    setState(() => _isGenerating = true);
    final puzzle = await _services.puzzleFactory(
      choice.size,
      choice.difficulty,
    );
    if (!mounted) return;
    setState(() => _isGenerating = false);
    await _openGame(GameController(puzzle: puzzle));
  }

  Future<bool> _confirmReplacingSavedGame() async {
    final shouldReplace = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Start a new game?'),
        content: const Text('Your unfinished game will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Start new game'),
          ),
        ],
      ),
    );
    return shouldReplace == true;
  }

  Future<void> _openGame(GameController controller) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(controller: controller),
      ),
    );
    await _loadSavedGame();
  }

  void _openScreen(Widget screen) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final savedGame = _savedGame;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AppLogo(size: 112)),
                  const SizedBox(height: 24),
                  Text(
                    'Binairo',
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A logic puzzle of zeros and ones',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (savedGame != null) ...[
                    _ContinueCard(
                      savedGame: savedGame,
                      onTap: _isGenerating
                          ? null
                          : () => _openGame(
                              GameController(
                                puzzle: savedGame.puzzle,
                                currentBoard: savedGame.currentBoard,
                                elapsedBeforeThisSession: savedGame.elapsed,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      textStyle: textTheme.titleMedium,
                    ),
                    onPressed: _isGenerating ? null : _chooseAndStartNewGame,
                    icon: _isGenerating
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                    label: Text(
                      _isGenerating ? 'Making your puzzle…' : 'New game',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _HomeShortcut(
                        icon: Icons.school_outlined,
                        label: 'How to play',
                        onTap: () => _openScreen(const HowToPlayScreen()),
                      ),
                      const SizedBox(width: 12),
                      _HomeShortcut(
                        icon: Icons.bar_chart,
                        label: 'Statistics',
                        onTap: () => _openScreen(const StatisticsScreen()),
                      ),
                      const SizedBox(width: 12),
                      _HomeShortcut(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () => _openScreen(const SettingsScreen()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.savedGame, required this.onTap});

  final SavedGame savedGame;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final puzzle = savedGame.puzzle;
    final percentFilled = (savedGame.fillProgress * 100).round();
    return Card.filled(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.play_circle_fill, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Continue', style: textTheme.titleMedium),
                    Text(
                      '${puzzle.size}×${puzzle.size} · '
                      '${capitalize(puzzle.difficulty.name)} · '
                      '${formatElapsedTime(savedGame.elapsed)}',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: savedGame.fillProgress,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text('$percentFilled%', style: textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeShortcut extends StatelessWidget {
  const _HomeShortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card.outlined(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            child: Column(
              children: [
                Icon(icon),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
