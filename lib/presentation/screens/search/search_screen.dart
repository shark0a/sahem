import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../cubits/search/search_cubit.dart';
import '../../cubits/search/search_state.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/shimmer_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _activeFilter = AppStrings.filterAll;

  static const _filters = [
    AppStrings.filterAll,
    AppStrings.breakfast,
    AppStrings.lunch,
    AppStrings.dinner,
    AppStrings.filterVegetarian,
  ];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.searchRecipes,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSearchBar(context),
                  const SizedBox(height: 16),
                  _buildFilterChips(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) =>
                    _buildResults(context, state),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        final isLoading = state is SearchLoading;
        return Container(
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
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Icon(Icons.search, color: AppColors.textHint),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: (v) =>
                      context.read<SearchCubit>().onSearchChanged(v),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: AppStrings.searchPlaceholder,
                    hintStyle: TextStyle(
                      color: AppColors.textHint,
                      fontFamily: 'Inter',
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                  ),
                ),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              if (_controller.text.isNotEmpty && !isLoading)
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textHint),
                  onPressed: () {
                    _controller.clear();
                    context.read<SearchCubit>().clearSearch();
                  },
                )
              else if (!isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.mic_none, color: AppColors.textHint),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final filter = _filters[index];
          final isActive = _activeFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isActive
                        ? AppColors.primary.withOpacity(0.3)
                        : const Color(0x0A000000),
                    blurRadius: isActive ? 12 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color:
                      isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResults(BuildContext context, SearchState state) {
    if (state is SearchInitial) {
      return const Center(
        child: Text('🍽️  Search for any recipe',
            style: TextStyle(
                fontFamily: 'Inter', color: AppColors.textSecondary)),
      );
    }

    if (state is SearchLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: ShimmerGrid(count: 6),
      );
    }

    if (state is SearchEmpty) {
      return EmptyStateWidget(
        title: AppStrings.noRecipesFound,
        subtitle: AppStrings.tryAnother,
        icon: Icons.no_food,
        emoji: '❓',
      );
    }

    if (state is SearchError) {
      return EmptyStateWidget(
        title: 'Something went wrong',
        subtitle: state.message,
        icon: Icons.error_outline,
        emoji: '😕',
      );
    }

    if (state is SearchLoaded) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: state.recipes.length,
        itemBuilder: (context, index) {
          final recipe = state.recipes[index];
          return GestureDetector(
            onTap: () => context.push(
              '/recipe/${recipe.id}',
              extra: recipe,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RecipeCard(
                    recipe: recipe,
                    variant: RecipeCardVariant.grid,
                    onTap: () => context.push(
                      '/recipe/${recipe.id}',
                      extra: recipe,
                    ),
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
