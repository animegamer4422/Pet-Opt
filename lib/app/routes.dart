import 'package:flutter/material.dart';
import '../features/auth/auth_page.dart';
import '../features/feed/feed_page.dart';
import '../features/post/create_post_page.dart';
import '../features/pet/pet_detail_page.dart';
import '../features/onboarding/profile_setup_page.dart';

class Routes {
  static const auth = '/auth';
  static const feed = '/';
  static const createPost = '/create-post';
  static const petDetail = '/pet-detail';
  static const profileSetup = '/profile-setup';



  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case auth:
        return MaterialPageRoute(builder: (_) => const AuthPage());
      case feed:
        return MaterialPageRoute(builder: (_) => const FeedPage());
      case createPost:
        return MaterialPageRoute(builder: (_) => const CreatePostPage());
      case petDetail:
        final petId = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => PetDetailPage(petId: petId));
      case profileSetup:
  return MaterialPageRoute(builder: (_) => const ProfileSetupPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
