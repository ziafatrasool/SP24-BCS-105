import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/images.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/quiz_service.dart';
import '../../services/sound_service.dart';
import '../../widgets/page_background.dart';
import '../home/home_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score;

  final int totalQuestions;

  final int quizId;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.quizId,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  bool _rewarded = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _slideController.forward();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rewardUser();
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      if (settings.soundEnabled) {
        SoundService().playResult(settings.volume);
      }
    });
  }

  Future<void> _rewardUser() async {
    if (_rewarded) return;
    _rewarded = true;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    if (userId != null) {
      final correctAnswers = widget.score ~/ 10;
      await QuizService().submitResult(
        userId: userId,
        quizId: widget.quizId,
        score: widget.score,
        correctAnswers: correctAnswers,
      );
      await authProvider.addXp(widget.score);
      await authProvider.addSolvedQuestions(widget.totalQuestions);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int correctAnswers = widget.score ~/ 10;
    int wrongAnswers = widget.totalQuestions - correctAnswers;
    int xpEarned = widget.score * 10;

    final authProvider = Provider.of<AuthProvider>(context);
    final userAvatarImage = authProvider.avatarUrl.isNotEmpty
        ? NetworkImage(authProvider.avatarUrl)
        : const AssetImage(AppImages.avatar) as ImageProvider;

    final topPlayers = [2300, 2100, 1900];
    final totalXp = authProvider.points;
    final currentRank = topPlayers.where((xp) => xp > totalXp).length + 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Result"),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AppImages.logo),
        ),
      ),
      body: PageBackground(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0D47A1),
                      Color(0xFF1976D2),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success Animation
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: const Icon(
                          Icons.emoji_events,
                          size: 120,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Congratulations Text
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Text(
                          "Congratulations 🎉",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // User Avatar
                      SlideTransition(
                        position: _slideAnimation,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: userAvatarImage,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Score Card with Animation
                      SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade700
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Score",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withOpacity(0.8) ??
                                      Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "${widget.score} / ${widget.totalQuestions * 10}",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.color ??
                                      Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // XP and Rank Row
                      Row(
                        children: [
                          // XP Card
                          Expanded(
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.shade400,
                                      Colors.orange.shade700
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "XP Earned",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color
                                                ?.withOpacity(0.85) ??
                                            Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "+$xpEarned",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.color ??
                                            Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Rank Card
                          Expanded(
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red.shade400,
                                      Colors.red.shade700
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Your Rank",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color
                                                ?.withOpacity(0.85) ??
                                            Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "#$currentRank",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.color ??
                                            Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(76, 175, 80, 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.green,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Correct",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "$correctAnswers",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(244, 67, 54, 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.red,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Wrong",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "$wrongAnswers",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      Text(
                        "Total XP: ${authProvider.points}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color ??
                              Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Back to Home Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()),
                              (route) => false,
                            );
                          },
                          child: const Text("Back To Home"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
