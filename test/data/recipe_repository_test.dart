import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sahem/core/errors/exceptions.dart';
import 'package:sahem/core/errors/failures.dart';
import 'package:sahem/core/services/network_info.dart';
import 'package:sahem/data/datasources/recipe_local_datasource.dart';
import 'package:sahem/data/datasources/recipe_remote_datasource.dart';
import 'package:sahem/data/models/recipe_model.dart';
import 'package:sahem/data/repositories/recipe_repository_impl.dart';
import 'package:sahem/domain/entities/recipe.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────
class MockRemoteDatasource extends Mock implements RecipeRemoteDatasource {}

class MockLocalDatasource extends Mock implements RecipeLocalDatasource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

// ── Helpers ────────────────────────────────────────────────────────────────
RecipeModel _makeModel(String id) => RecipeModel(
      id: id,
      name: 'Test Recipe $id',
      thumbnailUrl: 'https://example.com/image.jpg',
      category: 'Chicken',
      area: 'Egyptian',
      instructions: 'Step 1. Step 2.',
      ingredients: ['Ingredient 1', 'Ingredient 2'],
      measures: ['1 cup', '2 tbsp'],
    );

void main() {
  late RecipeRepositoryImpl repository;
  late MockRemoteDatasource mockRemote;
  late MockLocalDatasource mockLocal;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemote = MockRemoteDatasource();
    mockLocal = MockLocalDatasource();
    mockNetworkInfo = MockNetworkInfo();
    repository = RecipeRepositoryImpl(mockRemote, mockLocal, mockNetworkInfo);
  });

  // ── getSuggestedRecipes ──────────────────────────────────────────────────
  group('getSuggestedRecipes', () {
    const category = 'Chicken';
    final models = [_makeModel('1'), _makeModel('2')];

    test('returns remote data and caches it when online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.getByCategory(category))
          .thenAnswer((_) async => models);
      when(() => mockLocal.cacheRecipes(models)).thenAnswer((_) async {});

      final result = await repository.getSuggestedRecipes(category);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected Right'), (recipes) {
        expect(recipes.length, equals(2));
        expect(recipes.first.id, equals('1'));
        expect(recipes.first, isA<Recipe>());
      });

      verify(() => mockRemote.getByCategory(category)).called(1);
      verify(() => mockLocal.cacheRecipes(models)).called(1);
    });

    test('returns cached data when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocal.getCachedRecipes(category))
          .thenAnswer((_) async => models);

      final result = await repository.getSuggestedRecipes(category);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected Right'), (recipes) {
        expect(recipes.length, equals(2));
      });

      verifyNever(() => mockRemote.getByCategory(any()));
      verify(() => mockLocal.getCachedRecipes(category)).called(1);
    });

    test('returns CacheFailure when offline and no cache available', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocal.getCachedRecipes(category))
          .thenThrow(const CacheException(message: 'Empty cache'));

      final result = await repository.getSuggestedRecipes(category);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns ServerFailure when remote throws ServerException', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.getByCategory(category)).thenThrow(
          const ServerException(statusCode: 500, message: 'Server Error'));

      final result = await repository.getSuggestedRecipes(category);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  // ── searchRecipes ────────────────────────────────────────────────────────
  group('searchRecipes', () {
    const query = 'pasta';
    final models = [_makeModel('10'), _makeModel('11')];

    test('returns results from remote when online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.searchByName(query))
          .thenAnswer((_) async => models);

      final result = await repository.searchRecipes(query);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (recipes) => expect(recipes.length, equals(2)),
      );
    });

    test('returns NetworkFailure when offline and cache is empty', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocal.getCachedRecipes(any()))
          .thenThrow(const CacheException());

      final result = await repository.searchRecipes(query);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  // ── getFavorites ─────────────────────────────────────────────────────────
  group('getFavorites', () {
    final models = [_makeModel('20'), _makeModel('21')];

    test('returns list of favorite recipes', () async {
      when(() => mockLocal.getFavorites()).thenAnswer((_) async => models);

      final result = await repository.getFavorites();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (favorites) => expect(favorites.length, equals(2)),
      );
    });

    test('returns CacheFailure when local throws', () async {
      when(() => mockLocal.getFavorites())
          .thenThrow(const CacheException(message: 'DB error'));

      final result = await repository.getFavorites();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  // ── toggleFavorite ───────────────────────────────────────────────────────
  group('toggleFavorite', () {
    final recipe = _makeModel('30').toEntity();

    test('returns true when recipe is added to favorites', () async {
      when(() => mockLocal.toggleFavorite(any())).thenAnswer((_) async => true);

      final result = await repository.toggleFavorite(recipe);

      expect(result, equals(const Right<Failure, bool>(true)));
    });

    test('returns false when recipe is removed from favorites', () async {
      when(() => mockLocal.toggleFavorite(any()))
          .thenAnswer((_) async => false);

      final result = await repository.toggleFavorite(recipe);

      expect(result, equals(const Right<Failure, bool>(false)));
    });
  });
}
