import 'dart:math';
import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/game_model.dart';
import 'result_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller = TextEditingController();
  int randomNumber = Random().nextInt(100) + 1;
  String feedbackText = 'Tap check to begin the game';

  Future<void> checkGuess() async {
    FocusScope.of(context).unfocus();

    if (controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a number')),
      );
      return;
    }

    int guess = int.tryParse(controller.text) ?? 0;

    if (guess < 1 || guess > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a value between 1 and 100')),
      );
      return;
    }

    String result;
    if (guess == randomNumber) {
      result = 'Correct';
    } else if (guess > randomNumber) {
      result = 'Too High';
    } else {
      result = 'Too Low';
    }

    setState(() {
      feedbackText = result;
    });

    try {
      await DBHelper().insertGame(
        GameModel(
          guess: guess,
          result: result,
          time: DateTime.now().toString(),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: ${error.toString()}')),
        );
      }
    }

    if (!mounted) return;

    controller.clear();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(guess: guess, result: result),
      ),
    );

    if (mounted && result == 'Correct') {
      setState(() {
        randomNumber = Random().nextInt(100) + 1;
        feedbackText = 'Nice! A new secret number is ready.';
      });
    }
  }

  void openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Guess Game'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View History',
            onPressed: openHistory,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Think Fast',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.12),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.remove_red_eye, color: Colors.white, size: 32),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Enter a number between 1 and 100, then press Check to see whether your guess is too high, too low, or perfect.',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: const Color.fromRGBO(255, 255, 255, 0.14),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Your Guess',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white12,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Enter your number',
                            hintStyle: TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(Icons.numbers,
                                color: Colors.white70),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('Check'),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.tealAccent.shade700,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: checkGuess,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.history,
                                    color: Colors.white),
                                label: const Text('History',
                                    style: TextStyle(color: Colors.white)),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  side: const BorderSide(color: Colors.white54),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: openHistory,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  feedbackText,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Pro Tip',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Focus on the range and use the history button to review previous guesses. Every attempt is a clue — make your next guess smarter.',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
