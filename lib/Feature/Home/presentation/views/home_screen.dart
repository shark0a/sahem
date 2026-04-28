import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sahem/Feature/Home/presentation/bloc/home_cubit.dart';
import 'package:sahem/Feature/Home/presentation/bloc/home_state.dart';
import 'package:sahem/Feature/Home/presentation/widgets/home_error_view.dart';
import 'package:sahem/Feature/Home/presentation/widgets/home_loaded_view.dart';
import 'package:sahem/Feature/Home/presentation/widgets/home_loading_view.dart';
import 'package:sahem/core/constants/app_colors.dart';
import 'package:sahem/core/widgets/bottom_nav_bar.dart';
import 'package:sahem/core/widgets/offline_banner.dart';

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
              if (state is HomeLoaded) OfflineBanner(isOffline: state.isOffline),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => context.read<HomeCubit>().refresh(),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildContent(state),
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

  Widget _buildContent(HomeState state) {
    if (state is HomeLoading) return const HomeLoadingView();
    if (state is HomeError) return HomeErrorView(message: state.message);
    if (state is HomeLoaded) return HomeLoadedView(state: state);
    if (state is HomeOffline) {
      return HomeLoadedView(
        state: HomeLoaded(
          recipes: state.cachedRecipes,
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
    return const HomeLoadingView();
  }
}
