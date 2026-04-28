import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';
class GetFavorites {
  final RecipeRepository _repository;
  GetFavorites(this._repository);

  Future<Either<Failure, List<Recipe>>> call() => _repository.getFavorites();
}
