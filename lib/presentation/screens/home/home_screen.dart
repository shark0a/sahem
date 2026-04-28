import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/recipe.dart';
import '../../cubits/home/home_cubit.dart';
import '../../cubits/home/home_state.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/shimmer_card.dart';
import '../../router/app_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return Column(
            children: [
              // Offline banner at top
              if (state is HomeLoaded)
                OfflineBanner(isOffline: state.isOffline),

              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => context.read<HomeCubit>().refresh(),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildContent(context, state),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildContent(BuildContext context, HomeState state) {
    if (state is HomeLoading) return _buildLoading();
    if (state is HomeError) return _buildError(context, state.message);
    if (state is HomeLoaded) return _buildLoaded(context, state);
    if (state is HomeOffline) return _buildOfflineContent(context, state.cachedRecipes);
    return _buildLoading();
  }

  Widget _buildLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 60), // status bar
        const Padding(
          padding: EdgeInsets.all(20),
          child: ShimmerCard(height: 140, width: double.infinity, borderRadius: 20),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ShimmerCard(height: 24, width: 180, borderRadius: 8),
        ),
        const SizedBox(height: 16),
        const ShimmerRecipeList(),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ShimmerCard(height: 24, width: 160, borderRadius: 8),
        ),
        const SizedBox(height: 16),
        const ShimmerGrid(count: 4),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: EmptyStateWidget(
        title: 'Oops!',
        subtitle: message,
        icon: Icons.error_outline,
        emoji: '😕',
        action: ElevatedButton(
          onPressed: () => context.read<HomeCubit>().refresh(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Try Again',
              style: TextStyle(color: Colors.white, fontFamily: 'Nunito')),
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, HomeLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 60),
        _buildHeader(state),
        const SizedBox(height: 24),
        _buildSuggestedSection(context, state.recipes),
        const SizedBox(height: 24),
        _buildCategoriesSection(context),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildOfflineContent(BuildContext context, List<Recipe> recipes) {
    return _buildLoaded(
      context,
      HomeLoaded(
        recipes: recipes,
        mealType: 'Cached',
        mealEmoji: '📦',
        greeting: 'Welcome Back',
        city: 'Offline',
        cuisine: 'International',
        countryFlag: '🌍',
        isOffline: true,
      ),
    );
  }

  Widget _buildHeader(HomeLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.headerGradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${state.greeting}, Chef 👋',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE0B2), Color(0xFFFFF3E0)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.mealEmoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    '${state.mealType} Time',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${state.city} ${state.countryFlag} — ${state.cuisine} Cuisine',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedSection(BuildContext context, List<Recipe> recipes) {
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
              );
            },
          ),
        ),
      ],
    );
  }

  static const _categories = [
    {'emoji': '🥞', 'name': AppStrings.breakfast},
    {'emoji': '🍱', 'name': AppStrings.lunch},
    {'emoji': '🍝', 'name': AppStrings.dinner},
    {'emoji': '🍰', 'name': AppStrings.dessert},
  ];

  Widget _buildCategoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            AppStrings.popularCategories,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _CategoryCard(
                emoji: category['emoji']!,
                name: category['name']!,
                onTap: () {
                  // Navigate to search with pre-filled category
                  context.go(AppRoutes.search);
                },
              ).animate().fadeIn(delay: (index * 80).ms).scale(
                    begin: const Offset(0.9, 0.9),
                    delay: (index * 80).ms,
                  );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String emoji;
  final String name;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.emoji,
    required this.name,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _pressed
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.cardShadow,
                blurRadius: _pressed ? 24 : 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.emoji,
                  style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text(
                widget.name,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
