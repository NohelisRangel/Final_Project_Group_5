import 'package:flutter/material.dart';
import '../../controllers/favorites_controller.dart';
import 'recipe_description_screen.dart';

class FavoriteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var favorites = FavoriteController.getFavorites();

    return Scaffold(
      appBar: AppBar(
        title: Text("My Favorites"),
        backgroundColor: Colors.orange,
      ),

      body: favorites.isEmpty
          ? Center(child: Text("No favorites yet"))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                var recipe = favorites[index];

                return ListTile(
                  leading: Image.network(recipe["image"], width: 60),
                  title: Text(recipe["title"]),

                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      FavoriteController.removeFavorite(recipe["id"]);
                      (context as Element).reassemble(); 
                    },
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeDescriptionScreen(recipe: recipe["id"]),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
