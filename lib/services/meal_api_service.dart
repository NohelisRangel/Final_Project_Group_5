import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class MealApiService {
  static const String _apiKey = '108344f219df45f1ab3fcbc912d2e0cd';
  static const String _baseUrl = 'https://api.spoonacular.com/recipes';

  Future<List<Recipe>> fetchRecipes({
    String query = '',
    String cuisine = '',
  }) async {
    final uri = Uri.parse('$_baseUrl/complexSearch').replace(
      queryParameters: {
        'apiKey': _apiKey,
        'number': '20',
        if (query.isNotEmpty) 'query': query,
        if (cuisine.isNotEmpty) 'cuisine': cuisine,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['results'] == null) {
        return [];
      }

      final List results = data['results'];

      return results
          .map((item) => Recipe.fromJson(item, selectedCuisine: cuisine))
          .toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<Map<String, dynamic>> fetchRecipeDetails(int recipeId) async {
    final uri = Uri.parse('$_baseUrl/$recipeId/information').replace(
      queryParameters: {
        'apiKey': _apiKey,
        'includeNutrition': 'true',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load recipe details');
    }
  }
  Future<List<Map<String, dynamic>>> searchIngredients(String query) async {
  final uri = Uri.parse('https://api.spoonacular.com/food/ingredients/search').replace(
    queryParameters: {
      'apiKey': _apiKey,
      'query': query,
      'number': '10',
      'metaInformation': 'true', // includes aisle, unit info
    },
  );

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List results = data['results'] ?? [];

    return results.map((item) => {
      'id': item['id'],
      'name': item['name'],
      'country': item['aisle'] ?? 'General', // aisle used as subtitle like your mockup
      'image': 'https://spoonacular.com/cdn/ingredients_100x100/${item['image']}',
    }).toList();
  } else {
    throw Exception('Failed to search ingredients');
  }
}

// Used when opening a recipe detail — pre-fills cart with that recipe's ingredients
Future<List<Map<String, dynamic>>> fetchRecipeIngredients(int recipeId) async {
  final data = await fetchRecipeDetails(recipeId); // reuses your existing method
  final List ingredients = data['extendedIngredients'] ?? [];

  return ingredients.map((item) => {
    'id': item['id'],
    'name': item['name'],
    'country': item['aisle'] ?? 'General',
    'image': 'https://spoonacular.com/cdn/ingredients_100x100/${item['image']}',
  }).toList();
}
}