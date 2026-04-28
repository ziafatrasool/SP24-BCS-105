import 'package:flutter/material.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double height = 170;
  double weight = 70;

  void calculateBMI() {
    double heightInMeters = height / 100;
    double bmi = weight / (heightInMeters * heightInMeters);

    String category;

    if (bmi < 18.5) {
      category = "Underweight";
    } else if (bmi < 24.9) {
      category = "Normal";
    } else if (bmi < 29.9) {
      category = "Overweight";
    } else {
      category = "Obese";
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) =>
            ResultScreen(bmi: bmi, category: category),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  Widget glassCard({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "BMI Calculator",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 30),

            glassCard(
              child: Column(
                children: [
                  Text("Height: ${height.toInt()} cm",
                      style: TextStyle(color: Colors.white)),
                  Slider(
                    value: height,
                    min: 100,
                    max: 220,
                    activeColor: Colors.white,
                    onChanged: (value) {
                      setState(() => height = value);
                    },
                  ),
                ],
              ),
            ),

            glassCard(
              child: Column(
                children: [
                  Text("Weight: ${weight.toInt()} kg",
                      style: TextStyle(color: Colors.white)),
                  Slider(
                    value: weight,
                    min: 30,
                    max: 150,
                    activeColor: Colors.white,
                    onChanged: (value) {
                      setState(() => weight = value);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: calculateBMI,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(
                    horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text("Calculate"),
            ),
          ],
        ),
      ),
    );
  }
}