import 'package:flutter/material.dart';

import '../features/auth/auth_page.dart';
import '../features/onboarding/profile_setup_page.dart';
import '../features/shell/home_shell_page.dart';
import '../features/pet/pet_detail_page.dart';

class Routes {
  static const auth = '/auth';
  static const profileSetup = '/profile-setup';
  static const home = '/home';
  static const petDetail = '/pet-detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case auth:
        return MaterialPageRoute(builder: (_) => const AuthPage());
      case profileSetup:
        return MaterialPageRoute(builder: (_) => const ProfileSetupPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeShellPage());
      case petDetail:
        final petId = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => PetDetailPage(petId: petId));
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
