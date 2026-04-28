import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sahem/core/errors/failures.dart';
import 'package:sahem/domain/entities/recipe.dart';
import 'package:sahem/domain/usecases/get_favorites.dart';
import 'package:sahem/domain/usecases/toggle_favorite.dart';
import 'package:sahem/presentation/cubits/favorites/favorites_cubit.dart';
import 'package:sahem/presentation/cubits/favorites/favorites_state.dart';

class MockGetFavorites extends Mock implements GetFavorites {}
class MockToggleFavorite extends Mock implements ToggleFavorite {}

const _recipe = Recipe(
  id: '1',
  name: 'Shakshuka',
  ingredients: ['eggs', 'tomatoes'],
  measures: ['3', '2 cups'],
);

void main() {
  late MockGetFavorites mockGetFavorites;
  late MockToggleFavorite mockToggleFavorite;

  setUp(() {
    mockGetFavorites = MockGetFavorites();
    mockToggleFavorite = MockToggleFavorite();
  });

  FavoritesCubit buildCubit() =>
      FavoritesCubit(mockGetFavorites, mockToggleFavorite);

  group('FavoritesCubit', () {
    test('initial state is FavoritesInitial', () {
      expect(buildCubit().state, isA<FavoritesInitial>());
    });

    blocTest<FavoritesCubit, FavoritesState>(
      'emits [FavoritesLoading, FavoritesLoaded] with recipes on success',
      build: () {
        when(() => mockGetFavorites())
            .thenAnswer((_) async => const Right([_recipe]));
        return buildCubit();
      },
      act: (cubit) => cubit.loadFavorites(),
      expect: () => [
        isA<FavoritesLoading>(),
        isA<FavoritesLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as FavoritesLoaded;
        expect(state.favorites.length, 1);
        expect(state.favorites.first.name, 'Shakshuka');
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'emits [FavoritesLoading, FavoritesLoaded] with empty list',
      build: () {
        when(() => mockGetFavorites())
            .thenAnswer((_) async => const Right([]));
        return buildCubit();
      },
      act: (cubit) => cubit.loadFavorites(),
      expect: () => [
        isA<FavoritesLoading>(),
        isA<FavoritesLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as FavoritesLoaded;
        expect(state.favorites, isEmpty);
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'emits [FavoritesLoading, FavoritesError] on failure',
      build: () {
        when(() => mockGetFavorites())
            .thenAnswer((_) async => const Left(CacheFailure()));
        return buildCubit();
      },
      act: (cubit) => cubit.loadFavorites(),
      expect: () => [
        isA<FavoritesLoading>(),
        isA<FavoritesError>(),
      ],
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'removeFromFavorites calls toggleFavorite then reloads list',
      build: () {
        when(() => mockToggleFavorite(_recipe))
            .thenAnswer((_) async => const Right(false));
        when(() => mockGetFavorites())
            .thenAnswer((_) async => const Right([]));
        return buildCubit();
      },
      act: (cubit) => cubit.removeFromFavorites(_recipe),
      expect: () => [
        isA<FavoritesLoading>(),
        isA<FavoritesLoaded>(),
      ],
      verify: (_) {
        verify(() => mockToggleFavorite(_recipe)).called(1);
        verify(() => mockGetFavorites()).called(1);
      },
    );
  });
}
