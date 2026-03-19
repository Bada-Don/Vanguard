import 'package:flutter_test/flutter_test.dart';
import 'package:vanguard_crisis_response/core/models/mesh_network_config.dart';

void main() {
  group('MeshNetworkConfig', () {
    const testConfig = MeshNetworkConfig(
      maxHops: 4,
      messageQueueSize: 150,
      uplinkRetryAttempts: 3,
      connectionTimeout: 30,
      scanFrequency: 10,
      enableBackgroundService: true,
      enableAutoUplink: true,
    );

    test('should create config with all fields', () {
      expect(testConfig.maxHops, 4);
      expect(testConfig.messageQueueSize, 150);
      expect(testConfig.uplinkRetryAttempts, 3);
      expect(testConfig.connectionTimeout, 30);
      expect(testConfig.scanFrequency, 10);
      expect(testConfig.enableBackgroundService, isTrue);
      expect(testConfig.enableAutoUplink, isTrue);
    });

    test('should use default values', () {
      const defaultConfig = MeshNetworkConfig();

      expect(defaultConfig.maxHops, 3);
      expect(defaultConfig.messageQueueSize, 100);
      expect(defaultConfig.uplinkRetryAttempts, 3);
      expect(defaultConfig.connectionTimeout, 30);
      expect(defaultConfig.scanFrequency, 10);
      expect(defaultConfig.enableBackgroundService, isTrue);
      expect(defaultConfig.enableAutoUplink, isTrue);
    });

    test('should validate correct configuration', () {
      expect(testConfig.isValid, isTrue);
      expect(testConfig.validationErrors, isEmpty);
    });

    test('should invalidate config with maxHops out of range', () {
      const invalidConfig = MeshNetworkConfig(maxHops: 2);
      expect(invalidConfig.isValid, isFalse);
      expect(invalidConfig.validationErrors, contains('Max hops must be between 3 and 5'));

      const invalidConfig2 = MeshNetworkConfig(maxHops: 6);
      expect(invalidConfig2.isValid, isFalse);
    });

    test('should invalidate config with messageQueueSize out of range', () {
      const invalidConfig = MeshNetworkConfig(messageQueueSize: 40);
      expect(invalidConfig.isValid, isFalse);
      expect(invalidConfig.validationErrors, contains('Message queue size must be between 50 and 200'));

      const invalidConfig2 = MeshNetworkConfig(messageQueueSize: 250);
      expect(invalidConfig2.isValid, isFalse);
    });

    test('should invalidate config with uplinkRetryAttempts out of range', () {
      const invalidConfig = MeshNetworkConfig(uplinkRetryAttempts: 0);
      expect(invalidConfig.isValid, isFalse);
      expect(invalidConfig.validationErrors, contains('Uplink retry attempts must be between 1 and 5'));

      const invalidConfig2 = MeshNetworkConfig(uplinkRetryAttempts: 6);
      expect(invalidConfig2.isValid, isFalse);
    });

    test('should invalidate config with connectionTimeout out of range', () {
      const invalidConfig = MeshNetworkConfig(connectionTimeout: 5);
      expect(invalidConfig.isValid, isFalse);
      expect(invalidConfig.validationErrors, contains('Connection timeout must be between 10 and 60 seconds'));

      const invalidConfig2 = MeshNetworkConfig(connectionTimeout: 70);
      expect(invalidConfig2.isValid, isFalse);
    });

    test('should invalidate config with scanFrequency out of range', () {
      const invalidConfig = MeshNetworkConfig(scanFrequency: 3);
      expect(invalidConfig.isValid, isFalse);
      expect(invalidConfig.validationErrors, contains('Scan frequency must be between 5 and 30 seconds'));

      const invalidConfig2 = MeshNetworkConfig(scanFrequency: 35);
      expect(invalidConfig2.isValid, isFalse);
    });

    test('should serialize to JSON correctly', () {
      final json = testConfig.toJson();

      expect(json['maxHops'], 4);
      expect(json['messageQueueSize'], 150);
      expect(json['uplinkRetryAttempts'], 3);
      expect(json['connectionTimeout'], 30);
      expect(json['scanFrequency'], 10);
      expect(json['enableBackgroundService'], isTrue);
      expect(json['enableAutoUplink'], isTrue);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'maxHops': 5,
        'messageQueueSize': 200,
        'uplinkRetryAttempts': 4,
        'connectionTimeout': 45,
        'scanFrequency': 15,
        'enableBackgroundService': false,
        'enableAutoUplink': false,
      };

      final config = MeshNetworkConfig.fromJson(json);

      expect(config.maxHops, 5);
      expect(config.messageQueueSize, 200);
      expect(config.uplinkRetryAttempts, 4);
      expect(config.connectionTimeout, 45);
      expect(config.scanFrequency, 15);
      expect(config.enableBackgroundService, isFalse);
      expect(config.enableAutoUplink, isFalse);
    });

    test('should use defaults for missing JSON fields', () {
      final json = <String, dynamic>{};
      final config = MeshNetworkConfig.fromJson(json);

      expect(config.maxHops, 3);
      expect(config.messageQueueSize, 100);
      expect(config.uplinkRetryAttempts, 3);
    });

    test('should serialize and deserialize JSON string correctly', () {
      final jsonString = testConfig.toJsonString();
      final deserializedConfig = MeshNetworkConfig.fromJsonString(jsonString);

      expect(deserializedConfig, testConfig);
    });

    test('should support equality comparison', () {
      const config1 = MeshNetworkConfig(maxHops: 4, messageQueueSize: 150);
      const config2 = MeshNetworkConfig(maxHops: 4, messageQueueSize: 150);

      expect(config1, config2);
    });

    test('should create copy with updated fields', () {
      final copied = testConfig.copyWith(
        maxHops: 5,
        enableBackgroundService: false,
      );

      expect(copied.maxHops, 5);
      expect(copied.enableBackgroundService, isFalse);
      expect(copied.messageQueueSize, testConfig.messageQueueSize);
      expect(copied.uplinkRetryAttempts, testConfig.uplinkRetryAttempts);
    });

    test('should access default config constant', () {
      expect(MeshNetworkConfig.defaultConfig.maxHops, 3);
      expect(MeshNetworkConfig.defaultConfig.messageQueueSize, 100);
      expect(MeshNetworkConfig.defaultConfig.isValid, isTrue);
    });
  });
}
