import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  Box? _cacheBox;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await Hive.initFlutter();
      _cacheBox = await Hive.openBox(AppConstants.cacheBox);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Hive init failed: $e');
      _isInitialized = true; // prevent retry loops
    }
  }

  // Hive Storage (non-sensitive data)
  Future<void> saveString(String key, String value) async {
    try { await _cacheBox?.put(key, value); } catch (_) {}
  }

  String? getString(String key, {String? defaultValue}) {
    try { return _cacheBox?.get(key, defaultValue: defaultValue) as String?; } catch (_) { return defaultValue; }
  }

  Future<void> saveBool(String key, bool value) async {
    try { await _cacheBox?.put(key, value); } catch (_) {}
  }

  bool getBool(String key, {bool defaultValue = false}) {
    try { return (_cacheBox?.get(key, defaultValue: defaultValue) as bool?) ?? defaultValue; } catch (_) { return defaultValue; }
  }

  Future<void> saveInt(String key, int value) async {
    try { await _cacheBox?.put(key, value); } catch (_) {}
  }

  int getInt(String key, {int defaultValue = 0}) {
    try { return (_cacheBox?.get(key, defaultValue: defaultValue) as int?) ?? defaultValue; } catch (_) { return defaultValue; }
  }

  Future<void> saveMap(String key, Map<String, dynamic> value) async {
    try { await _cacheBox?.put(key, jsonEncode(value)); } catch (_) {}
  }

  Map<String, dynamic>? getMap(String key) {
    try {
      final str = _cacheBox?.get(key) as String?;
      if (str == null) return null;
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) { return null; }
  }

  Future<void> saveList(String key, List<dynamic> value) async {
    try { await _cacheBox?.put(key, jsonEncode(value)); } catch (_) {}
  }

  List<dynamic>? getList(String key) {
    try {
      final str = _cacheBox?.get(key) as String?;
      if (str == null) return null;
      return jsonDecode(str) as List<dynamic>;
    } catch (_) { return null; }
  }

  Future<void> delete(String key) async {
    try { await _cacheBox?.delete(key); } catch (_) {}
  }

  Future<void> clear() async {
    try { await _cacheBox?.clear(); } catch (_) {}
  }

  bool containsKey(String key) {
    try { return _cacheBox?.containsKey(key) ?? false; } catch (_) { return false; }
  }

  // Secure token helpers (use Hive on web since flutter_secure_storage may be unavailable)
  Future<void> saveToken(String token) async => saveString(AppConstants.tokenKey, token);
  Future<String?> getToken() async => getString(AppConstants.tokenKey);
  Future<void> saveRefreshToken(String token) async => saveString(AppConstants.refreshTokenKey, token);
  Future<String?> getRefreshToken() async => getString(AppConstants.refreshTokenKey);
  Future<void> clearTokens() async {
    await delete(AppConstants.tokenKey);
    await delete(AppConstants.refreshTokenKey);
  }

  // User data helpers
  Future<void> saveUserData(Map<String, dynamic> userData) async => saveMap(AppConstants.userKey, userData);
  Map<String, dynamic>? getUserData() => getMap(AppConstants.userKey);
  Future<void> clearUserData() async => delete(AppConstants.userKey);

  // Onboarding
  bool get isOnboardingComplete => getBool(AppConstants.onboardingKey);
  Future<void> setOnboardingComplete() async => saveBool(AppConstants.onboardingKey, true);

  // Theme
  String get themeMode => getString(AppConstants.themeKey) ?? 'system';
  Future<void> setThemeMode(String mode) async => saveString(AppConstants.themeKey, mode);

  // Streak
  int get streakCount => getInt(AppConstants.streakKey);
  Future<void> setStreakCount(int count) async => saveInt(AppConstants.streakKey, count);
}
