import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sahem/core/errors/failures.dart';
import 'package:sahem/core/services/location_service.dart';
import 'package:sahem/core/services/network_info.dart';
import 'package:sahem/core/utils/context_helper.dart';
import 'package:sahem/domain/entities/recipe.dart';
import 'package:sahem/domain/usecases/get_suggested_recipes.dart';
import 'package:sahem/presentation/cubits/home/home_cubit.dart';
import 'package:sahem/presentation/cubits/home/home_state.dart';

class MockGetSuggestedRecipes extends Mock implements GetSuggestedRecipes {}
class MockLocationService extends Mock implements LocationService {}
class MockNetworkInfo extends Mock implements NetworkInfo {}
class MockContextHelper extends Mock implements ContextHelper {}

const _recipe = Recipe(
  id: '1',
  name: 'Egyptian Falafel',
  thumbnailUrl: 'https://example.com/img.jpg',
  category: 'Chicken',
  area: 'Egyptian',
  ingredients: ['falafel', 'tahini'],
  measures: ['10', '2 tbsp'],
);

void main() {
  late MockGetSuggestedRecipes mockGetSuggested;
  late MockLocationService mockLocation;
  late MockNetworkInfo mockNetworkInfo;
  late MockContextHelper mockContextHelper;

  setUp(() {
    mockGetSuggested = MockGetSuggestedRecipes();
    mockLocation = MockLocationService();
    mockNetworkInfo = MockNetworkInfo();
    mockContextHelper = MockContextHelper();

    // Default stubs
    when(() => mockContextHelper.getGreeting()).thenReturn('Good Morning');
    when(() => mockContextHelper.getMealTypeLabel()).thenReturn('Breakfast');
    when(() => mockContextHelper.getMealTypeEmoji()).thenReturn('🌅');
    when(() => mockContextHelper.getRegionCuisine(any()))
        .thenReturn('Egyptian');
    when(() => mockContextHelper.getCountryFlag(any())).thenReturn('🇪🇬');
    when(() => mockContextHelper.getCuisineCategory(any()))
        .thenReturn('Chicken');
  });

  HomeCubit buildCubit() => HomeCubit(
        mockGetSuggested,
        mockLocation,
        mockNetworkInfo,
        mockContextHelper,
      );

  group('HomeCubit', () {
    test('initial state is HomeInitial', () {
      expect(buildCubit().state, isA<HomeInitial>());
    });

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeLoaded] on success with location',
      build: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockLocation.getCountryCode())
            .thenAnswer((_) async => const Right('EG'));
        when(() => mockLocation.getCityName())
            .thenAnswer((_) async => const Right('Cairo'));
        when(() => mockGetSuggested(any()))
            .thenAnswer((_) async => const Right([_recipe]));
        return buildCubit();
      },
      act: (cubit) => cubit.loadHome(),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as HomeLoaded;
        expect(state.recipes.length, 1);
        expect(state.greeting, 'Good Morning');
        expect(state.city, 'Cairo');
        expect(state.cuisine, 'Egyptian');
        expect(state.isOffline, false);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeLoaded] with isOffline=true when offline',
      build: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(() => mockLocation.getCountryCode())
            .thenAnswer((_) async => const Left(LocationFailure()));
        when(() => mockLocation.getCityName())
            .thenAnswer((_) async => const Left(LocationFailure()));
        when(() => mockGetSuggested(any()))
            .thenAnswer((_) async => const Right([_recipe]));
        return buildCubit();
      },
      act: (cubit) => cubit.loadHome(),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as HomeLoaded;
        expect(state.isOffline, true);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeError] when recipe fetch fails online',
      build: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockLocation.getCountryCode())
            .thenAnswer((_) async => const Left(LocationFailure()));
        when(() => mockLocation.getCityName())
            .thenAnswer((_) async => const Left(LocationFailure()));
        when(() => mockGetSuggested(any()))
            .thenAnswer((_) async => const Left(ServerFailure()));
        return buildCubit();
      },
      act: (cubit) => cubit.loadHome(),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeError>(),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeOffline] when offline and fetch fails',
      build: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(() => mockLocation.getCountryCode())
            .thenAnswer((_) async => const Left(LocationFailure()));
        when(() => mockLocation.getCityName())
            .thenAnswer((_) async => const Left(LocationFailure()));
        when(() => mockGetSuggested(any()))
            .thenAnswer((_) async => const Left(CacheFailure()));
        return buildCubit();
      },
      act: (cubit) => cubit.loadHome(),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeOffline>(),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'refresh calls loadHome again',
      build: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockLocation.getCountryCode())
            .thenAnswer((_) async => const Right('EG'));
        when(() => mockLocation.getCityName())
            .thenAnswer((_) async => const Right('Cairo'));
        when(() => mockGetSuggested(any()))
            .thenAnswer((_) async => const Right([_recipe]));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadHome();
        await cubit.refresh();
      },
      verify: (_) {
        verify(() => mockGetSuggested(any())).called(2);
      },
    );
  });
}
