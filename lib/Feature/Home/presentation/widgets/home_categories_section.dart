import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sahem/Feature/Home/presentation/widgets/home_category_card.dart';
import 'package:sahem/core/constants/app_colors.dart';
import 'package:sahem/core/constants/app_strings.dart';
import 'package:sahem/core/router/app_router.dart';

class HomeCategoriesSection extends StatelessWidget {
  const HomeCategoriesSection({super.key});

  static const _categories = [
    {'emoji': '🥞', 'name': AppStrings.breakfast},
    {'emoji': '🍱', 'name': AppStrings.lunch},
    {'emoji': '🍝', 'name': AppStrings.dinner},
    {'emoji': '🍰', 'name': AppStrings.dessert},
  ];

  @override
  Widget build(BuildContext context) {
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
              return HomeCategoryCard(
                emoji: category['emoji']!,
                name: category['name']!,
                onTap: () {
                  context.go(AppRoutes.search, extra: category['name']);
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
