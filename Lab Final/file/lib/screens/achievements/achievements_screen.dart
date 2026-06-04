import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/images.dart';
import '../../providers/auth_provider.dart';
import '../../services/achievement_service.dart';
import '../../widgets/loading_animation.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final achievementService = AchievementService();

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AppImages.logo),
        ),
        title: const Text('🏅 Achievements'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: achievementService.getAchievements(
          solvedCount: authProvider.solved,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingAnimation());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '⚠️ Unable to load achievements',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.black87,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      snapshot.error.toString(),
                      style: TextStyle(
                          color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.7) ??
                              Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final achievements = snapshot.data ?? [];
          if (achievements.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No achievements available yet.',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color ??
                          Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Column(
            children: [
              const Center(
                child: Icon(
                  Icons.emoji_events,
                  size: 120,
                  color: Colors.amber,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final badge = achievements[index];
                    final icon = badge['icon']?.toString() ?? '🏅';
                    final title = badge['title']?.toString() ?? 'Achievement';
                    final description = badge['description']?.toString() ?? '';
                    final unlocked = badge['unlocked'] == true;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Text(
                          icon,
                          style: const TextStyle(fontSize: 30),
                        ),
                        title: Text(title),
                        subtitle: Text(description),
                        trailing: unlocked
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : const Icon(Icons.lock, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
