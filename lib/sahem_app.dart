import 'package:flutter/material.dart';
import 'package:sahem/core/constants/app_strings.dart';
import 'package:sahem/core/constants/app_theme.dart';
import 'package:sahem/core/di/injection.dart';
import 'package:sahem/core/router/app_router.dart';

class SahemApp extends StatelessWidget {
  const SahemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: sl<AppRouter>().router,
    );
  }
}
