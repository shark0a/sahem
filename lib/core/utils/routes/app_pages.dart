import 'package:go_router/go_router.dart';
import 'package:sahem/Feature/splash/presentation/screens/splash_screen.dart';
import 'package:sahem/core/utils/routes/app_router.dart';

class AppPages {
  static final routers = GoRouter(
    routes: [
      GoRoute(
        path: AppRouter.splash,
        builder: (context, state) => SplashScreen(),
      ),
    ],
  );
}
