import 'package:flutter/material.dart';
import '../../controllers/cart_controller.dart';
import '../../models/cart_item.dart';
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
 
  @override
  State<CartScreen> createState() => _CartScreenState();
}
 

class _CartItemCard extends StatelessWidget {
  final CartIngredient item;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
 
  const _CartItemCard({
    required this.item,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ingredient image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.fastfood_rounded,
                    color: accent.withOpacity(0.6), size: 28),
              ),
            ),
          ),
          const SizedBox(width: 12),
 
          // Name + country
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item.country,
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
              ],
            ),
          ),
 
        ],
      ),
    );
  }
}
 
class _CartScreenState extends State<CartScreen> {
  final CartManager _cart = CartManager();
 
  void _increment(int id) => setState(() => _cart.incrementQuantity(id));
  void _decrement(int id) => setState(() => _cart.decrementQuantity(id));
  void _remove(int id) => setState(() => _cart.removeIngredient(id));
 
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFF8F0);
    final cardBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? Colors.grey[400] : Colors.grey[600];
    final accent = const Color(0xFFFF9500); // orange accent
 
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cart Page',
          style: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: _cart.items.isEmpty
          ? _buildEmptyState(textSecondary!, accent)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: _cart.items.length,
                    itemBuilder: (context, index) {
                      final item = _cart.items[index];
                      return _CartItemCard(
                        item: item,
                        cardBg: cardBg,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary!,
                        accent: accent,
                        onIncrement: () => _increment(item.id),
                        onDecrement: () => _decrement(item.id),
                        onRemove: () => _remove(item.id),
                      );
                    },
                  ),
                ),
                _buildBuyButton(accent),
              ],
            ),
    );
  }
 
  Widget _buildEmptyState(Color textSecondary, Color accent) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 72, color: accent.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add ingredients from a recipe to get started.',
            style: TextStyle(fontSize: 14, color: textSecondary.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
 
  Widget _buildBuyButton(Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Buying ${_cart.totalItems} ingredient(s)'),
                backgroundColor: accent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          ),
          child: const Text(
            'Buy All Ingredients',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
  
}
 