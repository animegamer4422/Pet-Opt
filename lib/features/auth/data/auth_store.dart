import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/auth_models.dart';

@immutable
class AuthSession {
  final String email;
  final AccountType accountType;
  final DateTime createdAt;

  const AuthSession({
    required this.email,
    required this.accountType,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'accountType': accountType.name,
        'createdAt': createdAt.toIso8601String(),
      };

  static AuthSession fromJson(Map<String, dynamic> json) {
    final typeName =
        (json['accountType'] as String?) ?? AccountType.individual.name;

    final type = AccountType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => AccountType.individual,
    );

    return AuthSession(
      email: (json['email'] as String?) ?? '',
      accountType: type,
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

class AuthStore extends ChangeNotifier {
  AuthStore._();
  static final AuthStore instance = AuthStore._();

  static const _kSessionKey = 'petopt_auth_session_v1';

  AuthSession? _session;
  bool _hydrated = false;

  AuthSession? get session => _session;
  bool get isLoggedIn => _session != null;

  Future<void> hydrate() async {
    if (_hydrated) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSessionKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        _session = AuthSession.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {
        await prefs.remove(_kSessionKey);
        _session = null;
      }
    }

    _hydrated = true;
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required AccountType accountType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _session = AuthSession(
      email: email.trim(),
      accountType: accountType,
      createdAt: DateTime.now(),
    );
    await prefs.setString(_kSessionKey, jsonEncode(_session!.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessionKey);
    _session = null;
    notifyListeners();
  }
}
