import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final String id;
  final String name;
  final String? thumbnailUrl;
  final String? category;
  final String? area;
  final String? instructions;
  final List<String> ingredients;
  final List<String> measures;
  final String? youtubeUrl;
  final String? tags;

  const Recipe({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.category,
    this.area,
    this.instructions,
    required this.ingredients,
    required this.measures,
    this.youtubeUrl,
    this.tags,
  });

  List<Map<String, String>> get ingredientMeasurePairs {
    return List.generate(
      ingredients.length,
      (i) => {
        'ingredient': ingredients[i],
        'measure': i < measures.length ? measures[i] : '',
      },
    );
  }

  String get displayArea => area ?? 'International';

  @override
  List<Object?> get props => [
        id,
        name,
        thumbnailUrl,
        category,
        area,
        ingredients,
        measures,
      ];
}
