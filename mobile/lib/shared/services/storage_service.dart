import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  late Box _cacheBox;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox(AppConstants.cacheBox);
    _isInitialized = true;
  }

  // Secure Storage (tokens, sensitive data)
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _secureStorage.read(key: AppConstants.tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  // Hive Storage (non-sensitive data)
  Future<void> saveString(String key, String value) async {
    await _cacheBox.put(key, value);
  }

  String? getString(String key, {String? defaultValue}) {
    return _cacheBox.get(key, defaultValue: defaultValue) as String?;
  }

  Future<void> saveBool(String key, bool value) async {
    await _cacheBox.put(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _cacheBox.get(key, defaultValue: defaultValue) as bool;
  }

  Future<void> saveInt(String key, int value) async {
    await _cacheBox.put(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _cacheBox.get(key, defaultValue: defaultValue) as int;
  }

  Future<void> saveMap(String key, Map<String, dynamic> value) async {
    await _cacheBox.put(key, jsonEncode(value));
  }

  Map<String, dynamic>? getMap(String key) {
    final str = _cacheBox.get(key) as String?;
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('StorageService.getMap error: $e');
      return null;
    }
  }

  Future<void> saveList(String key, List<dynamic> value) async {
    await _cacheBox.put(key, jsonEncode(value));
  }

  List<dynamic>? getList(String key) {
    final str = _cacheBox.get(key) as String?;
    if (str == null) return null;
    try {
      return jsonDecode(str) as List<dynamic>;
    } catch (e) {
      debugPrint('StorageService.getList error: $e');
      return null;
    }
  }

  Future<void> delete(String key) async {
    await _cacheBox.delete(key);
  }

  Future<void> clear() async {
    await _cacheBox.clear();
    await _secureStorage.deleteAll();
  }

  bool containsKey(String key) => _cacheBox.containsKey(key);

  // User data helpers
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await saveMap(AppConstants.userKey, userData);
  }

  Map<String, dynamic>? getUserData() {
    return getMap(AppConstants.userKey);
  }

  Future<void> clearUserData() async {
    await delete(AppConstants.userKey);
  }

  // Onboarding
  bool get isOnboardingComplete => getBool(AppConstants.onboardingKey);

  Future<void> setOnboardingComplete() async {
    await saveBool(AppConstants.onboardingKey, true);
  }

  // Theme
  String get themeMode => getString(AppConstants.themeKey) ?? 'system';

  Future<void> setThemeMode(String mode) async {
    await saveString(AppConstants.themeKey, mode);
  }

  // Streak
  int get streakCount => getInt(AppConstants.streakKey);

  Future<void> setStreakCount(int count) async {
    await saveInt(AppConstants.streakKey, count);
  }
}
