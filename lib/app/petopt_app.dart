import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme.dart';

class PetOptApp extends StatelessWidget {
  const PetOptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetOpt',
      theme: buildPetOptTheme(),
      initialRoute: Routes.auth,
      onGenerateRoute: Routes.onGenerateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
