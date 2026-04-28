import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

class GetSuggestedRecipes {
  final RecipeRepository _repository;
  GetSuggestedRecipes(this._repository);

  Future<Either<Failure, List<Recipe>>> call(String category) =>
      _repository.getSuggestedRecipes(category);
}
