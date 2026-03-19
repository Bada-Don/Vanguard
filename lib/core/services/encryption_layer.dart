import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

/// Result type for encryption operations
class EncryptionResult<T, E> {
  final T? data;
  final E? error;
  final bool isSuccess;

  const EncryptionResult.success(this.data)
      : error = null,
        isSuccess = true;

  const EncryptionResult.failure(this.error)
      : data = null,
        isSuccess = false;
}

/// Encryption error types
enum EncryptionError {
  decryptionFailed,
  invalidData,
  keyNotFound,
  decompressionFailed,
  encryptionFailed,
  keyGenerationFailed,
}

/// Encryption layer service for AES-256-CBC encryption/decryption
/// Handles payload encryption with GZIP compression for bandwidth efficiency
class EncryptionLayer {
  static const String _keyStorageKey = 'mesh_encryption_key';
  static const String _ivStorageKey = 'mesh_encryption_iv';
  
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;
  
  encrypt_pkg.Key? _encryptionKey;
  bool _isInitialized = false;

  EncryptionLayer({
    FlutterSecureStorage? secureStorage,
    Logger? logger,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _logger = logger ?? Logger();

  /// Initialize encryption key from secure storage or generate new one
  Future<void> initializeKey() async {
    try {
      _logger.i('Initializing encryption key...');
      
      // Try to load existing key
      final storedKey = await _secureStorage.read(key: _keyStorageKey);
      
      if (storedKey != null) {
        _logger.d('Loading existing encryption key from secure storage');
        _encryptionKey = encrypt_pkg.Key.fromBase64(storedKey);
      } else {
        _logger.d('Generating new encryption key');
        // Generate new cryptographically secure key
        _encryptionKey = encrypt_pkg.Key.fromSecureRandom(32); // 256 bits
        
        // Store key in secure storage
        await _secureStorage.write(
          key: _keyStorageKey,
          value: _encryptionKey!.base64,
        );
        _logger.i('New encryption key generated and stored securely');
      }
      
      _isInitialized = true;
      _logger.i('Encryption layer initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize encryption key: $e');
      throw Exception('Encryption key initialization failed: $e');
    }
  }

  /// Generate a cryptographically secure IV (Initialization Vector)
  encrypt_pkg.IV _generateSecureIV() {
    return encrypt_pkg.IV.fromSecureRandom(16); // 128 bits
  }

  /// Compress data using GZIP
  Uint8List _compress(String data) {
    try {
      final bytes = utf8.encode(data);
      final compressed = gzip.encode(bytes);
      _logger.d('Compressed ${bytes.length} bytes to ${compressed.length} bytes');
      return Uint8List.fromList(compressed);
    } catch (e) {
      _logger.e('Compression failed: $e');
      rethrow;
    }
  }

  /// Decompress GZIP data
  String _decompress(Uint8List compressedData) {
    try {
      final decompressed = gzip.decode(compressedData);
      final result = utf8.decode(decompressed);
      _logger.d('Decompressed ${compressedData.length} bytes to ${decompressed.length} bytes');
      return result;
    } catch (e) {
      _logger.e('Decompression failed: $e');
      throw Exception('Decompression failed: $e');
    }
  }

  /// Encrypt and compress JSON payload
  /// 
  /// Process:
  /// 1. Compress JSON string using GZIP
  /// 2. Generate secure IV
  /// 3. Encrypt compressed data using AES-256-CBC
  /// 4. Prepend IV to encrypted data (IV is not secret)
  /// 
  /// Returns encrypted bytes with IV prepended
  Future<EncryptionResult<Uint8List, EncryptionError>> encrypt(
    String jsonPayload,
  ) async {
    try {
      if (!_isInitialized || _encryptionKey == null) {
        _logger.e('Encryption layer not initialized');
        return const EncryptionResult.failure(EncryptionError.keyNotFound);
      }

      _logger.d('Encrypting payload (${jsonPayload.length} chars)');

      // Step 1: Compress the JSON payload
      final compressed = _compress(jsonPayload);

      // Step 2: Generate secure IV
      final iv = _generateSecureIV();

      // Step 3: Encrypt using AES-256-CBC
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(_encryptionKey!, mode: encrypt_pkg.AESMode.cbc),
      );
      
      final encrypted = encrypter.encryptBytes(compressed, iv: iv);

      // Step 4: Prepend IV to encrypted data
      // Format: [IV (16 bytes)][Encrypted Data (variable)]
      final result = Uint8List(iv.bytes.length + encrypted.bytes.length);
      result.setRange(0, iv.bytes.length, iv.bytes);
      result.setRange(iv.bytes.length, result.length, encrypted.bytes);

      _logger.i('Encryption successful: ${result.length} bytes');
      return EncryptionResult.success(result);
    } catch (e) {
      _logger.e('Encryption failed: $e');
      return const EncryptionResult.failure(EncryptionError.encryptionFailed);
    }
  }

  /// Decrypt and decompress encrypted payload
  /// 
  /// Process:
  /// 1. Extract IV from first 16 bytes
  /// 2. Decrypt remaining bytes using AES-256-CBC
  /// 3. Decompress decrypted data using GZIP
  /// 4. Return JSON string
  /// 
  /// Returns decrypted JSON string or error
  Future<EncryptionResult<String, EncryptionError>> decrypt(
    Uint8List encryptedData,
  ) async {
    try {
      if (!_isInitialized || _encryptionKey == null) {
        _logger.e('Encryption layer not initialized');
        return const EncryptionResult.failure(EncryptionError.keyNotFound);
      }

      _logger.d('Decrypting payload (${encryptedData.length} bytes)');

      // Validate minimum length (IV + at least 1 block)
      if (encryptedData.length < 32) {
        _logger.e('Invalid encrypted data: too short');
        return const EncryptionResult.failure(EncryptionError.invalidData);
      }

      // Step 1: Extract IV from first 16 bytes
      final ivBytes = encryptedData.sublist(0, 16);
      final iv = encrypt_pkg.IV(ivBytes);

      // Step 2: Extract encrypted data
      final encryptedBytes = encryptedData.sublist(16);

      // Step 3: Decrypt using AES-256-CBC
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(_encryptionKey!, mode: encrypt_pkg.AESMode.cbc),
      );

      final decrypted = encrypter.decryptBytes(
        encrypt_pkg.Encrypted(encryptedBytes),
        iv: iv,
      );

      // Step 4: Decompress
      final decompressed = _decompress(Uint8List.fromList(decrypted));

      _logger.i('Decryption successful: ${decompressed.length} chars');
      return EncryptionResult.success(decompressed);
    } on FormatException catch (e) {
      _logger.e('Decompression failed: $e');
      return const EncryptionResult.failure(EncryptionError.decompressionFailed);
    } catch (e) {
      _logger.e('Decryption failed: $e');
      return const EncryptionResult.failure(EncryptionError.decryptionFailed);
    }
  }

  /// Check if encryption layer is initialized
  bool get isInitialized => _isInitialized;

  /// Reset encryption key (for testing or key rotation)
  Future<void> resetKey() async {
    try {
      _logger.w('Resetting encryption key');
      await _secureStorage.delete(key: _keyStorageKey);
      _encryptionKey = null;
      _isInitialized = false;
      await initializeKey();
      _logger.i('Encryption key reset successfully');
    } catch (e) {
      _logger.e('Failed to reset encryption key: $e');
      throw Exception('Key reset failed: $e');
    }
  }

  /// Get encryption key for testing purposes (should not be used in production)
  @visibleForTesting
  String? get encryptionKeyBase64 => _encryptionKey?.base64;
}
