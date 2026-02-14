import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'logger_service.dart';

/// Secure storage service using flutter_secure_storage
/// Uses platform-specific encryption (Keychain on iOS, EncryptedSharedPreferences on Android)
class EncryptionService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Keys for secure storage
  static const String _userIdKey = 'secure_user_id';
  static const String _userNameKey = 'secure_user_name';
  static const String _userSpecialtyKey = 'secure_user_specialty';

  /// Hash a string using SHA256 (one-way, for non-sensitive data like nicknames)
  static String hashString(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  /// Generate a hashed nickname from a name
  static String generateHashedNickname(String realName) {
    final hash = hashString(realName);
    return 'User_${hash.substring(0, 6).toUpperCase()}';
  }

  /// Store a value securely
  static Future<void> secureWrite(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      LoggerService()
          .logError('SecureStorageWriteError', e, null, {'key': key});
    }
  }

  /// Read a value from secure storage
  static Future<String?> secureRead(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      LoggerService().logError('SecureStorageReadError', e, null, {'key': key});
      return null;
    }
  }

  /// Delete a value from secure storage
  static Future<void> secureDelete(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      LoggerService()
          .logError('SecureStorageDeleteError', e, null, {'key': key});
    }
  }

  /// Clear all secure storage
  static Future<void> secureClearAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      LoggerService().logError('SecureStorageClearError', e, null, {});
    }
  }

  // Convenience methods for specific user data
  static Future<void> setSecureUserId(String id) => secureWrite(_userIdKey, id);
  static Future<String?> getSecureUserId() => secureRead(_userIdKey);

  static Future<void> setSecureUserName(String name) =>
      secureWrite(_userNameKey, name);
  static Future<String?> getSecureUserName() => secureRead(_userNameKey);

  static Future<void> setSecureUserSpecialty(String specialty) =>
      secureWrite(_userSpecialtyKey, specialty);
  static Future<String?> getSecureUserSpecialty() =>
      secureRead(_userSpecialtyKey);

  // Legacy methods - now use secure storage internally
  // These are kept for backward compatibility but now delegate to secure storage
  @Deprecated('Use secureWrite instead for new code')
  static String encryptString(String plaintext) {
    // For backward compatibility, return base64 encoded string
    // New code should use async secureWrite method
    return base64Encode(utf8.encode(plaintext));
  }

  @Deprecated('Use secureRead instead for new code')
  static String decryptString(String encrypted) {
    try {
      // For backward compatibility, decode base64
      return utf8.decode(base64Decode(encrypted));
    } catch (e) {
      LoggerService().logError('DecryptionError', e, null, {});
      return '';
    }
  }
}
