import 'package:flutter/services.dart';

/// Platform channel handler for native code communication
/// Manages communication between Flutter and native Android/iOS code
class PlatformChannelHandler {
  /// Channel for Nearby Service operations
  static const MethodChannel nearbyChannel = MethodChannel('com.vanguard.crisis/nearby');

  /// Channel for background service operations
  static const MethodChannel backgroundChannel = MethodChannel('com.vanguard.crisis/background');

  /// Event channel for connection state updates
  static const EventChannel connectionEventChannel = EventChannel('com.vanguard.crisis/connection_events');

  /// Event channel for payload reception
  static const EventChannel payloadEventChannel = EventChannel('com.vanguard.crisis/payload_events');

  /// Start advertising with the given user name
  static Future<bool> startAdvertising(String userName) async {
    try {
      final result = await nearbyChannel.invokeMethod('startAdvertising', {
        'userName': userName,
      });
      return result as bool;
    } on PlatformException catch (e) {
      throw Exception('Failed to start advertising: ${e.message}');
    }
  }

  /// Start discovery
  static Future<bool> startDiscovery() async {
    try {
      final result = await nearbyChannel.invokeMethod('startDiscovery');
      return result as bool;
    } on PlatformException catch (e) {
      throw Exception('Failed to start discovery: ${e.message}');
    }
  }

  /// Stop advertising
  static Future<bool> stopAdvertising() async {
    try {
      final result = await nearbyChannel.invokeMethod('stopAdvertising');
      return result as bool;
    } on PlatformException catch (e) {
      throw Exception('Failed to stop advertising: ${e.message}');
    }
  }

  /// Stop discovery
  static Future<bool> stopDiscovery() async {
    try {
      final result = await nearbyChannel.invokeMethod('stopDiscovery');
      return result as bool;
    } on PlatformException catch (e) {
      throw Exception('Failed to stop discovery: ${e.message}');
    }
  }

  /// Send payload to all connected endpoints
  static Future<int> sendPayload(List<int> payload) async {
    try {
      final result = await nearbyChannel.invokeMethod('sendPayload', {
        'payload': payload,
      });
      return result as int;
    } on PlatformException catch (e) {
      throw Exception('Failed to send payload: ${e.message}');
    }
  }

  /// Get connected endpoints count
  static Future<int> getConnectedEndpointsCount() async {
    try {
      final result = await nearbyChannel.invokeMethod('getConnectedEndpointsCount');
      return result as int;
    } on PlatformException catch (e) {
      throw Exception('Failed to get endpoints count: ${e.message}');
    }
  }

  /// Get connected endpoints list
  static Future<List<String>> getConnectedEndpoints() async {
    try {
      final result = await nearbyChannel.invokeMethod('getConnectedEndpoints');
      return List<String>.from(result as List);
    } on PlatformException catch (e) {
      throw Exception('Failed to get endpoints: ${e.message}');
    }
  }
}
