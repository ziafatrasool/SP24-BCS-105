import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UltimateProfile(),
    );
  }
}

class UltimateProfile extends StatelessWidget {
  const UltimateProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f5f9),
      body: CustomScrollView(
        slivers: [
          // 🔥 APP BAR PROFILE (Premium Look)
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.deepPurple,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff5f2c82), Color(0xff49a09d)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    CircleAvatar(
                      radius: 55,
                      backgroundImage: NetworkImage(
                        "https://via.placeholder.com/150",
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Ziafat Rasool",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Senior Mobile App Developer",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 📄 BODY
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 🔗 Social Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      SocialIcon(Icons.link),
                      SocialIcon(Icons.code),
                      SocialIcon(Icons.email),
                      SocialIcon(Icons.phone),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 📞 Contact Card
                  sectionCard("Contact", const [
                    InfoTile(Icons.email, "ziafat@gmail.com"),
                    InfoTile(Icons.phone, "+92 300 1234567"),
                    InfoTile(Icons.location_on, "Faisalabad, Pakistan"),
                  ]),

                  // 💼 Experience
                  sectionCard("Experience", const [
                    InfoTile(Icons.work, "2+ Years Flutter App Development"),
                    InfoTile(Icons.rocket, "10+ Apps Completed"),
                  ]),

                  // 🎓 Education
                  sectionCard("Education", const [
                    InfoTile(Icons.school, "BS Computer Science"),
                  ]),

                  // 🧠 Skills with Progress
                  skillCard(),

                  // ❤️ Hobbies
                  sectionCard("Hobbies", const [
                    InfoTile(Icons.favorite, "Coding"),
                    InfoTile(Icons.sports_esports, "Gaming"),
                    InfoTile(Icons.music_note, "Music"),
                  ]),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Section Card
  static Widget sectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 14)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // 🔹 Skills Card with Progress Bars
  static Widget skillCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 14)],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Skills",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          SkillBar("Flutter", 0.9),
          SkillBar("Dart", 0.85),
          SkillBar("Firebase", 0.75),
          SkillBar("REST API", 0.8),
          SkillBar("UI/UX", 0.7),
        ],
      ),
    );
  }
}

// 🔹 Info Tile
class InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoTile(this.icon, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

// 🔹 Social Icon
class SocialIcon extends StatelessWidget {
  final IconData icon;
  const SocialIcon(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white,
      // backgroundImage: AssetImage('assests/ss.png'),
      child: Icon(icon, color: Colors.deepPurple),
    );
  }
}

// 🔹 Skill Progress Bar
class SkillBar extends StatelessWidget {
  final String skill;
  final double value;

  const SkillBar(this.skill, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(skill),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: value,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}
