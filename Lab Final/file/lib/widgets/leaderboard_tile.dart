import 'package:flutter/material.dart';

import '../core/constants/images.dart';

class LeaderboardTile extends StatelessWidget {
  final String name;
  final int points;

  const LeaderboardTile({super.key, required this.name, required this.points});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: const AssetImage(AppImages.avatar) as ImageProvider,
      ),
      title: Text(name),
      trailing: Text("$points XP"),
    );
  }
}
