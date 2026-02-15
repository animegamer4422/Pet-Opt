import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme.dart';

class PetOptApp extends StatelessWidget {
  const PetOptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetOpt',
      debugShowCheckedModeBanner: false,

      // ✅ Auto-switch based on device theme + live updates
      themeMode: ThemeMode.system,

      // ✅ Light theme
      theme: buildPetOptTheme(Brightness.light),

      // ✅ Dark theme
      darkTheme: buildPetOptTheme(Brightness.dark),

      initialRoute: Routes.auth,
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
