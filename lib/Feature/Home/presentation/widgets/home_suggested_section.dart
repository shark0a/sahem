import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sahem/core/constants/app_colors.dart';
import 'package:sahem/core/constants/app_strings.dart';
import 'package:sahem/core/widgets/recipe_card.dart';
import 'package:sahem/domain/entities/recipe.dart';

class HomeSuggestedSection extends StatelessWidget {
  final List<Recipe> recipes;

  const HomeSuggestedSection({
    super.key,
    required this.recipes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            AppStrings.suggestedForYou,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: recipes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return RecipeCard(
                recipe: recipe,
                onTap: () => context.push(
                  '/recipe/${recipe.id}',
                  extra: recipe,
                ),
              ).animate().fadeIn(delay: (index * 60).ms);
            },
          ),
        ),
      ],
    );
  }
}
