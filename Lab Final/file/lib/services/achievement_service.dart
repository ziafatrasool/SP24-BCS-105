class AchievementService {
  Future<List<Map<String, dynamic>>> getAchievements({
    required int solvedCount,
  }) async {
    final thresholds = [
      {
        'title': 'Beginner',
        'description': 'Solve 10 questions',
        'icon': '🥉',
        'threshold': 10
      },
      {
        'title': 'Skilled',
        'description': 'Solve 20 questions',
        'icon': '🏅',
        'threshold': 20
      },
      {
        'title': 'Pro',
        'description': 'Solve 50 questions',
        'icon': '🏆',
        'threshold': 50
      },
      {
        'title': 'Champion',
        'description': 'Solve 70 questions',
        'icon': '🥈',
        'threshold': 70
      },
      {
        'title': 'Expert',
        'description': 'Solve 100 questions',
        'icon': '🏅',
        'threshold': 100
      },
      {
        'title': 'Master',
        'description': 'Solve 120 questions',
        'icon': '🏆',
        'threshold': 120
      },
      {
        'title': 'Legend',
        'description': 'Solve 150 questions',
        'icon': '🥇',
        'threshold': 150
      },
    ];

    return thresholds.map((badge) {
      return {
        'title': badge['title'],
        'description': badge['description'],
        'icon': badge['icon'],
        'unlocked': solvedCount >= (badge['threshold'] as int),
      };
    }).toList();
  }
}
