import 'package:flutter/material.dart';
import '../../models/recipe.dart';
import '../../services/meal_api_service.dart';
import '../../controllers/cart_controller.dart';
import '../../models/cart_item.dart';
import '../screens/cart_list_screen.dart';

class RecipeDescriptionScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDescriptionScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeDescriptionScreen> createState() =>
      _RecipeDescriptionScreenState();
}

class _RecipeDescriptionScreenState extends State<RecipeDescriptionScreen> {
  final MealApiService _apiService = MealApiService();

  bool _isLoading = true;
  Map<String, dynamic>? _recipeDetails;

  @override
  void initState() {
    super.initState();
    _loadRecipeDetails();
  }

  Future<void> _loadRecipeDetails() async {
    try {
      final details =
          await _apiService.fetchRecipeDetails(widget.recipe.id);

      if (!mounted) return;

      setState(() {
        _recipeDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading details: $e')),
      );
    }
  }

  String _removeHtmlTags(String htmlText) {
    return htmlText
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .trim();
  }

  void _addAllToCart() {
  final ingredients = (_recipeDetails!['extendedIngredients'] as List<dynamic>? ?? []);
  
  for (final ingredient in ingredients) {
    CartManager().addIngredient(CartIngredient(
      id: ingredient['id'],
      name: ingredient['name'] ?? '',
      country: ingredient['aisle'] ?? 'General',
      imageUrl: 'https://spoonacular.com/cdn/ingredients_100x100/${ingredient['image'] ?? ''}',
    ));
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${ingredients.length} ingredients added to cart!'),
      backgroundColor: Colors.green,
      action: SnackBarAction(
        label: 'View Cart',
        textColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Detail'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recipeDetails == null
              ? const Center(child: Text('No recipe details found'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        _recipeDetails!['image'] ??
                            widget.recipe.image,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) {
                          return Container(
                            height: 250,
                            width: double.infinity,
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  size: 60),
                            ),
                          );
                        },
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              _recipeDetails!['title'] ??
                                  widget.recipe.title,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                const Icon(Icons.public,
                                    color:
                                        Colors.orange),
                                const SizedBox(
                                    width: 8),
                                Text(
                                  (_recipeDetails![
                                                  'cuisines'] !=
                                              null &&
                                          _recipeDetails![
                                                  'cuisines']
                                              .isNotEmpty)
                                      ? _recipeDetails![
                                              'cuisines'][0]
                                          .toString()
                                      : widget.recipe
                                          .cuisine,
                                  style:
                                      const TextStyle(
                                          fontSize:
                                              16),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              _removeHtmlTags(
                                  _recipeDetails![
                                          'summary'] ??
                                      'No description available'),
                              style:
                                  const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 20),

                            const Text(
                              'Ingredients',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            ...((_recipeDetails![
                                            'extendedIngredients']
                                        as List<dynamic>? ??
                                    [])
                                .map(
                              (ingredient) => Padding(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                            vertical:
                                                4),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    const Icon(
                                      Icons
                                          .check_circle,
                                      size: 18,
                                      color:
                                          Colors.green,
                                    ),
                                    const SizedBox(
                                        width: 8),
                                    Expanded(
                                      child: Text(
                                        ingredient[
                                                'original'] ??
                                            '',
                                        style:
                                            const TextStyle(
                                                fontSize:
                                                    16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),

                            const SizedBox(height: 20),

                            const Text(
                              'Instructions',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              _removeHtmlTags(
                                _recipeDetails![
                                        'instructions'] ??
                                    'No instructions available',
                              ),
                              style:
                                  const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton
                                  .icon(
                                onPressed: () {
                                  ScaffoldMessenger
                                          .of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Added to Favorites successfully'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons
                                    .favorite_border),
                                label: const Text(
                                    'Add to Favorites'),
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      Colors
                                          .redAccent,
                                  foregroundColor:
                                      Colors.white,
                                  padding:
                                      const EdgeInsets
                                              .symmetric(
                                          vertical:
                                              14),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _recipeDetails == null ? null : _addAllToCart,
                                icon: const Icon(Icons.shopping_cart_outlined),
                                label: const Text('Add to Cart'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}