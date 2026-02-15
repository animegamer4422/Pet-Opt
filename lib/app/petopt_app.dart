import 'package:flutter/material.dart';
import '../features/auth/data/auth_store.dart';
import '../features/auth/auth_page.dart';
import '../features/shell/home_shell_page.dart';
import 'routes.dart';
import 'theme.dart';

class PetOptApp extends StatelessWidget {
  const PetOptApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthStore.instance;

    return MaterialApp(
      title: 'PetOpt',
      debugShowCheckedModeBanner: false,

      themeMode: ThemeMode.system,
      theme: buildPetOptTheme(Brightness.light),
      darkTheme: buildPetOptTheme(Brightness.dark),

      // ✅ Skip Auth when session exists
      home: auth.isLoggedIn ? const HomeShellPage() : const AuthPage(),

      // Keep routes for internal navigation
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
