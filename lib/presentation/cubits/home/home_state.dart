import 'package:equatable/equatable.dart';
import '../../../domain/entities/recipe.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Recipe> recipes;
  final String mealType;
  final String mealEmoji;
  final String greeting;
  final String city;
  final String cuisine;
  final String countryFlag;
  final bool isOffline;

  const HomeLoaded({
    required this.recipes,
    required this.mealType,
    required this.mealEmoji,
    required this.greeting,
    required this.city,
    required this.cuisine,
    required this.countryFlag,
    this.isOffline = false,
  });

  HomeLoaded copyWith({
    List<Recipe>? recipes,
    String? mealType,
    String? mealEmoji,
    String? greeting,
    String? city,
    String? cuisine,
    String? countryFlag,
    bool? isOffline,
  }) {
    return HomeLoaded(
      recipes: recipes ?? this.recipes,
      mealType: mealType ?? this.mealType,
      mealEmoji: mealEmoji ?? this.mealEmoji,
      greeting: greeting ?? this.greeting,
      city: city ?? this.city,
      cuisine: cuisine ?? this.cuisine,
      countryFlag: countryFlag ?? this.countryFlag,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [
        recipes,
        mealType,
        mealEmoji,
        greeting,
        city,
        cuisine,
        countryFlag,
        isOffline,
      ];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeOffline extends HomeState {
  final List<Recipe> cachedRecipes;
  const HomeOffline(this.cachedRecipes);

  @override
  List<Object?> get props => [cachedRecipes];
}
