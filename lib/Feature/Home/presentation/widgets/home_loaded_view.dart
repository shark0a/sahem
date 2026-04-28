import 'package:flutter/material.dart';
import 'package:sahem/Feature/Home/presentation/bloc/home_state.dart';
import 'package:sahem/Feature/Home/presentation/widgets/home_categories_section.dart';
import 'package:sahem/Feature/Home/presentation/widgets/home_header_section.dart';
import 'package:sahem/Feature/Home/presentation/widgets/home_suggested_section.dart';

class HomeLoadedView extends StatelessWidget {
  final HomeLoaded state;

  const HomeLoadedView({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 60),
        HomeHeaderSection(state: state),
        const SizedBox(height: 24),
        HomeSuggestedSection(recipes: state.recipes),
        const SizedBox(height: 24),
        const HomeCategoriesSection(),
        const SizedBox(height: 100),
      ],
    );
  }
}
