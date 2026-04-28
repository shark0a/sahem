import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/recipe.dart';

part 'recipe_model.g.dart';

@HiveType(typeId: 0)
class RecipeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? thumbnailUrl;

  @HiveField(3)
  final String? category;

  @HiveField(4)
  final String? area;

  @HiveField(5)
  final String? instructions;

  @HiveField(6)
  final List<String> ingredients;

  @HiveField(7)
  final List<String> measures;

  @HiveField(8)
  final String? youtubeUrl;

  @HiveField(9)
  final String? tags;

  RecipeModel({
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

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    final ingredients = <String>[];
    final measures = <String>[];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(ingredient.toString().trim());
        measures.add(measure?.toString().trim() ?? '');
      }
    }

    return RecipeModel(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? '',
      thumbnailUrl: json['strMealThumb']?.toString(),
      category: json['strCategory']?.toString(),
      area: json['strArea']?.toString(),
      instructions: json['strInstructions']?.toString(),
      ingredients: ingredients,
      measures: measures,
      youtubeUrl: json['strYoutube']?.toString(),
      tags: json['strTags']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'idMeal': id,
      'strMeal': name,
      'strMealThumb': thumbnailUrl,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strYoutube': youtubeUrl,
      'strTags': tags,
    };

    for (int i = 0; i < ingredients.length; i++) {
      json['strIngredient${i + 1}'] = ingredients[i];
      json['strMeasure${i + 1}'] = i < measures.length ? measures[i] : '';
    }

    return json;
  }

  Recipe toEntity() {
    return Recipe(
      id: id,
      name: name,
      thumbnailUrl: thumbnailUrl,
      category: category,
      area: area,
      instructions: instructions,
      ingredients: ingredients,
      measures: measures,
      youtubeUrl: youtubeUrl,
      tags: tags,
    );
  }

  factory RecipeModel.fromEntity(Recipe recipe) {
    return RecipeModel(
      id: recipe.id,
      name: recipe.name,
      thumbnailUrl: recipe.thumbnailUrl,
      category: recipe.category,
      area: recipe.area,
      instructions: recipe.instructions,
      ingredients: recipe.ingredients,
      measures: recipe.measures,
      youtubeUrl: recipe.youtubeUrl,
      tags: recipe.tags,
    );
  }
}
