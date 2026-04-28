import 'package:hive_flutter/hive_flutter.dart';
import 'package:sahem/core/errors/exceptions.dart';
import 'package:sahem/data/models/recipe_model.dart';
class RecipeLocalDatasource {
  final HiveInterface _hive;

  RecipeLocalDatasource(this._hive);

  Box<RecipeModel> get _favoritesBox => _hive.box<RecipeModel>('favorites');
  Box<RecipeModel> get _cacheBox => _hive.box<RecipeModel>('cache');

  // ── Cache ──────────────────────────────────────────────────────────────────

  Future<void> cacheRecipes(List<RecipeModel> recipes) async {
    try {
      final Map<String, RecipeModel> entries = {
        for (final r in recipes) r.id: r,
      };
      await _cacheBox.putAll(entries);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  Future<List<RecipeModel>> getCachedRecipes(String category) async {
    try {
      final values = _cacheBox.values
          .where((r) =>
              r.category?.toLowerCase() == category.toLowerCase())
          .toList();
      if (values.isEmpty) throw CacheException(message: 'No cache found');
      return values;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  // ── Favorites ──────────────────────────────────────────────────────────────

  Future<List<RecipeModel>> getFavorites() async {
    try {
      return _favoritesBox.values.toList();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  Future<bool> isFavorite(String recipeId) async {
    return _favoritesBox.containsKey(recipeId);
  }

  /// Returns true if added, false if removed (toggle).
  Future<bool> toggleFavorite(RecipeModel recipe) async {
    try {
      if (_favoritesBox.containsKey(recipe.id)) {
        await _favoritesBox.delete(recipe.id);
        return false;
      } else {
        await _favoritesBox.put(recipe.id, recipe);
        return true;
      }
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
}
