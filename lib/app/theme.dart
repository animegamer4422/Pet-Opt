import 'package:flutter/material.dart';

ThemeData buildPetOptTheme() {
  const seed = Color(0xFF4E7CF6);
  final scheme = ColorScheme.fromSeed(seedColor: seed);

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,

    scaffoldBackgroundColor: scheme.surface,

    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
    ),

    // ✅ Use CardThemeData for Flutter versions where ThemeData.cardTheme expects CardThemeData?
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      floatingLabelStyle: TextStyle(fontWeight: FontWeight.w700, color: scheme.primary),
      labelStyle: TextStyle(color: scheme.onSurface.withOpacity(0.75)),
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 15.5),
      bodyLarge: TextStyle(fontSize: 16.5),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
