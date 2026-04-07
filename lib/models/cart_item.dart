class CartIngredient {
  final int id;
  final String name;
  final String country;
  final String imageUrl;
  int quantity;
 
  CartIngredient({
    required this.id,
    required this.name,
    required this.country,
    required this.imageUrl,
    this.quantity = 1,
  });
}