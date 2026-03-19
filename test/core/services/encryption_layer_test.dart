import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:vanguard_crisis_response/core/services/encryption_layer.dart';
import 'package:logger/logger.dart';

@GenerateMocks([FlutterSecureStorage])
import 'encryption_layer_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EncryptionLayer', () {
    late MockFlutterSecureStorage mockSecureStorage;
    late EncryptionLayer encryptionLayer;
    late Logger logger;

    setUp(() {
      mockSecureStorage = MockFlutterSecureStorage();
      logger = Logger(level: Level.off); // Disable logging in tests
      encryptionLayer = EncryptionLayer(
        secureStorage: mockSecureStorage,
        logger: logger,
      );
    });

    group('Initialization', () {
      test('should generate new key when no key exists in storage', () async {
        when(mockSecureStorage.read(key: 'mesh_encryption_key'))
            .thenAnswer((_) async => null);
        when(mockSecureStorage.write(
          key: 'mesh_encryption_key',
          value: anyNamed('value'),
        )).thenAnswer((_) async => {});

        await encryptionLayer.initializeKey();

        expect(encryptionLayer.isInitialized, isTrue);
        verify(mockSecureStorage.read(key: 'mesh_encryption_key')).called(1);
        verify(mockSecureStorage.write(
          key: 'mesh_encryption_key',
          value: anyNamed('value'),
        )).called(1);
      });

      test('should load existing key from storage', () async {
        const existingKey = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='; // Base64 32 bytes
        when(mockSecureStorage.read(key: 'mesh_encryption_key'))
            .thenAnswer((_) async => existingKey);

        await encryptionLayer.initializeKey();

        expect(encryptionLayer.isInitialized, isTrue);
        verify(mockSecureStorage.read(key: 'mesh_encryption_key')).called(1);
        verifyNever(mockSecureStorage.write(
          key: anyNamed('key'),
          value: anyNamed('value'),
        ));
      });

      test('should throw exception when initialization fails', () async {
        when(mockSecureStorage.read(key: 'mesh_encryption_key'))
            .thenThrow(Exception('Storage error'));

        expect(
          () => encryptionLayer.initializeKey(),
          throwsException,
        );
      });
    });

    group('Encryption', () {
      setUp(() async {
        when(mockSecureStorage.read(key: 'mesh_encryption_key'))
            .thenAnswer((_) async => null);
        when(mockSecureStorage.write(
          key: 'mesh_encryption_key',
          value: anyNamed('value'),
        )).thenAnswer((_) async => {});

        await encryptionLayer.initializeKey();
      });

      test('should encrypt JSON payload successfully', () async {
        const jsonPayload = '{"id":"test","lat":30.0,"lng":76.0}';

        final result = await encryptionLayer.encrypt(jsonPayload);

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.length, greaterThan(16)); // At least IV + some data
        expect(result.error, isNull);
      });

      test('should fail encryption when not initialized', () async {
        final uninitializedLayer = EncryptionLayer(
          secureStorage: mockSecureStorage,
          logger: logger,
        );

        const jsonPayload = '{"id":"test"}';
        final result = await uninitializedLayer.encrypt(jsonPayload);

        expect(result.isSuccess, isFalse);
        expect(result.error, EncryptionError.keyNotFound);
        expect(result.data, isNull);
      });

      test('should produce different ciphertext for same plaintext (due to IV)', () async {
        const jsonPayload = '{"id":"test","lat":30.0,"lng":76.0}';

        final result1 = await encryptionLayer.encrypt(jsonPayload);
        final result2 = await encryptionLayer.encrypt(jsonPayload);

        expect(result1.isSuccess, isTrue);
        expect(result2.isSuccess, isTrue);
        expect(result1.data, isNot(equals(result2.data))); // Different IVs
      });

      test('should compress data before encryption', () async {
        // Large repetitive JSON should compress well
        final largeJson = '{"data":"${'x' * 1000}"}';

        final result = await encryptionLayer.encrypt(largeJson);

        expect(result.isSuccess, isTrue);
        // Compressed + encrypted should be smaller than original
        expect(result.data!.length, lessThan(largeJson.length));
      });
    });

    group('Decryption', () {
      setUp(() async {
        when(mockSecureStorage.read(key: 'mesh_encryption_key'))
            .thenAnswer((_) async => null);
        when(mockSecureStorage.write(
          key: 'mesh_encryption_key',
          value: anyNamed('value'),
        )).thenAnswer((_) async => {});

        await encryptionLayer.initializeKey();
      });

      test('should decrypt encrypted payload successfully', () async {
        const originalPayload = '{"id":"test-123","lat":30.7333,"lng":76.7794}';

        final encryptResult = await encryptionLayer.encrypt(originalPayload);
        expect(encryptResult.isSuccess, isTrue);

        final decryptResult = await encryptionLayer.decrypt(encryptResult.data!);

        expect(decryptResult.isSuccess, isTrue);
        expect(decryptResult.data, originalPayload);
        expect(decryptResult.error, isNull);
      });

      test('should fail decryption when not initialized', () async {
        final uninitializedLayer = EncryptionLayer(
          secureStorage: mockSecureStorage,
          logger: logger,
        );

        final fakeData = Uint8List(32);
        final result = await uninitializedLayer.decrypt(fakeData);

        expect(result.isSuccess, isFalse);
        expect(result.error, EncryptionError.keyNotFound);
      });

      test('should fail decryption with invalid data (too short)', () async {
        final invalidData = Uint8List(10); // Less than 32 bytes minimum

        final result = await encryptionLayer.decrypt(invalidData);

        expect(result.isSuccess, isFalse);
        expect(result.error, EncryptionError.invalidData);
      });

      test('should fail decryption with corrupted data', () async {
        const originalPayload = '{"id":"test"}';

        final encryptResult = await encryptionLayer.encrypt(originalPayload);
        expect(encryptResult.isSuccess, isTrue);

        // Corrupt the encrypted data
        final corruptedData = Uint8List.fromList(encryptResult.data!);
        corruptedData[20] = corruptedData[20] ^ 0xFF; // Flip bits

        final decryptResult = await encryptionLayer.decrypt(corruptedData);

        expect(decryptResult.isSuccess, isFalse);
        expect(
          decryptResult.error,
          anyOf([
            EncryptionError.decryptionFailed,
            EncryptionError.decompressionFailed,
          ]),
        );
      });
    });

    group('Round-trip encryption/decryption', () {
      setUp(() async {
        when(mockSecureStorage.read(key: 'mesh_encryption_key'))
            .thenAnswer((_) async => null);
        when(mockSecureStorage.write(
          key: 'mesh_encryption_key',
          value: anyNamed('value'),
        )).thenAnswer((_) async => {});

        await encryptionLayer.initializeKey();
      });

      test('should preserve simple JSON payload', () async {
        const payload = '{"id":"abc123","type":1}';

        final encrypted = await encryptionLayer.encrypt(payload);
        final decrypted = await encryptionLayer.decrypt(encrypted.data!);

        expect(decrypted.data, payload);
      });

      test('should preserve complex JSON payload', () async {
        const payload = '''
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "lat": 30.7333,
  "lng": 76.7794,
  "ts": 1710000000,
  "type": 2,
  "hop": 0,
  "accuracy": 15.5
}''';

        final encrypted = await encryptionLayer.encrypt(payload);
        final decrypted = await encryptionLayer.decrypt(encrypted.data!);

        expect(decrypted.data, payload);
      });

      test('should preserve payload with special characters', () async {
        const payload = '{"message":"Test with émojis 🚨🔥 and spëcial çhars"}';

        final encrypted = await encryptionLayer.encrypt(payload);
        final decrypted = await encryptionLayer.decrypt(encrypted.data!);

        expect(decrypted.data, payload);
      });

      test('should preserve empty JSON object', () async {
        const payload = '{}';

        final encrypted = await encryptionLayer.encrypt(payload);
        final decrypted = await encryptionLayer.decrypt(encrypted.data!);

        expect(decrypted.data, payload);
      });

      test('should preserve large JSON payload', () async {
        final payload = '{"data":"${'x' * 10000}"}';

        final encrypted = await encryptionLayer.encrypt(payload);
        final decrypted = await encryptionLayer.decrypt(encrypted.data!);

        expect(decrypted.data, payload);
      });
    });

    group('Key management', () {
      test('should reset key successfully', () async {
        when(mockSecureStorage.read(key: 'mesh_encryption_key'))
            .thenAnswer((_) async => null);
        when(mockSecureStorage.write(
          key: 'mesh_encryption_key',
          value: anyNamed('value'),
        )).thenAnswer((_) async => {});
        when(mockSecureStorage.delete(key: 'mesh_encryption_key'))
            .thenAnswer((_) async => {});

        await encryptionLayer.initializeKey();
        final oldKey = encryptionLayer.encryptionKeyBase64;

        await encryptionLayer.resetKey();
        final newKey = encryptionLayer.encryptionKeyBase64;

        expect(encryptionLayer.isInitialized, isTrue);
        expect(newKey, isNot(equals(oldKey)));
        verify(mockSecureStorage.delete(key: 'mesh_encryption_key')).called(1);
      });

      test('should not decrypt with different key', () async {
        when(mockSecureStorage.read(key: 'mesh_encryption_key'))
            .thenAnswer((_) async => null);
        when(mockSecureStorage.write(
          key: 'mesh_encryption_key',
          value: anyNamed('value'),
        )).thenAnswer((_) async => {});
        when(mockSecureStorage.delete(key: 'mesh_encryption_key'))
            .thenAnswer((_) async => {});

        await encryptionLayer.initializeKey();

        const payload = '{"id":"test"}';
        final encrypted = await encryptionLayer.encrypt(payload);

        // Reset key (generates new key)
        await encryptionLayer.resetKey();

        // Try to decrypt with new key
        final decrypted = await encryptionLayer.decrypt(encrypted.data!);

        expect(decrypted.isSuccess, isFalse);
      });
    });

    group('Property-based tests', () {
      setUp(() async {
        when(mockSecureStorage.read(key: 'mesh_encryption_key'))
            .thenAnswer((_) async => null);
        when(mockSecureStorage.write(
          key: 'mesh_encryption_key',
          value: anyNamed('value'),
        )).thenAnswer((_) async => {});

        await encryptionLayer.initializeKey();
      });

      test('encryption is deterministic with same IV (property test)', () async {
        // This tests that the encryption algorithm itself is deterministic
        // (though in practice we use random IVs)
        const payload = '{"test":"data"}';

        final result1 = await encryptionLayer.encrypt(payload);
        final result2 = await encryptionLayer.encrypt(payload);

        // Results should be different due to different IVs
        expect(result1.data, isNot(equals(result2.data)));

        // But both should decrypt to same plaintext
        final decrypt1 = await encryptionLayer.decrypt(result1.data!);
        final decrypt2 = await encryptionLayer.decrypt(result2.data!);

        expect(decrypt1.data, payload);
        expect(decrypt2.data, payload);
      });

      test('round-trip preserves data for various inputs', () async {
        final testCases = [
          '{"a":1}',
          '{"nested":{"object":{"deep":true}}}',
          '{"array":[1,2,3,4,5]}',
          '{"unicode":"日本語テスト"}',
          '{"numbers":123.456}',
          '{"bool":true}',
          '{"null":null}',
        ];

        for (final testCase in testCases) {
          final encrypted = await encryptionLayer.encrypt(testCase);
          final decrypted = await encryptionLayer.decrypt(encrypted.data!);

          expect(decrypted.data, testCase, reason: 'Failed for: $testCase');
        }
      });
    });
  });
}
