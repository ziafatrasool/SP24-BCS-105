import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/images.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/loading_animation.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AppImages.logo),
        ),
        title: const Text('Settings'),
      ),
      body: !settings.initialized
          ? const Center(child: LoadingAnimation())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'App Settings',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: settings.notificationsEnabled,
                  title: const Text('Enable Notifications'),
                  onChanged: (value) {
                    settings.setNotificationsEnabled(value);
                  },
                ),
                SwitchListTile(
                  value: settings.themeMode == ThemeMode.dark,
                  title: const Text('Dark Mode'),
                  subtitle:
                      const Text('Choose between light and dark app style'),
                  onChanged: (value) {
                    settings
                        .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
                SwitchListTile(
                  value: settings.soundEnabled,
                  title: const Text('Enable Sound'),
                  onChanged: (value) {
                    settings.setSoundEnabled(value);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Sound Volume'),
                  subtitle: Slider(
                    value: settings.volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(settings.volume * 100).round()}%',
                    onChanged: settings.soundEnabled
                        ? (value) => settings.setVolume(value)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Your theme, sound, and notification settings are saved locally and applied instantly.',
                  style: TextStyle(
                      color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.85) ??
                          Colors.black87),
                ),
              ],
            ),
    );
  }
}
