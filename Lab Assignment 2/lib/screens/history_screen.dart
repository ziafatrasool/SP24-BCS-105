import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/game_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<GameModel> gameList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    gameList = await DBHelper().getGames();
    setState(() {
      loading = false;
    });
  }

  Color _resultColor(String result) {
    if (result == 'Correct') return Colors.greenAccent.shade400;
    if (result == 'Too High') return Colors.orangeAccent.shade400;
    return Colors.redAccent.shade200;
  }

  String _formatTime(String rawTime) {
    try {
      final date = DateTime.parse(rawTime).toLocal();
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return rawTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF312E81), Color(0xFF0F172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  color: Colors.tealAccent,
                  backgroundColor: Colors.white12,
                  onRefresh: fetchData,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 255, 255, 0.10),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'All Guesses',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Total attempts: ${gameList.length}',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                              const Icon(Icons.poll,
                                  color: Colors.white70, size: 30),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: gameList.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.history_toggle_off,
                                          color: Colors.white38, size: 60),
                                      SizedBox(height: 16),
                                      Text(
                                        'No history yet. Play a round to save guesses.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: gameList.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final game = gameList[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            255, 255, 255, 0.08),
                                        borderRadius: BorderRadius.circular(20),
                                        border:
                                            Border.all(color: Colors.white12),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              _resultColor(game.result),
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        title: Text(
                                          'Guess: ${game.guess}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          '${game.result} • ${_formatTime(game.time)}',
                                          style: const TextStyle(
                                              color: Colors.white70),
                                        ),
                                        trailing: Icon(Icons.chevron_right,
                                            color: _resultColor(game.result)),
                                      ),
                                    );
                                  },
                                ),
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
