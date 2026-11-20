import 'package:binairo_core/binairo_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PuzzleStatistics {
  const PuzzleStatistics({
    this.solvedCount = 0,
    this.bestTime,
    this.totalTime = Duration.zero,
  });

  final int solvedCount;
  final Duration? bestTime;
  final Duration totalTime;

  Duration? get averageTime =>
      solvedCount == 0 ? null : totalTime ~/ solvedCount;
}

class StatisticsRepository {
  static const String _keyPrefix = 'statistics';

  Future<PuzzleStatistics> load(int size, Difficulty difficulty) async {
    final preferences = await SharedPreferences.getInstance();
    final keys = _StatisticsKeys(size, difficulty);
    final bestSeconds = preferences.getInt(keys.bestSeconds);
    return PuzzleStatistics(
      solvedCount: preferences.getInt(keys.solvedCount) ?? 0,
      bestTime: bestSeconds == null ? null : Duration(seconds: bestSeconds),
      totalTime: Duration(seconds: preferences.getInt(keys.totalSeconds) ?? 0),
    );
  }

  /// Returns `true` when [solveTime] is the new best time.
  Future<bool> recordSolve(
    int size,
    Difficulty difficulty,
    Duration solveTime,
  ) async {
    final previous = await load(size, difficulty);
    final preferences = await SharedPreferences.getInstance();
    final keys = _StatisticsKeys(size, difficulty);
    final previousBest = previous.bestTime;
    final newBest = previousBest == null || solveTime < previousBest
        ? solveTime
        : previousBest;
    await preferences.setInt(keys.solvedCount, previous.solvedCount + 1);
    await preferences.setInt(keys.bestSeconds, newBest.inSeconds);
    await preferences.setInt(
      keys.totalSeconds,
      (previous.totalTime + solveTime).inSeconds,
    );
    return newBest == solveTime;
  }

  Future<void> clearAll() async {
    final preferences = await SharedPreferences.getInstance();
    final statisticsKeys = preferences.getKeys().where(
      (key) => key.startsWith('$_keyPrefix.'),
    );
    for (final key in statisticsKeys.toList()) {
      await preferences.remove(key);
    }
  }
}

class _StatisticsKeys {
  _StatisticsKeys(int size, Difficulty difficulty)
    : _base = '${StatisticsRepository._keyPrefix}.$size.${difficulty.name}';

  final String _base;

  String get solvedCount => '$_base.solved_count';
  String get bestSeconds => '$_base.best_seconds';
  String get totalSeconds => '$_base.total_seconds';
}
