import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'persistence.dart';

/// Encryption algorithm type
enum EncryptionAlgorithm {
  aes256,
  xor, // Simple XOR for testing/development
}

/// Encryption provider interface
abstract class EncryptionProvider {
  /// Encrypt data
  Future<String> encrypt(String data, {String? key});

  /// Decrypt data
  Future<String> decrypt(String data, {String? key});

  /// Generate encryption key
  String generateKey();

  /// Encryption algorithm
  EncryptionAlgorithm get algorithm;
}

/// Simple XOR encryption (for development/testing only)
/// Note: NOT cryptographically secure - use AES for production
class XOREncryption implements EncryptionProvider {
  @override
  EncryptionAlgorithm get algorithm => EncryptionAlgorithm.xor;

  @override
  Future<String> encrypt(String data, {String? key}) async {
    if (key == null || key.isEmpty) {
      throw ArgumentError('Encryption key is required');
    }

    final dataBytes = utf8.encode(data);
    final keyBytes = utf8.encode(key);
    final encrypted = <int>[];

    for (var i = 0; i < dataBytes.length; i++) {
      encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64Encode(encrypted);
  }

  @override
  Future<String> decrypt(String data, {String? key}) async {
    if (key == null || key.isEmpty) {
      throw ArgumentError('Decryption key is required');
    }

    final encrypted = base64Decode(data);
    final keyBytes = utf8.encode(key);
    final decrypted = <int>[];

    for (var i = 0; i < encrypted.length; i++) {
      decrypted.add(encrypted[i] ^ keyBytes[i % keyBytes.length]);
    }

    return utf8.decode(decrypted);
  }

  @override
  String generateKey() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(32, (index) => chars[random.nextInt(chars.length)])
        .join();
  }
}

/// AES-256 encryption (placeholder - requires crypto package)
/// For production, use the 'encrypt' package or 'pointycastle'
class AESEncryption implements EncryptionProvider {
  @override
  EncryptionAlgorithm get algorithm => EncryptionAlgorithm.aes256;

  @override
  Future<String> encrypt(String data, {String? key}) async {
    if (key == null || key.isEmpty) {
      throw ArgumentError('Encryption key is required');
    }

    // Note: This is a placeholder implementation
    // For production, use the 'encrypt' package:
    // 
    // import 'package:encrypt/encrypt.dart' as encrypt;
    // 
    // final encryptKey = encrypt.Key.fromUtf8(key.padRight(32).substring(0, 32));
    // final iv = encrypt.IV.fromLength(16);
    // final encrypter = encrypt.Encrypter(encrypt.AES(encryptKey));
    // final encrypted = encrypter.encrypt(data, iv: iv);
    // return encrypted.base64;

    if (kDebugMode) {
      debugPrint('Warning: Using placeholder AES encryption. Use "encrypt" package for production.');
    }

    // Fallback to XOR for now
    return XOREncryption().encrypt(data, key: key);
  }

  @override
  Future<String> decrypt(String data, {String? key}) async {
    if (key == null || key.isEmpty) {
      throw ArgumentError('Decryption key is required');
    }

    // Note: This is a placeholder implementation
    // For production, use the 'encrypt' package (see encrypt method)

    if (kDebugMode) {
      debugPrint('Warning: Using placeholder AES decryption. Use "encrypt" package for production.');
    }

    // Fallback to XOR for now
    return XOREncryption().decrypt(data, key: key);
  }

  @override
  String generateKey() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
    final random = Random.secure();
    return List.generate(32, (index) => chars[random.nextInt(chars.length)])
        .join();
  }
}

/// Secure persisted state with encryption
/// This is a simplified version that doesn't extend SwiftPersisted
/// For production use, integrate with flutter_secure_storage
class SecureSwiftPersisted<T> {
  final String storageKey;
  final StorageBackend storage;
  final EncryptionProvider encryption;
  final String? encryptionKey;
  final int version;
  T _value;

  SecureSwiftPersisted(
    T initialValue,
    this.storageKey,
    this.storage, {
    required this.encryption,
    this.encryptionKey,
    this.version = 1,
  }) : _value = initialValue {
    load();
  }

  T get value => _value;
  set value(T newValue) {
    _value = newValue;
    save();
  }

  Future<void> save() async {
    try {
      final encKey = encryptionKey ?? _getDefaultKey();
      final json = jsonEncode({
        'value': _value,
        'version': version,
        'timestamp': DateTime.now().toIso8601String(),
      });

      final encrypted = await encryption.encrypt(json, key: encKey);
      await storage.save(storageKey, encrypted);
    } catch (e) {
      debugPrint('Error saving encrypted data: $e');
      rethrow;
    }
  }

  Future<void> load() async {
    try {
      final encrypted = await storage.load(storageKey);
      if (encrypted == null) return;

      final decryptionKey = encryptionKey ?? _getDefaultKey();
      final decrypted = await encryption.decrypt(encrypted, key: decryptionKey);
      final data = jsonDecode(decrypted) as Map<String, dynamic>;

      _value = data['value'] as T;
    } catch (e) {
      debugPrint('Error loading encrypted data: $e');
      // Don't rethrow - use initial value
    }
  }

  String _getDefaultKey() {
    // In production, retrieve from secure storage (e.g., flutter_secure_storage)
    // This is just a placeholder
    return 'default_encryption_key_change_in_production';
  }
}

/// Encryption helper utilities
class EncryptionHelper {
  /// Create XOR encryption provider
  static EncryptionProvider xor() => XOREncryption();

  /// Create AES encryption provider
  static EncryptionProvider aes() => AESEncryption();

  /// Generate secure random key
  static String generateSecureKey({int length = 32}) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()_+-=[]{}|;:,.<>?';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// Hash data (simple hash for non-cryptographic purposes)
  static String simpleHash(String data) {
    var hash = 0;
    for (var i = 0; i < data.length; i++) {
      hash = ((hash << 5) - hash) + data.codeUnitAt(i);
      hash = hash & hash; // Convert to 32-bit integer
    }
    return hash.abs().toString();
  }

  /// Encode data to base64
  static String encodeBase64(String data) {
    return base64Encode(utf8.encode(data));
  }

  /// Decode data from base64
  static String decodeBase64(String data) {
    return utf8.decode(base64Decode(data));
  }
}

/// Key management interface
abstract class KeyManager {
  /// Store encryption key securely
  Future<void> storeKey(String keyId, String key);

  /// Retrieve encryption key
  Future<String?> retrieveKey(String keyId);

  /// Delete encryption key
  Future<void> deleteKey(String keyId);

  /// Check if key exists
  Future<bool> hasKey(String keyId);
}

/// In-memory key manager (for development/testing)
class MemoryKeyManager implements KeyManager {
  final Map<String, String> _keys = {};

  @override
  Future<void> storeKey(String keyId, String key) async {
    _keys[keyId] = key;
  }

  @override
  Future<String?> retrieveKey(String keyId) async {
    return _keys[keyId];
  }

  @override
  Future<void> deleteKey(String keyId) async {
    _keys.remove(keyId);
  }

  @override
  Future<bool> hasKey(String keyId) async {
    return _keys.containsKey(keyId);
  }

  /// Clear all keys
  void clear() {
    _keys.clear();
  }
}

/// Secure key manager (placeholder - requires flutter_secure_storage)
class SecureKeyManager implements KeyManager {
  // Note: For production, use flutter_secure_storage package:
  // 
  // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
  // 
  // final _storage = FlutterSecureStorage();

  final MemoryKeyManager _fallback = MemoryKeyManager();

  @override
  Future<void> storeKey(String keyId, String key) async {
    // Production: await _storage.write(key: keyId, value: key);
    if (kDebugMode) {
      debugPrint('Warning: Using memory key manager. Use flutter_secure_storage for production.');
    }
    await _fallback.storeKey(keyId, key);
  }

  @override
  Future<String?> retrieveKey(String keyId) async {
    // Production: return await _storage.read(key: keyId);
    return _fallback.retrieveKey(keyId);
  }

  @override
  Future<void> deleteKey(String keyId) async {
    // Production: await _storage.delete(key: keyId);
    await _fallback.deleteKey(keyId);
  }

  @override
  Future<bool> hasKey(String keyId) async {
    // Production: return await _storage.containsKey(key: keyId);
    return _fallback.hasKey(keyId);
  }
}

