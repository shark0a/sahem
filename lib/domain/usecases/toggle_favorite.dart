import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

class ToggleFavorite {
  final RecipeRepository _repository;
  ToggleFavorite(this._repository);

  Future<Either<Failure, bool>> call(Recipe recipe) =>
      _repository.toggleFavorite(recipe);
}
