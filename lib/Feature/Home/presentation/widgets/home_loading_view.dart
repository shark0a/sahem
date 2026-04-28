import 'package:flutter/material.dart';
import 'package:sahem/core/widgets/shimmer_card.dart';

class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 60),
        Padding(
          padding: EdgeInsets.all(20),
          child: ShimmerCard(
            height: 140,
            width: double.infinity,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ShimmerCard(height: 24, width: 180, borderRadius: 8),
        ),
        SizedBox(height: 16),
        ShimmerRecipeList(),
        SizedBox(height: 24),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ShimmerCard(height: 24, width: 160, borderRadius: 8),
        ),
        SizedBox(height: 16),
        ShimmerGrid(),
      ],
    );
  }
}
