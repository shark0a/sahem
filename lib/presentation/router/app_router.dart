import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/recipe.dart';
import '../cubits/favorites/favorites_cubit.dart';
import '../cubits/home/home_cubit.dart';
import '../cubits/search/search_cubit.dart';
import '../screens/detail/recipe_detail_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/splash/splash_screen.dart';

class AppRouter {
  late final GoRouter router;

  AppRouter() {
    router = GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (_, __) => BlocProvider<HomeCubit>(
            create: (_) => sl<HomeCubit>()..loadHome(),
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.search,
          name: 'search',
          builder: (_, __) => BlocProvider<SearchCubit>(
            create: (_) => sl<SearchCubit>(),
            child: const SearchScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.favorites,
          name: 'favorites',
          builder: (_, __) => BlocProvider<FavoritesCubit>(
            create: (_) => sl<FavoritesCubit>()..loadFavorites(),
            child: const FavoritesScreen(),
          ),
        ),
        GoRoute(
          path: '/recipe/:id',
          name: 'detail',
          builder: (_, state) {
            final recipe = state.extra as Recipe;
            return RecipeDetailScreen(recipe: recipe);
          },
        ),
      ],
      errorBuilder: (_, state) => Scaffold(
        body: Center(child: Text('Route not found: ${state.uri}')),
      ),
    );
  }
}

abstract class AppRoutes {
  static const String splash    = '/splash';
  static const String home      = '/';
  static const String search    = '/search';
  static const String favorites = '/favorites';
}
