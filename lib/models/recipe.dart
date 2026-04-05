class Recipe {
  final int id;
  final String title;
  final String image;
  final String cuisine;
  final String description;
  final String ingredients;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.cuisine,
    required this.description,
    required this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['image'] ?? '';

    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'https://spoonacular.com/recipeImages/$imageUrl';
    }

    String cuisineName = '';
    if (json['cuisines'] != null &&
        json['cuisines'] is List &&
        (json['cuisines'] as List).isNotEmpty) {
      cuisineName = json['cuisines'][0].toString().trim();
    }

    return Recipe(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: imageUrl,
      cuisine: cuisineName,
      description: '',
      ingredients: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipe_id': id,
      'name': title,
      'image': image,
      'cuisine': cuisine,
      'description': description,
      'ingredients': ingredients,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['recipe_id'] ?? 0,
      title: map['name'] ?? '',
      image: map['image'] ?? '',
      cuisine: map['cuisine'] ?? '',
      description: map['description'] ?? '',
      ingredients: map['ingredients'] ?? '',
    );
  }
}