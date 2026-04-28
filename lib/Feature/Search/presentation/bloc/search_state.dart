import 'package:equatable/equatable.dart';
import 'package:sahem/domain/entities/recipe.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Recipe> recipes;
  final String query;

  const SearchLoaded(this.recipes, {this.query = ''});

  @override
  List<Object?> get props => [recipes, query];
}

class SearchEmpty extends SearchState {
  final String query;
  const SearchEmpty({this.query = ''});

  @override
  List<Object?> get props => [query];
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
