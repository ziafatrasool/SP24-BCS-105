import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/patient.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'doctor_app.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE patients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            age INTEGER NOT NULL,
            gender TEXT NOT NULL,
            phone TEXT NOT NULL,
            diagnosis TEXT NOT NULL,
            notes TEXT NOT NULL,
            lastVisitIso TEXT NOT NULL,
            avatarPath TEXT,
            documentPaths TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<List<Patient>> fetchPatients() async {
    final db = await database;
    final rows = await db.query(
      'patients',
      orderBy: 'lastVisitIso DESC, name COLLATE NOCASE',
    );
    return rows.map(Patient.fromMap).toList();
  }

  Future<int> insertPatient(Patient patient) async {
    final db = await database;
    return db.insert('patients', patient.toMap());
  }

  Future<int> updatePatient(Patient patient) async {
    final db = await database;
    return db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  Future<int> deletePatient(int id) async {
    final db = await database;
    return db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }
}
