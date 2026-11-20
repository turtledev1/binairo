import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../widgets/app_logo.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = AppScope.of(context).settingsController;
    final textTheme = Theme.of(context).textTheme;
    Widget sectionTitle(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: settingsController,
        builder: (context, _) {
          final settings = settingsController.settings;
          return ListView(
            children: [
              sectionTitle('Appearance'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('Phone'),
                      icon: Icon(Icons.brightness_auto),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {settings.themeMode},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) => settingsController.update(
                    (current) => current.copyWith(themeMode: selection.single),
                  ),
                ),
              ),
              sectionTitle('Game'),
              SwitchListTile(
                title: const Text('Vibration'),
                subtitle: const Text(
                  'Buzz when you tap a cell and when you solve a puzzle',
                ),
                value: settings.vibrationEnabled,
                onChanged: (enabled) => settingsController.update(
                  (current) => current.copyWith(vibrationEnabled: enabled),
                ),
              ),
              SwitchListTile(
                title: const Text('Show rule errors'),
                subtitle: const Text('Red ring on cells that break a rule'),
                value: settings.showRuleErrors,
                onChanged: (enabled) => settingsController.update(
                  (current) => current.copyWith(showRuleErrors: enabled),
                ),
              ),
              SwitchListTile(
                title: const Text('Show counters'),
                subtitle: const Text(
                  '0s and 1s still missing in each row and column',
                ),
                value: settings.showLineCounters,
                onChanged: (enabled) => settingsController.update(
                  (current) => current.copyWith(showLineCounters: enabled),
                ),
              ),
              sectionTitle('About'),
              const AboutListTile(
                icon: Icon(Icons.info_outline),
                applicationName: 'Binairo',
                applicationIcon: AppLogo(size: 48),
              ),
            ],
          );
        },
      ),
    );
  }
}
