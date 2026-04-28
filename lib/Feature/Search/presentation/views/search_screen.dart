import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sahem/Feature/Search/presentation/bloc/search_cubit.dart';
import 'package:sahem/Feature/Search/presentation/bloc/search_state.dart';
import 'package:sahem/Feature/Search/presentation/widgets/search_bar_section.dart';
import 'package:sahem/Feature/Search/presentation/widgets/search_filter_chips.dart';
import 'package:sahem/Feature/Search/presentation/widgets/search_results_view.dart';
import 'package:sahem/core/constants/app_colors.dart';
import 'package:sahem/core/constants/app_strings.dart';
import 'package:sahem/core/di/injection.dart';
import 'package:sahem/core/utils/context_helper.dart';
import 'package:sahem/core/widgets/bottom_nav_bar.dart';

class SearchScreen extends StatefulWidget {
  final String initialCategory;

  const SearchScreen({
    super.key,
    required this.initialCategory,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _activeFilter = AppStrings.filterAll;
  String _selectedCategory = '';
  String? _searchRestoreFilter;

  static const _filters = [
    AppStrings.filterAll,
    AppStrings.breakfast,
    AppStrings.lunch,
    AppStrings.dinner,
    AppStrings.filterVegetarian,
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory.trim().isEmpty
        ? sl<ContextHelper>().getCuisineCategory('')
        : widget.initialCategory.trim();
    _activeFilter = _categoryToFilter(_selectedCategory);
    _searchRestoreFilter = _activeFilter;
  }

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
                  BlocBuilder<SearchCubit, SearchState>(
                    builder: (context, state) {
                      final isLoading = state is SearchLoading;
                      return SearchBarSection(
                        controller: _controller,
                        focusNode: _focusNode,
                        isLoading: isLoading,
                        onChanged: _handleSearchChanged,
                        onClear: _handleClearSearch,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SearchFilterChips(
                    filters: _filters,
                    activeFilter: _activeFilter,
                    onSelected: _handleFilterSelected,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  return SearchResultsView(
                    state: state,
                    onRecipeTap: (recipe) => context.push(
                      '/recipe/${recipe.id}',
                      extra: recipe,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  void _handleSearchChanged(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _activeFilter =
            _searchRestoreFilter ?? _categoryToFilter(_selectedCategory);
        _searchRestoreFilter = _activeFilter;
      } else {
        _searchRestoreFilter ??= _activeFilter;
        _activeFilter = AppStrings.filterAll;
      }
    });
    context.read<SearchCubit>().onSearchChanged(value);
  }

  void _handleClearSearch() {
    _controller.clear();
    setState(() {
      _activeFilter =
          _searchRestoreFilter ?? _categoryToFilter(_selectedCategory);
      _searchRestoreFilter = _activeFilter;
    });
    context.read<SearchCubit>().clearSearch();
  }

  void _handleFilterSelected(String filter) {
    setState(() {
      _activeFilter = filter;
      _searchRestoreFilter = filter;
    });
    _controller.clear();
    _focusNode.unfocus();

    final cubit = context.read<SearchCubit>();
    if (filter == AppStrings.filterAll) {
      cubit.clearSearch();
      return;
    }

    final category = _filterToCategory(filter);
    cubit.loadCategory(category);
    setState(() {
      _selectedCategory = category;
    });
  }

  String _filterToCategory(String filter) {
    switch (filter) {
      case AppStrings.breakfast:
        return 'Breakfast';
      case AppStrings.lunch:
        return 'Chicken';
      case AppStrings.dinner:
        return 'Beef';
      case AppStrings.filterVegetarian:
        return 'Vegetarian';
      default:
        return filter;
    }
  }

  String _categoryToFilter(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast':
        return AppStrings.breakfast;
      case 'chicken':
        return AppStrings.lunch;
      case 'beef':
        return AppStrings.dinner;
      case 'vegetarian':
        return AppStrings.filterVegetarian;
      default:
        return AppStrings.filterAll;
    }
  }
}
