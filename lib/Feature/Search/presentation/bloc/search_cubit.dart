import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'package:sahem/domain/usecases/get_suggested_recipes.dart';
import 'package:sahem/domain/usecases/search_recipes.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRecipes _searchRecipes;
  final GetSuggestedRecipes _getSuggestedRecipes;
  final _searchController = StreamController<String>();
  late final StreamSubscription<String> _subscription;
  String? _activeCategory;

  SearchCubit(
    this._searchRecipes,
    this._getSuggestedRecipes, {
    String? initialCategory,
  }) : super(SearchInitial()) {
    final trimmedCategory = initialCategory?.trim();
    _activeCategory = trimmedCategory == null || trimmedCategory.isEmpty
        ? null
        : trimmedCategory;

    _subscription = _searchController.stream
        .debounceTime(const Duration(milliseconds: 400))
        .distinct()
        .listen(_performSearch);

    if (_activeCategory != null) {
      Future.microtask(() => loadCategory(_activeCategory!));
    }
  }

  void onSearchChanged(String query) => _searchController.add(query);

  Future<void> loadCategory(String category) async {
    final selectedCategory = category.trim();
    if (selectedCategory.isEmpty) {
      emit(SearchInitial());
      return;
    }

    _activeCategory = selectedCategory;
    emit(SearchLoading());

    final result = await _getSuggestedRecipes(selectedCategory);
    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (recipes) => recipes.isEmpty
          ? emit(SearchEmpty(query: selectedCategory))
          : emit(SearchLoaded(recipes, query: selectedCategory)),
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      if (_activeCategory != null) {
        await loadCategory(_activeCategory!);
      } else {
        emit(SearchInitial());
      }
      return;
    }

    emit(SearchLoading());

    final result = await _searchRecipes(query.trim());

    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (recipes) => recipes.isEmpty
          ? emit(SearchEmpty(query: query))
          : emit(SearchLoaded(recipes, query: query)),
    );
  }

  Future<void> clearSearch() async {
    if (_activeCategory != null) {
      await loadCategory(_activeCategory!);
      return;
    }
    emit(SearchInitial());
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    _searchController.close();
    return super.close();
  }
}
