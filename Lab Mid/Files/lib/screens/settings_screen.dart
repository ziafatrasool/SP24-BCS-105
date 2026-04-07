import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.controller,
    required this.settingsService,
  });

  final TaskController controller;
  final SettingsService settingsService;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFFEDF6FF), Color(0xFFF8F3FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
          children: <Widget>[
            Text(
              'Control Center',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Visual preferences, reminder behavior, and export actions all in one place.',
              style: TextStyle(color: Color(0xFF5E6A89)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFF102A43), Color(0xFF1F4E79)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Appearance', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 14),
                  SegmentedButton<ThemeMode>(
                    style: SegmentedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: Colors.white,
                      selectedBackgroundColor: const Color(0xFFBEE3F8),
                      selectedForegroundColor: const Color(0xFF102A43),
                    ),
                    segments: const <ButtonSegment<ThemeMode>>[
                      ButtonSegment(value: ThemeMode.system, label: Text('System')),
                      ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                      ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                    ],
                    selected: <ThemeMode>{settingsService.themeMode},
                    onSelectionChanged: (selection) {
                      settingsService.updateThemeMode(selection.first);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: _SquareSettingCard(
                    icon: Icons.notifications_active_outlined,
                    title: 'Alerts',
                    subtitle: settingsService.notificationSound == 'silent'
                        ? 'Silent reminders'
                        : 'Sound enabled',
                    child: SegmentedButton<String>(
                      segments: const <ButtonSegment<String>>[
                        ButtonSegment(value: 'default', label: Text('Sound')),
                        ButtonSegment(value: 'silent', label: Text('Silent')),
                      ],
                      selected: <String>{settingsService.notificationSound},
                      onSelectionChanged: (selection) {
                        settingsService.updateNotificationSound(selection.first);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SquareSettingCard(
                    icon: Icons.folder_zip_outlined,
                    title: 'Exports',
                    subtitle: 'Share your tasks',
                    child: Column(
                      children: <Widget>[
                        _CompactAction(
                          label: 'CSV',
                          onTap: controller.exportCsv,
                        ),
                        const SizedBox(height: 8),
                        _CompactAction(
                          label: 'PDF',
                          onTap: controller.exportPdf,
                        ),
                        const SizedBox(height: 8),
                        _CompactAction(
                          label: 'Email',
                          onTap: controller.exportEmail,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 26,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Export Deck',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 14),
                  _WideActionTile(
                    icon: Icons.table_chart_rounded,
                    title: 'Export CSV',
                    subtitle: 'Spreadsheet-friendly task list',
                    accent: const Color(0xFF0EA5E9),
                    onTap: controller.exportCsv,
                  ),
                  const SizedBox(height: 12),
                  _WideActionTile(
                    icon: Icons.picture_as_pdf_rounded,
                    title: 'Export PDF',
                    subtitle: 'Presentation-style report',
                    accent: const Color(0xFFEF4444),
                    onTap: controller.exportPdf,
                  ),
                  const SizedBox(height: 12),
                  _WideActionTile(
                    icon: Icons.email_outlined,
                    title: 'Email Summary',
                    subtitle: 'Open mail app with generated summary',
                    accent: const Color(0xFF8B5CF6),
                    onTap: controller.exportEmail,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SquareSettingCard extends StatelessWidget {
  const _SquareSettingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: const Color(0xFF1F4E79)),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Color(0xFF5E6A89))),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _CompactAction extends StatelessWidget {
  const _CompactAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}

class _WideActionTile extends StatelessWidget {
  const _WideActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: accent.withValues(alpha: 0.08),
          border: Border.all(color: accent.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF5E6A89))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}
