import 'package:sqflite/sqflite.dart';
import '../models/recipe.dart';
import 'database_service.dart';

class RecipeDbService {
  final DatabaseService _databaseService = DatabaseService.instance;

  /// Insert one recipe
  Future<void> insertRecipe(Recipe recipe) async {
    final db = await _databaseService.database;

    await db.insert(
      'recipes',
      recipe.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple recipes
  Future<void> insertRecipes(List<Recipe> recipes) async {
    final db = await _databaseService.database;

    final batch = db.batch();

    for (final recipe in recipes) {
      batch.insert(
        'recipes',
        recipe.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Get all recipes
  Future<List<Recipe>> getAllRecipes() async {
    final db = await _databaseService.database;

    final result = await db.query('recipes');

    return result.map((map) => Recipe.fromMap(map)).toList();
  }

  /// Count recipes
  Future<int> getRecipeCount() async {
    final db = await _databaseService.database;

    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM recipes');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Delete all recipes
  Future<void> clearRecipes() async {
    final db = await _databaseService.database;

    await db.delete('recipes');
  }

  /// Save cooked recipe with time
    Future<void> saveCookedRecipe({
    required int recipeId,
    required String userId,
    required String title,
    required int elapsedSeconds,
    required String instructions,
  }) async {
    final db = await _databaseService.database;

    await db.insert(
      'recipe_completed',
      {
        'recipe_id': recipeId,
        'user_id': DatabaseService.instance.currentUserId ?? 0,
        'title': title,
        'time_taken': elapsedSeconds,
        'completed_at': DateTime.now().toIso8601String(),
        'instructions': instructions,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}