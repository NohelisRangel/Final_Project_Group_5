import '../models/cart_item.dart';
class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();
 
  final List<CartIngredient> _items = [];
 
  List<CartIngredient> get items => List.unmodifiable(_items);
 
  void addIngredient(CartIngredient ingredient) {
    final existing = _items.firstWhere(
      (i) => i.id == ingredient.id,
      orElse: () => CartIngredient(id: -1, name: '', country: '', imageUrl: ''),
    );
    if (existing.id != -1) {
      existing.quantity++;
    } else {
      _items.add(ingredient);
    }
  }
 
  void removeIngredient(int id) {
    _items.removeWhere((i) => i.id == id);
  }
 
  void incrementQuantity(int id) {
    final item = _items.firstWhere((i) => i.id == id);
    item.quantity++;
  }
 
  void decrementQuantity(int id) {
    final item = _items.firstWhere((i) => i.id == id);
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      removeIngredient(id);
    }
  }
 
  int get totalItems => _items.fold(0, (sum, i) => sum + i.quantity);
}