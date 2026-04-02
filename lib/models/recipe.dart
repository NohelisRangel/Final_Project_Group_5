class Recipe {
  final int id;
  final String title;
  final String image;
  final String cuisine;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.cuisine,
  });

  factory Recipe.fromJson(
    Map<String, dynamic> json, {
    String selectedCuisine = '',
  }) {
    String imageUrl = json['image'] ?? '';

    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'https://spoonacular.com/recipeImages/$imageUrl';
    }

    return Recipe(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: imageUrl,
      cuisine: selectedCuisine.isEmpty ? 'Unknown' : selectedCuisine,
    );
  }
}