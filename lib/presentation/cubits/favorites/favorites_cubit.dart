import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/recipe.dart';
import '../../../domain/usecases/get_favorites.dart';
import '../../../domain/usecases/toggle_favorite.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final GetFavorites _getFavorites;
  final ToggleFavorite _toggleFavorite;

  FavoritesCubit(this._getFavorites, this._toggleFavorite)
      : super(FavoritesInitial());

  Future<void> loadFavorites() async {
    emit(FavoritesLoading());
    final result = await _getFavorites();
    result.fold(
      (failure) => emit(FavoritesError(failure.message)),
      (favorites) => emit(FavoritesLoaded(favorites)),
    );
  }

  Future<void> removeFromFavorites(Recipe recipe) async {
    final result = await _toggleFavorite(recipe);
    result.fold(
      (failure) => emit(FavoritesError(failure.message)),
      (_) => loadFavorites(),
    );
  }
}
