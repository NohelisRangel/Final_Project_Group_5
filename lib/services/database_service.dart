import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cart_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _getDataDb();
    return _db!;
  }

  Future<Database> _getDataDb() async {
    final path = join(await getDatabasesPath(), 'cart.db');
    if(_db == null) {
      try{
_db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        String sql = '''
          CREATE TABLE cart_items (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            country TEXT NOT NULL,
            imageUrl TEXT NOT NULL,
            quantity INTEGER NOT NULL DEFAULT 1
          )
        ''';
        await db.execute(sql);
      },
    );
      }catch(e){
        throw Exception("Error opening database: $e");
      }
    }
    return _db!;
  }

  // Load all items from DB
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

  // Insert or update item
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

  // Delete one item
  Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete('cart_items', where: 'id = ?', whereArgs: [id]);
  }

  // Clear entire cart
  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }
}