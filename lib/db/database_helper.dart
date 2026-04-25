import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('guessing_game.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE games(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        targetNumber INTEGER NOT NULL,
        attempts INTEGER NOT NULL,
        date TEXT NOT NULL,
        isWin INTEGER NOT NULL,
        maxNumber INTEGER NOT NULL,
        minNumber INTEGER NOT NULL
      )
    ''');
  }

  Future<void> initDatabase() async {
    await database;
  }

  Future<int> insertGame(GameModel game) async {
    final db = await instance.database;
    return await db.insert('games', game.toMap());
  }

  Future<List<GameModel>> getAllGames() async {
    final db = await instance.database;
    final result = await db.query('games', orderBy: 'date DESC');
    return result.map((json) => GameModel.fromMap(json)).toList();
  }

  Future<int> deleteGame(int id) async {
    final db = await instance.database;
    return await db.delete('games', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearAllGames() async {
    final db = await instance.database;
    return await db.delete('games');
  }

  Future<double> getAverageAttempts() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT AVG(attempts) as avg FROM games WHERE isWin = 1');
    return result.first['avg'] as double? ?? 0.0;
  }

  Future<int> getTotalGamesPlayed() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM games');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getWinCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM games WHERE isWin = 1');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}