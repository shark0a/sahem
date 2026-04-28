import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sahem/core/errors/failures.dart';
import 'package:sahem/domain/entities/recipe.dart';
import 'package:sahem/domain/usecases/get_suggested_recipes.dart';
import 'package:sahem/domain/usecases/search_recipes.dart';
import 'package:sahem/Feature/Search/presentation/bloc/search_cubit.dart';
import 'package:sahem/Feature/Search/presentation/bloc/search_state.dart';

class MockSearchRecipes extends Mock implements SearchRecipes {}

class MockGetSuggestedRecipes extends Mock implements GetSuggestedRecipes {}

const _recipe = Recipe(
  id: '1',
  name: 'Spaghetti',
  thumbnailUrl: 'https://example.com/img.jpg',
  category: 'Pasta',
  area: 'Italian',
  ingredients: ['pasta', 'tomato'],
  measures: ['200g', '3'],
);

void main() {
  late MockSearchRecipes mockSearchRecipes;
  late MockGetSuggestedRecipes mockGetSuggestedRecipes;

  setUp(() {
    mockSearchRecipes = MockSearchRecipes();
    mockGetSuggestedRecipes = MockGetSuggestedRecipes();
  });

  group('SearchCubit', () {
    test('initial state is SearchInitial', () {
      final cubit = SearchCubit(mockSearchRecipes, mockGetSuggestedRecipes);
      expect(cubit.state, isA<SearchInitial>());
      cubit.close();
    });

    blocTest<SearchCubit, SearchState>(
      'emits [SearchLoading, SearchLoaded] on valid search with results',
      build: () {
        when(() => mockSearchRecipes(any()))
            .thenAnswer((_) async => const Right([_recipe]));
        return SearchCubit(mockSearchRecipes, mockGetSuggestedRecipes);
      },
      act: (cubit) async {
        cubit.onSearchChanged('spaghetti');
        // Wait for debounce (400ms) + async op
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchLoaded>(),
      ],
      verify: (_) {
        verify(() => mockSearchRecipes('spaghetti')).called(1);
      },
    );

    blocTest<SearchCubit, SearchState>(
      'emits [SearchLoading, SearchEmpty] when query returns no results',
      build: () {
        when(() => mockSearchRecipes(any()))
            .thenAnswer((_) async => const Right([]));
        return SearchCubit(mockSearchRecipes, mockGetSuggestedRecipes);
      },
      act: (cubit) async {
        cubit.onSearchChanged('xyzabc');
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchEmpty>(),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'emits [SearchLoading, SearchError] on failure',
      build: () {
        when(() => mockSearchRecipes(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return SearchCubit(mockSearchRecipes, mockGetSuggestedRecipes);
      },
      act: (cubit) async {
        cubit.onSearchChanged('pasta');
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchError>(),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'emits SearchInitial when empty string is searched',
      build: () => SearchCubit(mockSearchRecipes, mockGetSuggestedRecipes),
      act: (cubit) async {
        cubit.onSearchChanged('');
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      expect: () => [isA<SearchInitial>()],
      verify: (_) {
        verifyNever(() => mockSearchRecipes(any()));
      },
    );

    blocTest<SearchCubit, SearchState>(
      'does NOT emit duplicate states for the same query (distinct)',
      build: () {
        when(() => mockSearchRecipes(any()))
            .thenAnswer((_) async => const Right([_recipe]));
        return SearchCubit(mockSearchRecipes, mockGetSuggestedRecipes);
      },
      act: (cubit) async {
        cubit.onSearchChanged('pasta');
        cubit.onSearchChanged('pasta'); // same query
        await Future<void>.delayed(const Duration(milliseconds: 700));
      },
      verify: (_) {
        verify(() => mockSearchRecipes('pasta')).called(1);
      },
    );

    blocTest<SearchCubit, SearchState>(
      'clearSearch resets state to SearchInitial',
      build: () {
        when(() => mockSearchRecipes(any()))
            .thenAnswer((_) async => const Right([_recipe]));
        return SearchCubit(mockSearchRecipes, mockGetSuggestedRecipes);
      },
      act: (cubit) async {
        cubit.onSearchChanged('pasta');
        await Future<void>.delayed(const Duration(milliseconds: 600));
        cubit.clearSearch();
      },
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchLoaded>(),
        isA<SearchInitial>(),
      ],
    );

    test('SearchLoaded state holds correct recipes', () {
      const state = SearchLoaded([_recipe], query: 'spaghetti');
      expect(state.recipes.length, 1);
      expect(state.recipes.first.name, 'Spaghetti');
      expect(state.query, 'spaghetti');
    });

    test('SearchEmpty state holds query string', () {
      const state = SearchEmpty(query: 'xyz');
      expect(state.query, 'xyz');
    });

    test('SearchError holds error message', () {
      const state = SearchError('Network error');
      expect(state.message, 'Network error');
    });
  });
}
