import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import 'recipe_db_service.dart';

class MealApiService {
  static const String _apiKey = '177cf41477964663beec972d7a986bf1';
  static const String _baseUrl = 'https://api.spoonacular.com/recipes';

  final RecipeDbService _recipeDbService = RecipeDbService();

  Future<List<Recipe>> fetchRecipes({
    String query = '',
    String cuisine = '',
    int offset = 0,
    int number = 10,
  }) async {
    final uri = Uri.parse('$_baseUrl/complexSearch').replace(
      queryParameters: {
        'apiKey': _apiKey,
        'number': number.toString(),
        'offset': offset.toString(),
        'addRecipeInformation': 'true',
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

      final List<Recipe> recipes = results
          .map((item) => Recipe.fromJson(item))
          .where((recipe) => recipe.cuisine.isNotEmpty)
          .toList();

      final List<Recipe> firstTen = recipes.take(10).toList();
      await _recipeDbService.clearRecipes();
      await _recipeDbService.insertRecipes(firstTen);

      return recipes;
    } else {
      throw Exception(
        'Failed to load recipes. Status: ${response.statusCode}. Body: ${response.body}',
      );
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
      throw Exception(
        'Failed to load recipe details. Status: ${response.statusCode}. Body: ${response.body}',
      );
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