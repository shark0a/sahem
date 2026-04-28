import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sahem/core/services/location_service.dart';
import 'package:sahem/core/services/network_info.dart';
import 'package:sahem/core/utils/context_helper.dart';
import 'package:sahem/domain/usecases/get_suggested_recipes.dart';
import 'home_state.dart';
class HomeCubit extends Cubit<HomeState> {
  final GetSuggestedRecipes _getSuggestedRecipes;
  final LocationService _locationService;
  final NetworkInfo _networkInfo;
  final ContextHelper _contextHelper;

  HomeCubit(
    this._getSuggestedRecipes,
    this._locationService,
    this._networkInfo,
    this._contextHelper,
  ) : super(HomeInitial());

  Future<void> loadHome() async {
    emit(HomeLoading());

    // Determine context
    final greeting = _contextHelper.getGreeting();
    final mealType = _contextHelper.getMealTypeLabel();
    final mealEmoji = _contextHelper.getMealTypeEmoji();
    final isOnline = await _networkInfo.isConnected;

    // Get location info
    String city = 'Your Location';
    String cuisine = 'International';
    String countryFlag = '🌍';
    String category = _contextHelper.getCuisineCategory('');

    final locationResult = await _locationService.getCountryCode();
    locationResult.fold(
      (_) {}, // silently use defaults
      (countryCode) {
        cuisine = _contextHelper.getRegionCuisine(countryCode);
        countryFlag = _contextHelper.getCountryFlag(countryCode);
        category = _contextHelper.getCuisineCategory(countryCode);
      },
    );

    final cityResult = await _locationService.getCityName();
    cityResult.fold((_) {}, (c) => city = c);

    // Fetch recipes
    final result = await _getSuggestedRecipes(category);

    result.fold(
      (failure) {
        if (!isOnline) {
          emit(HomeOffline(const []));
        } else {
          emit(HomeError(failure.message));
        }
      },
      (recipes) {
        emit(HomeLoaded(
          recipes: recipes,
          mealType: mealType,
          mealEmoji: mealEmoji,
          greeting: greeting,
          city: city,
          cuisine: cuisine,
          countryFlag: countryFlag,
          isOffline: !isOnline,
        ));
      },
    );
  }

  Future<void> refresh() => loadHome();
}
