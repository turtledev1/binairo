import 'dart:io';
import 'dart:math';

import 'package:binairo_core/binairo_core.dart';

const String usage =
    'Usage: dart run binairo_core:generate_puzzle '
    '[--size 10] [--difficulty easy|hard] [--seed 42]';

void main(List<String> arguments) {
  final Map<String, String> options;
  try {
    options = _parseOptions(arguments);
  } on FormatException catch (error) {
    stderr
      ..writeln(error.message)
      ..writeln(usage);
    exitCode = 64;
    return;
  }

  final size = int.parse(options['size'] ?? '10');
  final difficulty = Difficulty.values.byName(options['difficulty'] ?? 'easy');
  final seedOption = options['seed'];
  final random = seedOption == null ? Random() : Random(int.parse(seedOption));

  final stopwatch = Stopwatch()..start();
  final puzzle = PuzzleGenerator(
    random: random,
  ).generate(size: size, difficulty: difficulty);
  stopwatch.stop();

  stdout
    ..writeln('Puzzle (${puzzle.givenBoard.filledCellCount} clues):')
    ..writeln(puzzle.givenBoard.toText())
    ..writeln()
    ..writeln('Solution:')
    ..writeln(puzzle.solutionBoard.toText())
    ..writeln()
    ..writeln('Generated in ${stopwatch.elapsedMilliseconds} ms.');
}

Map<String, String> _parseOptions(List<String> arguments) {
  const knownOptions = {'size', 'difficulty', 'seed'};
  final options = <String, String>{};
  for (var index = 0; index < arguments.length; index += 2) {
    final name = arguments[index].replaceFirst('--', '');
    if (!knownOptions.contains(name) || index + 1 >= arguments.length) {
      throw FormatException('Bad option: ${arguments[index]}');
    }
    options[name] = arguments[index + 1];
  }
  return options;
}
