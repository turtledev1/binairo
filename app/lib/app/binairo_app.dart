import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import 'app_services.dart';

class BinairoApp extends StatelessWidget {
  const BinairoApp({super.key, required this.services});

  static const Color brandColor = Color(0xFF3D7DD8);

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: services,
      child: ListenableBuilder(
        listenable: services.settingsController,
        builder: (context, _) => MaterialApp(
          title: 'Binairo',
          themeMode: services.settingsController.settings.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: brandColor),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: brandColor,
              brightness: Brightness.dark,
            ),
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
