import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:vanguard_crisis_response/core/platform/platform_channel_handler.dart';

/// Connection state for mesh networking
enum ConnectionState {
  disconnected,
  advertising,
  discovering,
  connected;

  String get displayName {
    switch (this) {
      case ConnectionState.disconnected:
        return 'Disconnected';
      case ConnectionState.advertising:
        return 'Advertising';
      case ConnectionState.discovering:
        return 'Discovering';
      case ConnectionState.connected:
        return 'Connected';
    }
  }
}

/// Nearby service for managing mesh network connections
/// Abstracts platform-specific implementations (Android/iOS)
class NearbyService {
  final Logger _logger;
  
  // Connection state management
  final StreamController<ConnectionState> _connectionStateController =
      StreamController<ConnectionState>.broadcast();
  
  final StreamController<Map<String, dynamic>> _payloadController =
      StreamController<Map<String, dynamic>>.broadcast();
  
  ConnectionState _currentState = ConnectionState.disconnected;
  final List<String> _connectedEndpoints = [];
  final List<Uint8List> _payloadQueue = [];
  
  bool _isInitialized = false;

  NearbyService({Logger? logger}) : _logger = logger ?? Logger() {
    _initializeEventChannels();
  }

  /// Initialize event channels for receiving platform events
  void _initializeEventChannels() {
    try {
      // Listen to connection state changes
      PlatformChannelHandler.connectionEventChannel
          .receiveBroadcastStream()
          .listen(
        (event) {
          _handleConnectionEvent(event as Map<dynamic, dynamic>);
        },
        onError: (error) {
          _logger.e('Connection event channel error: $error');
        },
      );

      // Listen to payload reception
      PlatformChannelHandler.payloadEventChannel
          .receiveBroadcastStream()
          .listen(
        (event) {
          _handlePayloadEvent(event as Map<dynamic, dynamic>);
        },
        onError: (error) {
          _logger.e('Payload event channel error: $error');
        },
      );

      _isInitialized = true;
      _logger.i('Nearby service event channels initialized');
    } catch (e) {
      _logger.e('Failed to initialize event channels: $e');
    }
  }

  /// Handle connection state events from platform
  void _handleConnectionEvent(Map<dynamic, dynamic> event) {
    try {
      final eventType = event['type'] as String?;
      
      switch (eventType) {
        case 'stateChanged':
          final state = event['state'] as String?;
          _updateConnectionState(_parseConnectionState(state));
          break;
          
        case 'endpointConnected':
          final endpointId = event['endpointId'] as String?;
          if (endpointId != null) {
            _addEndpoint(endpointId);
          }
          break;
          
        case 'endpointDisconnected':
          final endpointId = event['endpointId'] as String?;
          if (endpointId != null) {
            _removeEndpoint(endpointId);
          }
          break;
          
        default:
          _logger.w('Unknown connection event type: $eventType');
      }
    } catch (e) {
      _logger.e('Error handling connection event: $e');
    }
  }

  /// Handle payload reception events from platform
  void _handlePayloadEvent(Map<dynamic, dynamic> event) {
    try {
      final payload = event['payload'] as Uint8List?;
      final endpointId = event['endpointId'] as String?;
      
      if (payload != null) {
        _logger.d('Received payload from $endpointId: ${payload.length} bytes');
        _payloadController.add({
          'payload': payload,
          'endpointId': endpointId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      _logger.e('Error handling payload event: $e');
    }
  }

  /// Parse connection state string from platform
  ConnectionState _parseConnectionState(String? state) {
    switch (state?.toLowerCase()) {
      case 'advertising':
        return ConnectionState.advertising;
      case 'discovering':
        return ConnectionState.discovering;
      case 'connected':
        return ConnectionState.connected;
      default:
        return ConnectionState.disconnected;
    }
  }

  /// Update connection state and notify listeners
  void _updateConnectionState(ConnectionState newState) {
    if (_currentState != newState) {
      _logger.i('Connection state changed: ${_currentState.displayName} -> ${newState.displayName}');
      _currentState = newState;
      _connectionStateController.add(newState);
    }
  }

  /// Add endpoint to connected list
  void _addEndpoint(String endpointId) {
    if (!_connectedEndpoints.contains(endpointId)) {
      _connectedEndpoints.add(endpointId);
      _logger.i('Endpoint connected: $endpointId (total: ${_connectedEndpoints.length})');
      
      // Update state to connected if we have endpoints
      if (_connectedEndpoints.isNotEmpty && _currentState != ConnectionState.connected) {
        _updateConnectionState(ConnectionState.connected);
      }
      
      // Send queued payloads to new endpoint
      _sendQueuedPayloads();
    }
  }

  /// Remove endpoint from connected list
  void _removeEndpoint(String endpointId) {
    if (_connectedEndpoints.remove(endpointId)) {
      _logger.i('Endpoint disconnected: $endpointId (remaining: ${_connectedEndpoints.length})');
      
      // Update state if no endpoints remain
      if (_connectedEndpoints.isEmpty && _currentState == ConnectionState.connected) {
        _updateConnectionState(ConnectionState.advertising);
      }
    }
  }

  /// Start mesh networking (advertising and discovery)
  Future<bool> startMeshNetworking(String userName) async {
    try {
      _logger.i('Starting mesh networking for user: $userName');
      
      // Start advertising
      final advertisingStarted = await PlatformChannelHandler.startAdvertising(userName);
      if (!advertisingStarted) {
        _logger.e('Failed to start advertising');
        return false;
      }
      
      _logger.d('Advertising started successfully');
      _updateConnectionState(ConnectionState.advertising);
      
      // Start discovery
      final discoveryStarted = await PlatformChannelHandler.startDiscovery();
      if (!discoveryStarted) {
        _logger.e('Failed to start discovery');
        return false;
      }
      
      _logger.d('Discovery started successfully');
      _updateConnectionState(ConnectionState.discovering);
      
      _logger.i('Mesh networking started successfully');
      return true;
    } catch (e) {
      _logger.e('Error starting mesh networking: $e');
      return false;
    }
  }

  /// Stop mesh networking (stop advertising and discovery)
  Future<bool> stopMeshNetworking() async {
    try {
      _logger.i('Stopping mesh networking');
      
      // Stop advertising
      final advertisingStopped = await PlatformChannelHandler.stopAdvertising();
      if (!advertisingStopped) {
        _logger.w('Failed to stop advertising');
      }
      
      // Stop discovery
      final discoveryStopped = await PlatformChannelHandler.stopDiscovery();
      if (!discoveryStopped) {
        _logger.w('Failed to stop discovery');
      }
      
      // Clear connected endpoints
      _connectedEndpoints.clear();
      _updateConnectionState(ConnectionState.disconnected);
      
      _logger.i('Mesh networking stopped');
      return advertisingStopped && discoveryStopped;
    } catch (e) {
      _logger.e('Error stopping mesh networking: $e');
      return false;
    }
  }

  /// Send payload to all connected endpoints
  Future<int> sendPayload(Uint8List encryptedPayload) async {
    try {
      if (_connectedEndpoints.isEmpty) {
        _logger.w('No endpoints connected, queueing payload');
        _payloadQueue.add(encryptedPayload);
        return 0;
      }
      
      _logger.d('Sending payload to ${_connectedEndpoints.length} endpoints (${encryptedPayload.length} bytes)');
      
      final sentCount = await PlatformChannelHandler.sendPayload(encryptedPayload);
      
      _logger.i('Payload sent to $sentCount endpoints');
      return sentCount;
    } catch (e) {
      _logger.e('Error sending payload: $e');
      
      // Queue payload for retry
      _payloadQueue.add(encryptedPayload);
      return 0;
    }
  }

  /// Send queued payloads when endpoints connect
  Future<void> _sendQueuedPayloads() async {
    if (_payloadQueue.isEmpty) return;
    
    _logger.i('Sending ${_payloadQueue.length} queued payloads');
    
    final payloadsToSend = List<Uint8List>.from(_payloadQueue);
    _payloadQueue.clear();
    
    for (final payload in payloadsToSend) {
      try {
        await sendPayload(payload);
      } catch (e) {
        _logger.e('Error sending queued payload: $e');
        // Re-queue failed payload
        _payloadQueue.add(payload);
      }
    }
  }

  /// Get connection state stream
  Stream<ConnectionState> get connectionStateStream => _connectionStateController.stream;

  /// Get payload reception stream
  Stream<Map<String, dynamic>> get payloadStream => _payloadController.stream;

  /// Get current connection state
  ConnectionState get currentState => _currentState;

  /// Get connected endpoints count
  int get connectedEndpointsCount => _connectedEndpoints.length;

  /// Get connected endpoints list
  List<String> get connectedEndpoints => List.unmodifiable(_connectedEndpoints);

  /// Get queued payloads count
  int get queuedPayloadsCount => _payloadQueue.length;

  /// Check if mesh networking is active
  bool get isActive => _currentState != ConnectionState.disconnected;

  /// Check if any endpoints are connected
  bool get hasConnections => _connectedEndpoints.isNotEmpty;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Clear payload queue
  void clearPayloadQueue() {
    _payloadQueue.clear();
    _logger.d('Payload queue cleared');
  }

  /// Dispose resources
  void dispose() {
    _connectionStateController.close();
    _payloadController.close();
    _logger.d('Nearby service disposed');
  }
}
