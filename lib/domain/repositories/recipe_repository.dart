import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/recipe.dart';

abstract class RecipeRepository {
  Future<Either<Failure, List<Recipe>>> getSuggestedRecipes(String category);
  Future<Either<Failure, List<Recipe>>> searchRecipes(String query);
  Future<Either<Failure, Recipe>> getRecipeById(String id);
  Future<Either<Failure, List<Recipe>>> getFavorites();
  Future<Either<Failure, bool>> toggleFavorite(Recipe recipe);
  Future<Either<Failure, bool>> isFavorite(String recipeId);
}
