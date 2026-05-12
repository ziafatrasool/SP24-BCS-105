import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game_model.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'game.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE game(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            guess INTEGER,
            result TEXT,
            time TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertGame(GameModel game) async {
    final db = await database;
    await db.insert('game', game.toMap());
  }

  Future<List<GameModel>> getGames() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'game',
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) {
      return GameModel.fromMap(maps[i]);
    });
  }
}
