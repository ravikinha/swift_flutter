import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/encryption.dart';
import 'package:swift_flutter/core/persistence.dart';

void main() {
  group('XOREncryption', () {
    late XOREncryption encryption;

    setUp(() {
      encryption = XOREncryption();
    });

    test('should encrypt and decrypt data', () async {
      const data = 'Hello, World!';
      const key = 'my_secret_key';

      final encrypted = await encryption.encrypt(data, key: key);
      expect(encrypted, isNot(equals(data)));

      final decrypted = await encryption.decrypt(encrypted, key: key);
      expect(decrypted, equals(data));
    });

    test('should generate encryption key', () {
      final key = encryption.generateKey();
      expect(key.length, 32);
      expect(key, isNot(isEmpty));
    });

    test('should throw error if key is missing', () async {
      expect(
        () => encryption.encrypt('data', key: null),
        throwsArgumentError,
      );

      expect(
        () => encryption.decrypt('data', key: null),
        throwsArgumentError,
      );
    });

    test('should handle unicode characters', () async {
      const data = 'Hello 世界 🌍';
      const key = 'test_key';

      final encrypted = await encryption.encrypt(data, key: key);
      final decrypted = await encryption.decrypt(encrypted, key: key);

      expect(decrypted, equals(data));
    });

    test('should produce different output with different keys', () async {
      const data = 'secret data';
      const key1 = 'key1';
      const key2 = 'key2';

      final encrypted1 = await encryption.encrypt(data, key: key1);
      final encrypted2 = await encryption.encrypt(data, key: key2);

      expect(encrypted1, isNot(equals(encrypted2)));
    });
  });

  group('AESEncryption', () {
    late AESEncryption encryption;

    setUp(() {
      encryption = AESEncryption();
    });

    test('should encrypt and decrypt data', () async {
      const data = 'Sensitive information';
      const key = 'aes_encryption_key_32_chars!!';

      final encrypted = await encryption.encrypt(data, key: key);
      expect(encrypted, isNot(equals(data)));

      final decrypted = await encryption.decrypt(encrypted, key: key);
      expect(decrypted, equals(data));
    });

    test('should generate encryption key', () {
      final key = encryption.generateKey();
      expect(key.length, 32);
      expect(key, isNot(isEmpty));
    });

    test('algorithm should be AES256', () {
      expect(encryption.algorithm, EncryptionAlgorithm.aes256);
    });
  });

  group('SecureSwiftPersisted', () {
    late MemoryStorage storage;
    late XOREncryption encryption;

    setUp(() {
      storage = MemoryStorage();
      encryption = XOREncryption();
    });

    test('should save and load encrypted data', () async {
      final secure = SecureSwiftPersisted<String>(
        'initial',
        'test_key',
        storage,
        encryption: encryption,
        encryptionKey: 'my_key',
      );

      secure.value = 'secret data';
      await secure.save();

      // Verify data is encrypted in storage
      final raw = await storage.load('test_key');
      expect(raw, isNotNull);
      expect(raw, isNot(contains('secret data')));

      // Load and verify decryption
      final secure2 = SecureSwiftPersisted<String>(
        'initial',
        'test_key',
        storage,
        encryption: encryption,
        encryptionKey: 'my_key',
      );
      await secure2.load();
      expect(secure2.value, 'secret data');
    });

    test('should handle complex data types', () async {
      final secure = SecureSwiftPersisted<Map<String, dynamic>>(
        {},
        'complex_key',
        storage,
        encryption: encryption,
        encryptionKey: 'complex_key_123',
      );

      secure.value = {
        'name': 'John',
        'age': 30,
        'active': true,
      };
      await secure.save();
      await secure.load();

      expect(secure.value['name'], 'John');
      expect(secure.value['age'], 30);
      expect(secure.value['active'], true);
    });

    test('should use default key if not provided', () async {
      final secure = SecureSwiftPersisted<String>(
        'initial',
        'default_key_test',
        storage,
        encryption: encryption,
      );

      secure.value = 'test data';
      await secure.save();
      await secure.load();

      expect(secure.value, 'test data');
    });
  });

  group('EncryptionHelper', () {
    test('should create XOR encryption provider', () {
      final provider = EncryptionHelper.xor();
      expect(provider, isA<XOREncryption>());
      expect(provider.algorithm, EncryptionAlgorithm.xor);
    });

    test('should create AES encryption provider', () {
      final provider = EncryptionHelper.aes();
      expect(provider, isA<AESEncryption>());
      expect(provider.algorithm, EncryptionAlgorithm.aes256);
    });

    test('should generate secure key', () {
      final key = EncryptionHelper.generateSecureKey();
      expect(key.length, 32);

      final key64 = EncryptionHelper.generateSecureKey(length: 64);
      expect(key64.length, 64);
    });

    test('should hash data', () {
      final hash1 = EncryptionHelper.simpleHash('test data');
      final hash2 = EncryptionHelper.simpleHash('test data');
      final hash3 = EncryptionHelper.simpleHash('different data');

      expect(hash1, equals(hash2));
      expect(hash1, isNot(equals(hash3)));
    });

    test('should encode and decode base64', () {
      const data = 'Hello, World!';
      final encoded = EncryptionHelper.encodeBase64(data);
      expect(encoded, isNot(equals(data)));

      final decoded = EncryptionHelper.decodeBase64(encoded);
      expect(decoded, equals(data));
    });
  });

  group('MemoryKeyManager', () {
    late MemoryKeyManager keyManager;

    setUp(() {
      keyManager = MemoryKeyManager();
    });

    test('should store and retrieve key', () async {
      await keyManager.storeKey('key1', 'secret123');

      final retrieved = await keyManager.retrieveKey('key1');
      expect(retrieved, 'secret123');
    });

    test('should check if key exists', () async {
      await keyManager.storeKey('key1', 'value');

      expect(await keyManager.hasKey('key1'), isTrue);
      expect(await keyManager.hasKey('key2'), isFalse);
    });

    test('should delete key', () async {
      await keyManager.storeKey('key1', 'value');
      expect(await keyManager.hasKey('key1'), isTrue);

      await keyManager.deleteKey('key1');
      expect(await keyManager.hasKey('key1'), isFalse);
    });

    test('should return null for non-existent key', () async {
      final retrieved = await keyManager.retrieveKey('nonexistent');
      expect(retrieved, isNull);
    });

    test('should clear all keys', () async {
      await keyManager.storeKey('key1', 'value1');
      await keyManager.storeKey('key2', 'value2');

      keyManager.clear();

      expect(await keyManager.hasKey('key1'), isFalse);
      expect(await keyManager.hasKey('key2'), isFalse);
    });
  });

  group('SecureKeyManager', () {
    late SecureKeyManager keyManager;

    setUp(() {
      keyManager = SecureKeyManager();
    });

    test('should store and retrieve key', () async {
      await keyManager.storeKey('secure_key', 'secure_value');

      final retrieved = await keyManager.retrieveKey('secure_key');
      expect(retrieved, 'secure_value');
    });

    test('should check if key exists', () async {
      await keyManager.storeKey('test_key', 'test_value');

      expect(await keyManager.hasKey('test_key'), isTrue);
      expect(await keyManager.hasKey('missing_key'), isFalse);
    });

    test('should delete key', () async {
      await keyManager.storeKey('delete_me', 'value');
      await keyManager.deleteKey('delete_me');

      expect(await keyManager.hasKey('delete_me'), isFalse);
    });
  });
}

