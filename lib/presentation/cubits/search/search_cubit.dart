import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../../domain/usecases/search_recipes.dart';
import 'search_state.dart';
class SearchCubit extends Cubit<SearchState> {
  final SearchRecipes _searchRecipes;
  final _searchController = StreamController<String>();
  late final StreamSubscription<String> _subscription;

  SearchCubit(this._searchRecipes) : super(SearchInitial()) {
    _subscription = _searchController.stream
        .debounceTime(const Duration(milliseconds: 400))
        .distinct()
        .listen(_performSearch);
  }

  void onSearchChanged(String query) => _searchController.add(query);

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      emit(SearchInitial());
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

  void clearSearch() => emit(SearchInitial());

  @override
  Future<void> close() {
    _subscription.cancel();
    _searchController.close();
    return super.close();
  }
}
