
class FavoriteController {
  static List<Map<String, dynamic>> favoriteRecipes = [];

  static void addFavorite(Map<String, dynamic> recipe) {
    // avoid duplicates
    if (!favoriteRecipes.any((item) => item["id"] == recipe["id"])) {
      favoriteRecipes.add(recipe);
    }
  }

  static void removeFavorite(int id) {
    favoriteRecipes.removeWhere((item) => item["id"] == id);
  }

  static bool isFavorite(int id) {
    return favoriteRecipes.any((item) => item["id"] == id);
  }

  static List<Map<String, dynamic>> getFavorites() {
    return favoriteRecipes;
  }
}
