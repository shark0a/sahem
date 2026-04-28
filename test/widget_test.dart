import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sahem/core/di/injection.dart';
import 'package:sahem/core/network/dio_client.dart';
import 'package:sahem/core/router/app_router.dart';
import 'package:sahem/core/services/network_info.dart';
import 'package:sahem/core/services/location_service.dart';
import 'package:sahem/core/utils/context_helper.dart';
import 'package:sahem/core/constants/api_endpoints.dart';
import 'package:sahem/data/datasources/recipe_remote_datasource.dart';
import 'package:sahem/data/datasources/recipe_local_datasource.dart';
import 'package:sahem/data/repositories/recipe_repository_impl.dart';
import 'package:sahem/domain/repositories/recipe_repository.dart';
import 'package:sahem/domain/usecases/get_suggested_recipes.dart';
import 'package:sahem/domain/usecases/search_recipes.dart';
import 'package:sahem/domain/usecases/get_favorites.dart';
import 'package:sahem/domain/usecases/toggle_favorite.dart';
import 'package:sahem/Feature/Home/presentation/bloc/home_cubit.dart';
import 'package:sahem/Feature/Search/presentation/bloc/search_cubit.dart';
import 'package:sahem/Feature/Favorites/presentation/bloc/favorites_cubit.dart';
import 'package:sahem/sahem_app.dart';

void main() {
  testWidgets('App smoke test - verifies app starts without crashing',
      (WidgetTester tester) async {
    // Run Hive init in runAsync to avoid test fake async issues
    await tester.runAsync(() async {
      final tempDir = await Directory.systemTemp.createTemp('hive_test_');
      Hive.init(tempDir.path);

      // Register HiveInterface
      if (!sl.isRegistered<HiveInterface>()) {
        sl.registerSingleton<HiveInterface>(Hive);
      }
    });

    // Register app-level lazy singletons
    if (!sl.isRegistered<AppRouter>()) {
      sl.registerLazySingleton<AppRouter>(() => AppRouter());
    }

    // Register required services and cubits as lazy singletons
    // These prevent "not registered" errors when SplashScreen accesses them
    if (!sl.isRegistered<LocationService>()) {
      sl.registerLazySingleton<LocationService>(() => LocationService());
    }
    if (!sl.isRegistered<NetworkInfo>()) {
      sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl<Connectivity>()));
    }
    if (!sl.isRegistered<ContextHelper>()) {
      sl.registerLazySingleton<ContextHelper>(() => ContextHelper());
    }
    if (!sl.isRegistered<Connectivity>()) {
      sl.registerLazySingleton<Connectivity>(() => Connectivity());
    }
    if (!sl.isRegistered<Dio>()) {
      sl.registerLazySingleton<Dio>(() => DioClient.create(baseUrl: ApiEndpoints.baseUrl));
    }
    if (!sl.isRegistered<RecipeRemoteDatasource>()) {
      sl.registerLazySingleton<RecipeRemoteDatasource>(() => RecipeRemoteDatasource(sl<Dio>()));
    }
    if (!sl.isRegistered<RecipeLocalDatasource>()) {
      sl.registerLazySingleton<RecipeLocalDatasource>(() => RecipeLocalDatasource(sl<HiveInterface>()));
    }
    if (!sl.isRegistered<RecipeRepository>()) {
      sl.registerLazySingleton<RecipeRepository>(() => RecipeRepositoryImpl(
        sl<RecipeRemoteDatasource>(),
        sl<RecipeLocalDatasource>(),
        sl<NetworkInfo>(),
      ));
    }
    if (!sl.isRegistered<GetSuggestedRecipes>()) {
      sl.registerLazySingleton<GetSuggestedRecipes>(() => GetSuggestedRecipes(sl<RecipeRepository>()));
    }
    if (!sl.isRegistered<SearchRecipes>()) {
      sl.registerLazySingleton<SearchRecipes>(() => SearchRecipes(sl<RecipeRepository>()));
    }
    if (!sl.isRegistered<GetFavorites>()) {
      sl.registerLazySingleton<GetFavorites>(() => GetFavorites(sl<RecipeRepository>()));
    }
    if (!sl.isRegistered<ToggleFavorite>()) {
      sl.registerLazySingleton<ToggleFavorite>(() => ToggleFavorite(sl<RecipeRepository>()));
    }
    if (!sl.isRegistered<HomeCubit>()) {
      sl.registerLazySingleton<HomeCubit>(() => HomeCubit(
        sl<GetSuggestedRecipes>(),
        sl<LocationService>(),
        sl<NetworkInfo>(),
        sl<ContextHelper>(),
      ));
    }
    if (!sl.isRegistered<SearchCubit>()) {
      sl.registerLazySingleton<SearchCubit>(() => SearchCubit(
        sl<SearchRecipes>(),
        sl<GetSuggestedRecipes>(),
      ));
    }
    if (!sl.isRegistered<FavoritesCubit>()) {
      sl.registerLazySingleton<FavoritesCubit>(() => FavoritesCubit(
        sl<GetFavorites>(),
        sl<ToggleFavorite>(),
      ));
    }

    // Build our app
    await tester.pumpWidget(const SahemApp());

    // The splash screen shows for 1.5s then navigates
    // Advance time by 1.5 seconds so the timer fires
    await tester.pump(const Duration(milliseconds: 1500));

    // The app should still be showing SahemApp
    expect(find.byType(SahemApp), findsOneWidget);
  });
}