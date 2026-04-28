import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sahem/Feature/Home/presentation/bloc/home_cubit.dart';
import 'package:sahem/core/constants/app_colors.dart';
import 'package:sahem/core/widgets/empty_state_widget.dart';

class HomeErrorView extends StatelessWidget {
  final String message;

  const HomeErrorView({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
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
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Try Again',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ),
    );
  }
}
