import 'package:binairo_app/statistics/statistics_repository.dart';
import 'package:binairo_core/binairo_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a puzzle kind with no solves has zero count and no times', () async {
    final statistics = await StatisticsRepository().load(8, Difficulty.easy);

    expect(statistics.solvedCount, 0);
    expect(statistics.bestTime, isNull);
    expect(statistics.averageTime, isNull);
  });

  test('solves add up and keep the best and average time', () async {
    final repository = StatisticsRepository();

    await repository.recordSolve(
      8,
      Difficulty.easy,
      const Duration(seconds: 90),
    );
    await repository.recordSolve(
      8,
      Difficulty.easy,
      const Duration(seconds: 30),
    );
    await repository.recordSolve(
      8,
      Difficulty.easy,
      const Duration(seconds: 60),
    );
    final statistics = await repository.load(8, Difficulty.easy);

    expect(statistics.solvedCount, 3);
    expect(statistics.bestTime, const Duration(seconds: 30));
    expect(statistics.averageTime, const Duration(seconds: 60));
  });

  test('recording a solve tells whether it beat the best time', () async {
    final repository = StatisticsRepository();

    expect(
      await repository.recordSolve(
        6,
        Difficulty.hard,
        const Duration(seconds: 50),
      ),
      isTrue,
    );
    expect(
      await repository.recordSolve(
        6,
        Difficulty.hard,
        const Duration(seconds: 70),
      ),
      isFalse,
    );
    expect(
      await repository.recordSolve(
        6,
        Difficulty.hard,
        const Duration(seconds: 40),
      ),
      isTrue,
    );
  });

  test('each size and level keeps its own statistics', () async {
    final repository = StatisticsRepository();

    await repository.recordSolve(
      6,
      Difficulty.easy,
      const Duration(seconds: 10),
    );

    expect((await repository.load(6, Difficulty.hard)).solvedCount, 0);
    expect((await repository.load(8, Difficulty.easy)).solvedCount, 0);
  });

  test(
    'clearing removes statistics but leaves other saved data alone',
    () async {
      SharedPreferences.setMockInitialValues({'saved_game.difficulty': 'easy'});
      final repository = StatisticsRepository();
      await repository.recordSolve(
        6,
        Difficulty.easy,
        const Duration(seconds: 10),
      );

      await repository.clearAll();

      expect((await repository.load(6, Difficulty.easy)).solvedCount, 0);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('saved_game.difficulty'), 'easy');
    },
  );
}
