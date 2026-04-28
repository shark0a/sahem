import 'package:flutter/material.dart';
import 'package:sahem/core/widgets/shimmer_card.dart';

class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 60),
        const Padding(
          padding: EdgeInsets.all(20),
          child: ShimmerCard(
            height: 140,
            width: double.infinity,
            borderRadius: 20,
          ),
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
}
