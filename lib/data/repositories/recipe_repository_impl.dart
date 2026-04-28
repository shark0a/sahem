import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/services/network_info.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_local_datasource.dart';
import '../datasources/recipe_remote_datasource.dart';
import '../models/recipe_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeRemoteDatasource _remote;
  final RecipeLocalDatasource _local;
  final NetworkInfo _networkInfo;

  RecipeRepositoryImpl(this._remote, this._local, this._networkInfo);


  @override
  Future<Either<Failure, List<Recipe>>> getSuggestedRecipes(
      String category) async {
    if (await _networkInfo.isConnected) {
      try {
        final recipes = await _remote.getByCategory(category);
        await _local.cacheRecipes(recipes);
        return Right(recipes.map((e) => e.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? 'Server error'));
      } on NetworkException {
        return const Left(NetworkFailure());
      }
    } else {
      try {
        final cached = await _local.getCachedRecipes(category);
        return Right(cached.map((e) => e.toEntity()).toList());
      } on CacheException {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> searchRecipes(String query) async {
    if (await _networkInfo.isConnected) {
      try {
        final recipes = await _remote.searchByName(query);
        return Right(recipes.map((e) => e.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? 'Server error'));
      }
    } else {
      // Search in local cache
      try {
        final all = await _local.getCachedRecipes('');
        final filtered = all
            .where((r) => r.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
        return Right(filtered.map((e) => e.toEntity()).toList());
      } on CacheException {
        return const Left(NetworkFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Recipe>> getRecipeById(String id) async {
    try {
      final recipe = await _remote.getById(id);
      if (recipe == null) {
        return const Left(ServerFailure(message: 'Recipe not found'));
      }
      return Right(recipe.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getFavorites() async {
    try {
      final favorites = await _local.getFavorites();
      return Right(favorites.map((e) => e.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Cache error'));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(Recipe recipe) async {
    try {
      final model = RecipeModel.fromEntity(recipe);
      final added = await _local.toggleFavorite(model);
      return Right(added);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Cache error'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String recipeId) async {
    try {
      final result = await _local.isFavorite(recipeId);
      return Right(result);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }
}
