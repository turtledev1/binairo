import 'package:flutter/material.dart';

import 'game/saved_game_repository.dart';
import 'screens/new_game_screen.dart';

void main() {
  runApp(BinairoApp(savedGameRepository: SavedGameRepository()));
}

class BinairoApp extends StatelessWidget {
  const BinairoApp({super.key, required this.savedGameRepository});

  final SavedGameRepository savedGameRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Binairo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D7DD8)),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D7DD8),
          brightness: Brightness.dark,
        ),
      ),
      home: NewGameScreen(savedGameRepository: savedGameRepository),
    );
  }
}
