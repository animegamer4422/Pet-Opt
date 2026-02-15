import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';


@immutable
class UserProfile {
  final String name;
  final String location;
  final String phone;

  const UserProfile({
    required this.name,
    required this.location,
    required this.phone,
  });

  bool get isComplete => name.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
        'name': name,
        'location': location,
        'phone': phone,
      };

  static UserProfile fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: (json['name'] as String?) ?? '',
      location: (json['location'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
    );
  }
}

class ProfileStore extends ChangeNotifier {
  ProfileStore._();
  static final ProfileStore instance = ProfileStore._();

  static const _kProfileKey = 'petopt_user_profile_v1';

  UserProfile? _profile;
  bool _hydrated = false;

  UserProfile? get profile => _profile;
  bool get hasProfile => _profile != null && _profile!.isComplete;

  Future<void> hydrate() async {
    if (_hydrated) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProfileKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        _profile = UserProfile.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {
        await prefs.remove(_kProfileKey);
        _profile = null;
      }
    }

    _hydrated = true;
    notifyListeners();
  }

  Future<void> saveProfile({
    required String name,
    required String location,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _profile = UserProfile(
      name: name.trim(),
      location: location.trim(),
      phone: phone.trim(),
    );
    await prefs.setString(_kProfileKey, jsonEncode(_profile!.toJson()));
    notifyListeners();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kProfileKey);
    _profile = null;
    notifyListeners();
  }
}
