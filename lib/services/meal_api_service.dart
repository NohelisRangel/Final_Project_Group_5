import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class MealApiService {
  static const String _apiKey = '9326de07e3f241bb841e3ba8244772df';
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
}