import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = path.join(await getDatabasesPath(), 'zonarider.db');
    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites (
            motorcycleId TEXT PRIMARY KEY,
            createdAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE api_cache (
            motorcycleId TEXT PRIMARY KEY,
            payload TEXT NOT NULL,
            fetchedAt TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  Future<Set<String>> getFavoriteIds() async {
    final rows = await (await database).query('favorites');
    return rows.map((row) => row['motorcycleId'] as String).toSet();
  }

  Future<void> setFavorite(String id, bool isFavorite) async {
    final db = await database;
    if (isFavorite) {
      await db.insert(
        'favorites',
        {'motorcycleId': id, 'createdAt': DateTime.now().toIso8601String()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.delete('favorites', where: 'motorcycleId = ?', whereArgs: [id]);
    }
  }

  Future<String?> getApiCache(String id) async {
    final rows = await (await database).query(
      'api_cache',
      where: 'motorcycleId = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['payload'] as String;
  }

  Future<void> saveApiCache(String id, String payload) async {
    await (await database).insert(
      'api_cache',
      {
        'motorcycleId': id,
        'payload': payload,
        'fetchedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
