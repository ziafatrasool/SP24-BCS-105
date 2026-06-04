import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../core/constants/images.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/page_background.dart';
import '../../widgets/xp_bar.dart';

import '../quiz/quiz_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../profile/profile_screen.dart';
import '../achievements/achievements_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum _HomeBoxType { welcome, streak, challenge, record }

class _HomeScreenState extends State<HomeScreen> {
  final List<_HomeBoxType> _boxOrder = [
    _HomeBoxType.welcome,
    _HomeBoxType.streak,
    _HomeBoxType.challenge,
    _HomeBoxType.record,
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(AppImages.logo),
          ),
          title: const Text("👑 SkillVerse Pro"),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
          ],
        ),
        body: PageBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 420;
                return SingleChildScrollView(
                  padding: EdgeInsets.all(isNarrow ? 12 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your dashboard',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.85) ??
                              Colors.black87,
                        ),
                      ),
                      SizedBox(height: isNarrow ? 16 : 20),
                      Column(
                        children: _boxOrder.map((type) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: GestureDetector(
                              onLongPress: () {
                                HapticFeedback.lightImpact();
                              },
                              child: _buildHomeBox(type, authProvider),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Quick Access",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: isNarrow ? 12 : 15),
                      isNarrow
                          ? Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const LeaderboardScreen(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.emoji_events),
                                    label: const Text("Leaderboard"),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AchievementsScreen(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.workspace_premium),
                                    label: const Text("Badges"),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const LeaderboardScreen(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.emoji_events),
                                    label: const Text("Leaderboard"),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AchievementsScreen(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.workspace_premium),
                                    label: const Text("Badges"),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                );
              },
            ),
          ),
        ));
  }

  Widget _buildHomeBox(_HomeBoxType type, AuthProvider authProvider) {
    switch (type) {
      case _HomeBoxType.welcome:
        final xpProgress = (authProvider.points % 500) / 500;
        final avatarImage = authProvider.avatarUrl.isNotEmpty
            ? NetworkImage(authProvider.avatarUrl) as ImageProvider
            : const AssetImage(AppImages.avatar) as ImageProvider;
        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: avatarImage,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Welcome to SkillVerse Pro",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(authProvider.displayName,
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 15),
              Text("Level ${authProvider.level}"),
              const SizedBox(height: 10),
              XPBar(value: xpProgress.clamp(0.0, 1.0)),
              const SizedBox(height: 8),
              Text("${authProvider.points} XP"),
            ],
          ),
        );
      case _HomeBoxType.streak:
        return GlassCard(
          child: Row(
            children: [
              const Icon(
                Icons.whatshot,
                size: 48,
                color: Colors.orange,
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Current Streak",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "🔥 ${authProvider.streak} Days",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      case _HomeBoxType.challenge:
        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "🎯 Daily Challenge",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text("10 Questions Available"),
              const SizedBox(height: 10),
              const Text("Reward: 150 XP"),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QuizScreen()),
                    );
                  },
                  child: const Text("Start Challenge"),
                ),
              ),
            ],
          ),
        );
      case _HomeBoxType.record:
        return GlassCard(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(authProvider.displayName),
                subtitle: Text(authProvider.email),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.emoji_events),
                title: const Text('XP'),
                trailing: Text('${authProvider.points}'),
              ),
              ListTile(
                leading: const Icon(Icons.local_fire_department),
                title: const Text('Streak'),
                trailing: Text('${authProvider.streak}'),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Solved'),
                trailing: Text('${authProvider.solved}'),
              ),
            ],
          ),
        );
    }
  }
}
