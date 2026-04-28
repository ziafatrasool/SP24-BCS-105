import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final double bmi;
  final String category;

  const ResultScreen({super.key, required this.bmi, required this.category});

  Color getColor() {
    if (category == "Underweight") return Colors.blue;
    if (category == "Normal") return Colors.green;
    if (category == "Overweight") return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>( // ✅ FIX HERE
            tween: Tween<double>(begin: 0, end: bmi),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value.toStringAsFixed(1), // ✅ no error now
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 26,
                      color: getColor(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Recalculate"),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}