import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/images.dart';
import '../../providers/auth_provider.dart';
import '../../services/leaderboard_service.dart';
import '../../widgets/loading_animation.dart';
import '../../widgets/page_background.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final leaderboardService = LeaderboardService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AppImages.logo),
        ),
        title: const Text('Leaderboard'),
      ),
      body: PageBackground(
        child: FutureBuilder<List<dynamic>>(
          future: leaderboardService.getTopUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LoadingAnimation());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Unable to load leaderboard. ${snapshot.error}',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color ??
                            Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final topPlayers = snapshot.data ?? [];
            final currentRank = topPlayers.indexWhere(
                  (player) => player['id'] == authProvider.currentUser?.id,
                ) +
                1;
            final rankText = currentRank > 0 ? currentRank.toString() : '—';

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(22),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundImage: authProvider.avatarUrl.isNotEmpty
                              ? NetworkImage(authProvider.avatarUrl)
                              : const AssetImage(AppImages.avatar)
                                  as ImageProvider,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authProvider.displayName,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Rank #$rankText',
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${authProvider.points} XP',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'You',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Top Players',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...topPlayers.asMap().entries.map((entry) {
                    final rank = entry.key + 1;
                    final player = entry.value as Map<String, dynamic>;
                    final name = player['full_name']?.toString() ??
                        player['email']?.toString() ??
                        'Player';
                    final xp =
                        int.tryParse(player['points']?.toString() ?? '0') ?? 0;
                    final avatarUrl = player['avatar_url']?.toString() ?? '';
                    final isCurrent =
                        player['id'] == authProvider.currentUser?.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Colors.white.withOpacity(0.18)
                            : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isCurrent ? Colors.amber : Colors.white12,
                          width: isCurrent ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        leading: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundImage: avatarUrl.isNotEmpty
                                  ? NetworkImage(avatarUrl)
                                  : const AssetImage(AppImages.avatar)
                                      as ImageProvider,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: rank == 1
                                    ? Colors.amber
                                    : rank == 2
                                        ? Colors.grey.shade300
                                        : rank == 3
                                            ? Colors.deepOrangeAccent
                                            : Colors.black87,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                '#$rank',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            color: isCurrent
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark ? Colors.white70 : Colors.black54),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '$xp XP • Level ${player['level'] ?? 1}',
                          style: TextStyle(
                            color: isCurrent
                                ? (isDark ? Colors.white70 : Colors.black54)
                                : (isDark ? Colors.white54 : Colors.black45),
                          ),
                        ),
                        trailing: Container(
                          width: 76,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isCurrent ? Colors.amber : Colors.white10,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            xp.toString(),
                            style: TextStyle(
                              color: isCurrent
                                  ? Colors.black
                                  : (isDark ? Colors.white : Colors.black87),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Leaderboard Strategy',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '• Finish quizzes daily to grow XP faster.\n'
                          '• Keep a strong streak to stand out on the board.\n'
                          '• Use badges and bonuses to secure higher rank.',
                          style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
