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

// -- Mocks ------------------------------------------------------------------
class MockRemoteDatasource extends Mock implements RecipeRemoteDatasource {}

class MockLocalDatasource extends Mock implements RecipeLocalDatasource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class FakeRecipeModel extends Fake implements RecipeModel {}

// -- Helpers ----------------------------------------------------------------
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

  setUpAll(() {
    registerFallbackValue(FakeRecipeModel());
  });

  setUp(() {
    mockRemote = MockRemoteDatasource();
    mockLocal = MockLocalDatasource();
    mockNetworkInfo = MockNetworkInfo();
    repository = RecipeRepositoryImpl(mockRemote, mockLocal, mockNetworkInfo);
  });

  // -- getSuggestedRecipes --------------------------------------------------
  group('getSuggestedRecipes', () {
    const category = 'Chicken';
    final models = [_makeModel('1'), _makeModel('2')];

    test('returns remote data and caches it when online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.getByCategory(category))
          .thenAnswer((_) async => models);
      when(() => mockLocal.cacheRecipes(models)).thenAnswer((_) async => {});

      final result = await repository.getSuggestedRecipes(category);

      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('Expected Right, got Left: $l'),
        (r) => expect(r.length, 2),
      );
      verify(() => mockNetworkInfo.isConnected).called(1);
      verify(() => mockRemote.getByCategory(category)).called(1);
      verify(() => mockLocal.cacheRecipes(models)).called(1);
    });

    test('returns cached data when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocal.getCachedRecipes(category))
          .thenAnswer((_) async => models);

      final result = await repository.getSuggestedRecipes(category);

      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('Expected Right, got Left: $l'),
        (r) => expect(r.length, 2),
      );
      verify(() => mockNetworkInfo.isConnected).called(1);
      verifyNever(() => mockRemote.getByCategory(category));
      verify(() => mockLocal.getCachedRecipes(category)).called(1);
    });

    test('returns CacheFailure when offline and cache fails', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocal.getCachedRecipes(category))
          .thenThrow(CacheException());

      final result = await repository.getSuggestedRecipes(category);

      expect(result.isLeft(), isTrue);
      result.fold(
        (l) => expect(l, isA<CacheFailure>()),
        (r) => fail('Expected Left, got Right: $r'),
      );
      verify(() => mockNetworkInfo.isConnected).called(1);
      verifyNever(() => mockRemote.getByCategory(category));
      verify(() => mockLocal.getCachedRecipes(category)).called(1);
    });
  });

  // -- searchRecipes --------------------------------------------------------
  group('searchRecipes', () {
    const query = 'test';
    final models = [_makeModel('1'), _makeModel('2')];

    test('returns remote data when online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.searchByName(query))
          .thenAnswer((_) async => models);

      final result = await repository.searchRecipes(query);

      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('Expected Right, got Left: $l'),
        (r) => expect(r.length, 2),
      );
      verify(() => mockNetworkInfo.isConnected).called(1);
      verify(() => mockRemote.searchByName(query)).called(1);
    });

    test('returns cached data when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocal.getCachedRecipes(''))
          .thenAnswer((_) async => models);

      final result = await repository.searchRecipes(query);

      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('Expected Right, got Left: $l'),
        (r) => expect(r.length, 2),
      );
      verify(() => mockNetworkInfo.isConnected).called(1);
      verifyNever(() => mockRemote.searchByName(query));
      verify(() => mockLocal.getCachedRecipes('')).called(1);
    });

    test('returns NetworkFailure when offline and cache fails', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocal.getCachedRecipes('')).thenThrow(CacheException());

      final result = await repository.searchRecipes(query);

      expect(result.isLeft(), isTrue);
      result.fold(
        (l) => expect(l, isA<NetworkFailure>()),
        (r) => fail('Expected Left, got Right: $r'),
      );
      verify(() => mockNetworkInfo.isConnected).called(1);
      verifyNever(() => mockRemote.searchByName(query));
      verify(() => mockLocal.getCachedRecipes('')).called(1);
    });
  });

  // -- getFavorites --------------------------------------------------------
  group('getFavorites', () {
    final models = [_makeModel('1'), _makeModel('2')];

    test('returns favorite recipes', () async {
      when(() => mockLocal.getFavorites()).thenAnswer((_) async => models);

      final result = await repository.getFavorites();

      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('Expected Right, got Left: $l'),
        (r) => expect(r.length, 2),
      );
      verify(() => mockLocal.getFavorites()).called(1);
    });

    test('returns empty list when no favorites exist', () async {
      when(() => mockLocal.getFavorites()).thenAnswer((_) async => []);

      final result = await repository.getFavorites();

      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('Expected Right, got Left: $l'),
        (r) => expect(r.isEmpty, isTrue),
      );
      verify(() => mockLocal.getFavorites()).called(1);
    });
  });

  // -- toggleFavorite -------------------------------------------------------
  group('toggleFavorite', () {
    final recipe = _makeModel('30').toEntity();

    test('returns true when recipe is added to favorites', () async {
      when(() => mockLocal.toggleFavorite(any())).thenAnswer((_) async => true);

      final result = await repository.toggleFavorite(recipe);

      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('Expected Right, got Left: $l'),
        (r) => expect(r, isTrue),
      );
    });

    test('returns false when recipe is removed from favorites', () async {
      when(() => mockLocal.toggleFavorite(any()))
          .thenAnswer((_) async => false);

      final result = await repository.toggleFavorite(recipe);

      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('Expected Right, got Left: $l'),
        (r) => expect(r, isFalse),
      );
    });
  });
}
