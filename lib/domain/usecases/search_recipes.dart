import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

class SearchRecipes {
  final RecipeRepository _repository;
  SearchRecipes(this._repository);

  Future<Either<Failure, List<Recipe>>> call(String query) =>
      _repository.searchRecipes(query);
}
