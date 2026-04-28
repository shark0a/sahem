import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/datasources/recipe_local_datasource.dart';
import '../../data/datasources/recipe_remote_datasource.dart';
import '../../data/models/recipe_model.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/get_suggested_recipes.dart';
import '../../domain/usecases/search_recipes.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../presentation/cubits/favorites/favorites_cubit.dart';
import '../../presentation/cubits/home/home_cubit.dart';
import '../../presentation/cubits/search/search_cubit.dart';
import '../../presentation/router/app_router.dart';
import '../constants/api_endpoints.dart';
import '../network/dio_client.dart';
import '../services/location_service.dart';
import '../services/network_info.dart';
import '../services/notification_service.dart';
import '../utils/context_helper.dart';

final sl = GetIt.instance;

// ── ENTRY POINT ────────────────────────────────────────────────────────────
/// Call once from main() before runApp().
/// Initialises only what is CRITICAL for startup (Hive).
/// Everything else is lazy-loaded on first access.
Future<void> configureDependencies() async {
  // 1. Hive — CRITICAL: must be ready before any local data is read
  await _initHive();

  // 2. Register all other services as lazy singletons
  //    (nothing is instantiated here — only factories registered)
  _registerNetwork();
  _registerServices();
  _registerDatasources();
  _registerRepository();
  _registerUseCases();
  _registerCubits();
  _registerRouter();

  debugPrint('✅ DI: configureDependencies complete');
}

// ── HIVE INIT ──────────────────────────────────────────────────────────────
Future<void> _initHive() async {
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(RecipeModelAdapter().typeId)) {
    Hive.registerAdapter(RecipeModelAdapter());
  }

  if (!Hive.isBoxOpen('favorites')) {
    await Hive.openBox<RecipeModel>('favorites');
  }
  if (!Hive.isBoxOpen('cache')) {
    await Hive.openBox<RecipeModel>('cache');
  }

  // Register the HiveInterface itself so datasources can resolve it
  if (!sl.isRegistered<HiveInterface>()) {
    sl.registerSingleton<HiveInterface>(Hive);
  }

  debugPrint('✅ DI: Hive initialised');
}

// ── NETWORK ────────────────────────────────────────────────────────────────
void _registerNetwork() {
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(
      () => DioClient.create(baseUrl: ApiEndpoints.baseUrl),
    );
  }

  if (!sl.isRegistered<Connectivity>()) {
    sl.registerLazySingleton<Connectivity>(() => Connectivity());
  }

  if (!sl.isRegistered<NetworkInfo>()) {
    sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(sl<Connectivity>()),
    );
  }
}

// ── SERVICES ───────────────────────────────────────────────────────────────
void _registerServices() {
  if (!sl.isRegistered<LocationService>()) {
    sl.registerLazySingleton<LocationService>(() => LocationService());
  }

  if (!sl.isRegistered<NotificationService>()) {
    sl.registerLazySingleton<NotificationService>(() => NotificationService());
  }

  if (!sl.isRegistered<ContextHelper>()) {
    sl.registerLazySingleton<ContextHelper>(() => ContextHelper());
  }
}

// ── DATASOURCES ────────────────────────────────────────────────────────────
void _registerDatasources() {
  if (!sl.isRegistered<RecipeRemoteDatasource>()) {
    sl.registerLazySingleton<RecipeRemoteDatasource>(
      () => RecipeRemoteDatasource(sl<Dio>()),
    );
  }

  if (!sl.isRegistered<RecipeLocalDatasource>()) {
    sl.registerLazySingleton<RecipeLocalDatasource>(
      () => RecipeLocalDatasource(sl<HiveInterface>()),
    );
  }
}

// ── REPOSITORY ─────────────────────────────────────────────────────────────
void _registerRepository() {
  if (!sl.isRegistered<RecipeRepository>()) {
    sl.registerLazySingleton<RecipeRepository>(
      () => RecipeRepositoryImpl(
        sl<RecipeRemoteDatasource>(),
        sl<RecipeLocalDatasource>(),
        sl<NetworkInfo>(),
      ),
    );
  }
}

// ── USE CASES ──────────────────────────────────────────────────────────────
/// UseCases are registered as factories — new instance each call,
/// matching the  pattern from the spec.
void _registerUseCases() {
  if (!sl.isRegistered<GetSuggestedRecipes>()) {
    sl.registerFactory<GetSuggestedRecipes>(
      () => GetSuggestedRecipes(sl<RecipeRepository>()),
    );
  }

  if (!sl.isRegistered<SearchRecipes>()) {
    sl.registerFactory<SearchRecipes>(
      () => SearchRecipes(sl<RecipeRepository>()),
    );
  }

  if (!sl.isRegistered<ToggleFavorite>()) {
    sl.registerFactory<ToggleFavorite>(
      () => ToggleFavorite(sl<RecipeRepository>()),
    );
  }

  if (!sl.isRegistered<GetFavorites>()) {
    sl.registerFactory<GetFavorites>(
      () => GetFavorites(sl<RecipeRepository>()),
    );
  }
}

// ── CUBITS ─────────────────────────────────────────────────────────────────
/// Cubits are factories — a fresh instance is created per screen,
/// then disposed when the screen is removed from the widget tree.
void _registerCubits() {
  if (!sl.isRegistered<HomeCubit>()) {
    sl.registerFactory<HomeCubit>(
      () => HomeCubit(
        sl<GetSuggestedRecipes>(),
        sl<LocationService>(),
        sl<NetworkInfo>(),
        sl<ContextHelper>(),
      ),
    );
  }

  if (!sl.isRegistered<SearchCubit>()) {
    sl.registerFactory<SearchCubit>(
      () => SearchCubit(sl<SearchRecipes>()),
    );
  }

  if (!sl.isRegistered<FavoritesCubit>()) {
    sl.registerFactory<FavoritesCubit>(
      () => FavoritesCubit(
        sl<GetFavorites>(),
        sl<ToggleFavorite>(),
      ),
    );
  }
}

// ── ROUTER ─────────────────────────────────────────────────────────────────
void _registerRouter() {
  if (!sl.isRegistered<AppRouter>()) {
    sl.registerLazySingleton<AppRouter>(() => AppRouter());
  }
}
