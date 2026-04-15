import 'package:flutter/material.dart';
import '../../controllers/favorites_controller.dart';
import '../../models/recipe.dart';
import 'recipe_description_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Map<String, dynamic>> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final data = await FavoriteController.getFavorites();

    if (!mounted) return;

    setState(() {
      favorites = data;
      isLoading = false;
    });
  }

  Future<void> deleteFavorite(int id) async {
    await FavoriteController.removeFavorite(id);
    await loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites"),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
              ? const Center(child: Text("No favorites yet"))
              : ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    var recipe = favorites[index];

                    return ListTile(
                      leading: Image.network(
                        recipe["image"],
                        width: 60,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported);
                        },
                      ),
                      title: Text(recipe["title"]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await deleteFavorite(recipe["id"]);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeDescriptionScreen(
                              recipe: Recipe(
                                id: recipe["id"],
                                title: recipe["title"],
                                image: recipe["image"],
                                cuisine: "",
                                description: "",
                                ingredients: "",
                                instructions: "",
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}