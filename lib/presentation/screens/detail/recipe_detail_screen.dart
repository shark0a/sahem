import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/recipe.dart';
import '../../../domain/usecases/toggle_favorite.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<int> _checkedIngredients = {};
  bool _isFavorited = false;
  final _toggleFavorite = sl<ToggleFavorite>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleFavoriteToggle() async {
    setState(() => _isFavorited = !_isFavorited);
    await _toggleFavorite(widget.recipe);
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final instructions = _parseInstructions(recipe.instructions ?? '');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroImage(context, recipe),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 26,
                          color: AppColors.textPrimary,
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 16),
                      _buildStats(recipe).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 20),
                      _buildTabBar(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  child: AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _tabController.index == 0
                            ? _buildIngredients(recipe)
                            : _buildInstructions(instructions),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: _circleButton(
              child: const Icon(Icons.arrow_back,
                  size: 20, color: AppColors.textPrimary),
              onTap: () => Navigator.of(context).pop(),
            ),
          ),

          // Start Cooking FAB
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () => _startCooking(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                shadowColor: AppColors.primaryShadow,
              ),
              child: const Text(
                AppStrings.startCooking,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Favorite FAB
          Positioned(
            bottom: 90,
            right: 20,
            child: GestureDetector(
              onTap: _handleFavoriteToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _isFavorited ? AppColors.heartActive : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isFavorited
                              ? AppColors.heartActive
                              : AppColors.primary)
                          .withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context, Recipe recipe) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: SizedBox(
        height: 280,
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl: recipe.thumbnailUrl ?? '',
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: AppColors.surfaceVariant),
          errorWidget: (_, __, ___) => Container(
            color: AppColors.surfaceVariant,
            child: const Icon(Icons.restaurant,
                size: 64, color: AppColors.textHint),
          ),
        ),
      ),
    );
  }

  Widget _buildStats(Recipe recipe) {
    return Row(
      children: [
        _statItem(Icons.access_time_outlined,
            '${15 + recipe.ingredients.length * 2} min'),
        const SizedBox(width: 24),
        _statItem(Icons.local_fire_department_outlined, '320 cal'),
        const SizedBox(width: 24),
        _statItem(Icons.people_outline, '4 ${AppStrings.servings}'),
      ],
    );
  }

  Widget _statItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        onTap: (_) => setState(() {}),
        tabs: const [
          Tab(text: AppStrings.ingredients),
          Tab(text: AppStrings.instructions),
        ],
      ),
    );
  }

  Widget _buildIngredients(Recipe recipe) {
    final pairs = recipe.ingredientMeasurePairs;
    if (pairs.isEmpty) {
      return const Text(
        'No ingredients available.',
        style: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textSecondary,
        ),
      );
    }

    return Column(
      children: List.generate(pairs.length, (index) {
        final pair = pairs[index];
        final isChecked = _checkedIngredients.contains(index);
        return Padding(
          padding: EdgeInsets.only(bottom: index == pairs.length - 1 ? 0 : 10),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isChecked) {
                  _checkedIngredients.remove(index);
                } else {
                  _checkedIngredients.add(index);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isChecked
                    ? AppColors.primary.withOpacity(0.06)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isChecked
                      ? AppColors.primary.withOpacity(0.3)
                      : Colors.transparent,
                ),
                boxShadow: isChecked
                    ? []
                    : const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isChecked ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isChecked ? AppColors.primary : AppColors.textHint,
                        width: 2,
                      ),
                    ),
                    child: isChecked
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      pair['ingredient'] ?? '',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: isChecked
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                        decoration:
                            isChecked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  Text(
                    pair['measure'] ?? '',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (index * 40).ms),
        );
      }),
    );
  }

  Widget _buildInstructions(List<String> steps) {
    if (steps.isEmpty) {
      return const Center(
        child: Text(
          'No instructions available.',
          style: TextStyle(
              fontFamily: 'Inter', color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: List.generate(steps.length, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == steps.length - 1 ? 0 : 16),
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  steps[index],
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: (index * 60).ms).slideX(begin: 0.1),
        );
      }),
    );
  }

  List<String> _parseInstructions(String raw) {
    if (raw.isEmpty) return [];
    return raw
        .split(RegExp(r'\r?\n'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Widget _circleButton(
      {required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  void _startCooking(BuildContext context) {
    _tabController.animateTo(1);
  }
}
