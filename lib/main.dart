import 'package:flutter/material.dart';
import 'app/petopt_app.dart';
import './features/auth/data/auth_store.dart';

// lib\features\auth\data\auth_store.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthStore.instance.hydrate();
  runApp(const PetOptApp());
}