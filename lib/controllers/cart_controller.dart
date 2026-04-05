
import '../models/cart_item.dart';
import '../services/database_service.dart';
class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final DatabaseService _db = DatabaseService();
  final List<CartIngredient> _items = [];

  List<CartIngredient> get items => List.unmodifiable(_items);
  int get totalItems => _items.fold(0, (sum, i) => sum + i.quantity);

  // Call once at app startup
  Future<void> loadFromDatabase() async {
    final saved = await _db.loadCart();
    _items.clear();
    _items.addAll(saved);
  }

  Future<void> addIngredient(CartIngredient ingredient) async {
    final existing = _items.firstWhere(
      (i) => i.id == ingredient.id,
      orElse: () => CartIngredient(id: -1, name: '', country: '', imageUrl: ''),
    );
    if (existing.id != -1) {
      existing.quantity++;
      await _db.upsertItem(existing);   // update quantity in DB
    } else {
      _items.add(ingredient);
      await _db.upsertItem(ingredient); // insert new row in DB
    }
  }

  Future<void> removeIngredient(int id) async {
    _items.removeWhere((i) => i.id == id);
    await _db.deleteItem(id);           // delete from DB
  }

  Future<void> incrementQuantity(int id) async {
    final item = _items.firstWhere((i) => i.id == id);
    item.quantity++;
    await _db.upsertItem(item);         
  }

  Future<void> decrementQuantity(int id) async {
    final item = _items.firstWhere((i) => i.id == id);
    if (item.quantity > 1) {
      item.quantity--;
      await _db.upsertItem(item);       
    } else {
      await removeIngredient(id);
    }
  }
}