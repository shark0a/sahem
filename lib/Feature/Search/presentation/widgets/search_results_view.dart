import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sahem/Feature/Search/presentation/bloc/search_state.dart';
import 'package:sahem/core/constants/app_colors.dart';
import 'package:sahem/core/constants/app_strings.dart';
import 'package:sahem/core/widgets/empty_state_widget.dart';
import 'package:sahem/core/widgets/recipe_card.dart';
import 'package:sahem/core/widgets/shimmer_card.dart';
import 'package:sahem/domain/entities/recipe.dart';

class SearchResultsView extends StatelessWidget {
  final SearchState state;
  final ValueChanged<Recipe> onRecipeTap;

  const SearchResultsView({
    super.key,
    required this.state,
    required this.onRecipeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (state is SearchInitial) {
      return const Center(
        child: Text(
          '🍽️  Search for any recipe',
          style: TextStyle(
            fontFamily: 'Inter',
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    if (state is SearchLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: ShimmerGrid(count: 6),
      );
    }

    if (state is SearchEmpty) {
      return const  EmptyStateWidget(
        title: AppStrings.noRecipesFound,
        subtitle: AppStrings.tryAnother,
        icon: Icons.no_food,
        emoji: '❓',
      );
    }

    if (state is SearchError) {
      final errorState = state as SearchError;
      return EmptyStateWidget(
        title: 'Something went wrong',
        subtitle: errorState.message,
        icon: Icons.error_outline,
        emoji: '😕',
      );
    }

    if (state is SearchLoaded) {
      final loadedState = state as SearchLoaded;
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: loadedState.recipes.length,
        itemBuilder: (context, index) {
          final recipe = loadedState.recipes[index];
          return GestureDetector(
            onTap: () => onRecipeTap(recipe),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RecipeCard(
                    recipe: recipe,
                    variant: RecipeCardVariant.grid,
                    onTap: () => onRecipeTap(recipe),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (index * 60).ms).slideY(begin: 0.15);
        },
      );
    }

    return const SizedBox.shrink();
  }
}
