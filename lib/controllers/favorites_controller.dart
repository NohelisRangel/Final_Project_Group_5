import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';

class FavoriteController {
  static Future<Database> get _db async =>
      await DatabaseService.instance.database;

  static Future<void> addFavorite(Map<String, dynamic> recipe) async {
    final db = await _db;
    await db.insert(
      'favorites',
      {
        'id': recipe['id'],
        'title': recipe['title'],
        'image': recipe['image'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> removeFavorite(int id) async {
    final db = await _db;
    await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<bool> isFavorite(int id) async {
    final db = await _db;
    final result = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await _db;
    return await db.query('favorites');
  }
}