import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sahem/Feature/Favorites/presentation/bloc/favorites_cubit.dart';
import 'package:sahem/Feature/Favorites/presentation/bloc/favorites_state.dart';
import 'package:sahem/core/constants/app_colors.dart';
import 'package:sahem/core/constants/app_strings.dart';
import 'package:sahem/core/widgets/bottom_nav_bar.dart';
import 'package:sahem/core/widgets/empty_state_widget.dart';
import 'package:sahem/core/widgets/shimmer_card.dart';
import 'package:sahem/domain/entities/recipe.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                AppStrings.mySavedRecipes,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<FavoritesCubit, FavoritesState>(
                builder: (context, state) => _buildBody(context, state),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildBody(BuildContext context, FavoritesState state) {
    if (state is FavoritesLoading) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => const ShimmerCard(height: 88, borderRadius: 16),
      );
    }

    if (state is FavoritesError) {
      return EmptyStateWidget(
        title: 'Error loading favorites',
        subtitle: state.message,
        icon: Icons.error_outline,
      );
    }

    if (state is FavoritesLoaded) {
      if (state.favorites.isEmpty) {
        return EmptyStateWidget(
          title: AppStrings.noFavoritesYet,
          subtitle: AppStrings.emptyFavoritesSubtitle,
          icon: Icons.favorite_outline,
          emoji: '💔',
          action: ElevatedButton(
            onPressed: () => context.go('/'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: const Text(
              'Explore Recipes',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700),
            ),
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: state.favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final recipe = state.favorites[index];
                return _FavoriteItem(
                  recipe: recipe,
                  onDelete: () => context
                      .read<FavoritesCubit>()
                      .removeFromFavorites(recipe),
                  onTap: () => context.push(
                    '/recipe/${recipe.id}',
                    extra: recipe,
                  ),
                ).animate().fadeIn(delay: (index * 60).ms).slideX(begin: -0.1);
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              AppStrings.swipeToDelete,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _FavoriteItem extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _FavoriteItem({
    required this.recipe,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(recipe.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: recipe.thumbnailUrl ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      const ShimmerCard(height: 80, width: 80, borderRadius: 0),
                  errorWidget: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.surfaceVariant,
                    child:
                        const Icon(Icons.restaurant, color: AppColors.textHint),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipe.displayArea} Cuisine',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.favorite,
                    color: AppColors.heartActive, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
