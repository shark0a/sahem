import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) context.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Utensils icon with sparkle
            Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.restaurant,
                  size: 96,
                  color: AppColors.primary,
                )
                    .animate()
                    .scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      duration: 700.ms,
                      curve: Curves.easeOutBack,
                    )
                    .rotate(begin: -0.5, end: 0, duration: 700.ms),

                Positioned(
                  top: -8,
                  right: -8,
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 32,
                    color: AppColors.primary,
                  )
                      .animate(delay: 400.ms)
                      .scale(begin: const Offset(0, 0))
                      .fadeIn(),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // App name
            const Text(
              AppStrings.appName,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: 52,
                color: AppColors.primary,
                letterSpacing: -1,
              ),
            ).animate(delay: 500.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),

            const SizedBox(height: 12),

            // Tagline
            const Text(
              AppStrings.appTagline,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ).animate(delay: 800.ms).fadeIn(duration: 500.ms),

            const SizedBox(height: 64),

            // Loading spinner
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ).animate(delay: 1200.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
