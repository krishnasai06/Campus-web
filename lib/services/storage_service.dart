import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// [StorageService] handles secure persistence of sensitive session data.
/// 
/// SECURITY NOTICE:
/// 1. This service uses AES encryption provided by [FlutterSecureStorage].
/// 2. User passwords are ONLY stored to enable fast biometric login.
/// 3. Offline cache and session cookies are persisted to maintain experience.
class StorageService {
  // Singleton instance
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const String _keySessionCookie = 'session_cookie';
  static const String _keyNetID = 'net_id';
  static const String _keyPassword = 'user_password';
  
  // Cache Keys
  static const String _keyCacheAttendance = 'cache_attendance';
  static const String _keyCacheMarks = 'cache_marks';
  static const String _keyCacheTimetable = 'cache_timetable';
  /// Stores the session cookie securely.
  /// This cookie is used to authenticate requests to the SRM portal.
  Future<void> saveSessionCookie(String cookie) async {
    await _storage.write(key: _keySessionCookie, value: cookie);
  }

  /// Retrieves the stored session cookie.
  /// Returns null if no session exists or has been cleared.
  Future<String?> getSessionCookie() async {
    return await _storage.read(key: _keySessionCookie);
  }

  /// Clears all stored session data, but KEEPS the credential for biometric login natively.
  Future<void> clearSession() async {
    await _storage.delete(key: _keySessionCookie);
    // Note: NetID and Password are kept to allow fingerprint auto-login next time.
  }
  
  /// Wipe EVERYTHING including credentials (hard logout).
  Future<void> wipeCredentials() async {
    await clearSession();
    await _storage.delete(key: _keyNetID);
    await _storage.delete(key: _keyPassword);
    await clearCache();
  }

  /// Stores credentials for fast biometric login next time.
  Future<void> saveCredentials(String netID, String password) async {
    await _storage.write(key: _keyNetID, value: netID);
    await _storage.write(key: _keyPassword, value: password);
  }

  /// Retrieves stored password for biometric login.
  Future<String?> getPassword() async {
    return await _storage.read(key: _keyPassword);
  }

  /// Stores the user's NetID/Registration Number.
  /// Stored for UI display purposes (e.g., "Welcome, [NetID]").
  Future<void> saveNetID(String netID) async {
    await _storage.write(key: _keyNetID, value: netID);
  }

  /// Retrieves the stored NetID.
  Future<String?> getNetID() async {
    return await _storage.read(key: _keyNetID);
  }

  // --- Offline Caching ---
  
  Future<void> saveCache(String key, String jsonData) async {
    await _storage.write(key: key, value: jsonData);
  }

  Future<String?> getCache(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> clearCache() async {
    await _storage.delete(key: _keyCacheAttendance);
    await _storage.delete(key: _keyCacheMarks);
    await _storage.delete(key: _keyCacheTimetable);
  }

  String get keyCacheAttendance => _keyCacheAttendance;
  String get keyCacheMarks => _keyCacheMarks;
  String get keyCacheTimetable => _keyCacheTimetable;
}
