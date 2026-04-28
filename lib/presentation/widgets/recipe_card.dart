import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/recipe.dart';
import 'animated_heart_button.dart';
import 'shimmer_card.dart';

enum RecipeCardVariant { large, grid }

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final bool isFavorited;
  final VoidCallback? onFavoriteToggled;
  final VoidCallback? onTap;
  final RecipeCardVariant variant;
  final String? flag;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.isFavorited = false,
    this.onFavoriteToggled,
    this.onTap,
    this.variant = RecipeCardVariant.large,
    this.flag,
  });

  @override
  Widget build(BuildContext context) {
    final isLarge = variant == RecipeCardVariant.large;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isLarge ? 288 : double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.surface,
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Image
              SizedBox(
                height: 192,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: recipe.thumbnailUrl ?? '',
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const ShimmerCard(height: 192),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.restaurant,
                        size: 48, color: AppColors.textHint),
                  ),
                ),
              ),

              // Gradient overlay + info
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xB3000000),
                        Color(0xCC000000),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 14, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            '${_estimateCookTime(recipe)} min',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.people,
                              size: 14, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            '${_estimateServings(recipe)}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Favorite button (top-left)
              Positioned(
                top: 12,
                left: 12,
                child: AnimatedHeartButton(
                  isFavorited: isFavorited,
                  onToggle: onFavoriteToggled,
                ),
              ),

              // Flag / cuisine badge (top-right)
              if (flag != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(flag!, style: const TextStyle(fontSize: 14)),
                  ),
                ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
    );
  }

  int _estimateCookTime(Recipe recipe) {
    // Estimate based on ingredient count
    return 15 + recipe.ingredients.length * 2;
  }

  int _estimateServings(Recipe recipe) {
    return 4;
  }
}
