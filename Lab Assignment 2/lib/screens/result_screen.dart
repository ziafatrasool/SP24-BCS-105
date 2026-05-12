import 'package:flutter/material.dart';
import 'history_screen.dart';

class ResultScreen extends StatelessWidget {
  final int guess;
  final String result;

  const ResultScreen({super.key, required this.guess, required this.result});

  @override
  Widget build(BuildContext context) {
    final bool success = result == 'Correct';
    final Color badgeColor =
        success ? Colors.greenAccent.shade400 : Colors.orangeAccent.shade200;

    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D4350), Color(0xFFA43931)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          success ? Icons.emoji_events : Icons.lightbulb,
                          size: 88,
                          color: badgeColor,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Your Guess: $guess',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          result,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          success
                              ? 'Perfect answer! Tap Try Again to guess a new number.'
                              : 'Not this time. Use the history page to improve your next guess.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.history, color: Colors.white),
                          label: const Text('History',
                              style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            side: const BorderSide(color: Colors.white70),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HistoryScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
