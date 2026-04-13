import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cart_item.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();

  static Database? _database;
  
  // Track logged in user
  int? currentUserId; 
  String? currentUserEmail;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'global_recipe_book.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recipes(
        recipe_id INTEGER PRIMARY KEY,
        name TEXT,
        image TEXT,
        cuisine TEXT,
        description TEXT,
        ingredients TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        country TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1
      )
    ''');
    
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        image TEXT NOT NULL
      )
    ''');

    // ADDED PASSWORD FIELD
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_favorites (
        user_id INTEGER,
        recipe_id INTEGER,
        PRIMARY KEY (user_id, recipe_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE recipe_completed (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id           INTEGER NOT NULL,
        recipe_id         INTEGER NOT NULL,
        completed_at      TEXT    NOT NULL DEFAULT (datetime('now', 'localtime')),
        time_taken        INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id)   REFERENCES users(id)   ON DELETE CASCADE,
        FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id) ON DELETE CASCADE
      )
    ''');

    // SEED DATA 
    await db.insert('users', {'email': 'test@user1.com', 'password': 'password123'});
    await db.insert('users', {'email': 'test@user2.com', 'password': 'pass123'});
    await db.insert('users', {'email': 'test@user3.com', 'password': 'password321'});
  }

  // --- NEW AUTHENTICATION METHODS ---
  Future<Map<String, dynamic>?> authenticateUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    
    if (result.isNotEmpty) {
      currentUserId = result.first['id'] as int;
      currentUserEmail = result.first['email'] as String;
      return result.first;
    }
    return null; 
  }

  Future<void> logout() async {
    currentUserId = null;
    currentUserEmail = null;
  }

  Future<List<Map<String, dynamic>>> getUserHistory(int userId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT r.name, rc.completed_at, rc.time_taken
      FROM recipe_completed rc
      JOIN recipes r ON rc.recipe_id = r.recipe_id
      WHERE rc.user_id = ?
      ORDER BY rc.completed_at DESC
    ''', [userId]);
    return result;
  }

  // --- CART METHODS ---
  Future<List<CartIngredient>> loadCart() async {
    final db = await database;
    final rows = await db.query('cart_items');
    return rows.map((row) => CartIngredient(
      id: row['id'] as int,
      name: row['name'] as String,
      country: row['country'] as String,
      imageUrl: row['imageUrl'] as String,
      quantity: row['quantity'] as int,
    )).toList();
  }

  Future<void> upsertItem(CartIngredient item) async {
    final db = await database;
    await db.insert(
      'cart_items',
      {
        'id': item.id,
        'name': item.name,
        'country': item.country,
        'imageUrl': item.imageUrl,
        'quantity': item.quantity,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete('cart_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }
}