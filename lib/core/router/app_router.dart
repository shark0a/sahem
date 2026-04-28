import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sahem/Feature/Detail/presentation/views/recipe_detail_screen.dart';
import 'package:sahem/Feature/Favorites/presentation/bloc/favorites_cubit.dart';
import 'package:sahem/Feature/Favorites/presentation/views/favorites_screen.dart';
import 'package:sahem/Feature/Home/presentation/bloc/home_cubit.dart';
import 'package:sahem/Feature/Home/presentation/views/home_screen.dart';
import 'package:sahem/Feature/Search/presentation/bloc/search_cubit.dart';
import 'package:sahem/Feature/Search/presentation/views/search_screen.dart';
import 'package:sahem/Feature/Splash/presentation/views/splash_screen.dart';
import 'package:sahem/core/di/injection.dart';
import 'package:sahem/core/utils/context_helper.dart';
import 'package:sahem/domain/entities/recipe.dart';
import 'package:sahem/domain/usecases/get_suggested_recipes.dart';
import 'package:sahem/domain/usecases/search_recipes.dart';

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
          builder: (_, state) {
            final initialCategory = _resolveInitialSearchCategory(state.extra);

            return BlocProvider<SearchCubit>(
              create: (_) => SearchCubit(
                sl<SearchRecipes>(),
                sl<GetSuggestedRecipes>(),
                initialCategory: initialCategory,
              ),
              child: SearchScreen(initialCategory: initialCategory),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.favorites,
          name: 'favorites',
          builder: (_, __) => BlocProvider<FavoritesCubit>.value(
            value: sl<FavoritesCubit>()..loadFavorites(),
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
  static const String splash = '/splash';
  static const String home = '/';
  static const String search = '/search';
  static const String favorites = '/favorites';
}

String _resolveInitialSearchCategory(Object? extra) {
  final category = extra is String ? extra.trim() : '';
  if (category.isNotEmpty) {
    switch (category.toLowerCase()) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Chicken';
      case 'dinner':
        return 'Beef';
      case 'vegetarian':
        return 'Vegetarian';
      case 'chicken':
        return 'Chicken';
      case 'beef':
        return 'Beef';
      case 'dessert':
        return 'Dessert';
      default:
        return category;
    }
  }

  return sl<ContextHelper>().getCuisineCategory('');
}
