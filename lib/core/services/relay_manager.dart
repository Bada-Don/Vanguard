import 'dart:async';
import 'dart:typed_data';
import 'package:logger/logger.dart';
import 'package:vanguard_crisis_response/core/models/emergency_payload.dart';
import 'package:vanguard_crisis_response/core/models/mesh_network_config.dart';
import 'package:vanguard_crisis_response/core/services/encryption_layer.dart';
import 'package:vanguard_crisis_response/core/services/message_queue.dart';
import 'package:vanguard_crisis_response/core/services/nearby_service.dart';
import 'package:vanguard_crisis_response/core/services/payload_validator.dart';
import 'package:vanguard_crisis_response/core/services/api_client.dart';
import 'package:vanguard_crisis_response/core/services/connectivity_monitor.dart';

/// Relay result types
enum RelayResult {
  success,
  duplicate,
  maxHopsReached,
  validationFailed,
  decryptionFailed,
  encryptionFailed,
  transmissionFailed,
  queueFull,
}

/// Relay statistics for monitoring
class RelayStatistics {
  int messagesProcessed = 0;
  int messagesRelayed = 0;
  int messagesDuplicate = 0;
  int messagesDropped = 0;
  int validationErrors = 0;
  int decryptionErrors = 0;
  int? lastRelayTimestamp;
  int? lastUplinkTimestamp;

  Map<String, dynamic> toJson() {
    return {
      'messagesProcessed': messagesProcessed,
      'messagesRelayed': messagesRelayed,
      'messagesDuplicate': messagesDuplicate,
      'messagesDropped': messagesDropped,
      'validationErrors': validationErrors,
      'decryptionErrors': decryptionErrors,
      'lastRelayTimestamp': lastRelayTimestamp,
      'lastUplinkTimestamp': lastUplinkTimestamp,
    };
  }

  @override
  String toString() {
    return 'RelayStatistics(processed: $messagesProcessed, relayed: $messagesRelayed, duplicate: $messagesDuplicate, dropped: $messagesDropped)';
  }
}

/// Relay manager for message reception, duplicate prevention, multi-hop relay and uplink
/// Core component of mesh networking that handles message propagation
class RelayManager {
  final EncryptionLayer _encryptionLayer;
  final PayloadValidator _payloadValidator;
  final NearbyService _nearbyService;
  final MessageQueue _messageQueue;
  final ConnectivityMonitor _connectivityMonitor;
  final ApiClient _apiClient;
  final MeshNetworkConfig _config;
  final Logger _logger;

  // Duplicate prevention: track processed message IDs
  final Set<String> _processedMessageIds = {};
  
  // Relay statistics
  final RelayStatistics _statistics = RelayStatistics();
  
  // Stream controller for relay events
  final StreamController<Map<String, dynamic>> _relayEventController =
      StreamController<Map<String, dynamic>>.broadcast();

  StreamSubscription<Map<String, dynamic>>? _payloadSubscription;
  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  bool _isInitialized = false;
  bool _isUplinking = false;

  RelayManager({
    required EncryptionLayer encryptionLayer,
    required PayloadValidator payloadValidator,
    required NearbyService nearbyService,
    required MessageQueue messageQueue,
    required ConnectivityMonitor connectivityMonitor,
    required ApiClient apiClient,
    MeshNetworkConfig? config,
    Logger? logger,
  })  : _encryptionLayer = encryptionLayer,
        _payloadValidator = payloadValidator,
        _nearbyService = nearbyService,
        _messageQueue = messageQueue,
        _connectivityMonitor = connectivityMonitor,
        _apiClient = apiClient,
        _config = config ?? MeshNetworkConfig.defaultConfig,
        _logger = logger ?? Logger();

  /// Initialize relay manager and start listening for payloads
  Future<void> initialize() async {
    try {
      _logger.i('Initializing relay manager');

      // Ensure dependencies are initialized
      if (!_encryptionLayer.isInitialized) {
        await _encryptionLayer.initializeKey();
      }

      if (!_messageQueue.isInitialized) {
        await _messageQueue.initialize();
      }
      
      if (_connectivityMonitor.currentStatus == ConnectivityStatus.none) {
        await _connectivityMonitor.initialize();
      }

      // Subscribe to payload reception from NearbyService
      _payloadSubscription = _nearbyService.payloadStream.listen(
        (event) {
          final payload = event['payload'] as Uint8List?;
          final endpointId = event['endpointId'] as String?;
          
          if (payload != null) {
            _handleReceivedPayload(payload, endpointId);
          }
        },
        onError: (error) {
          _logger.e('Error in payload stream: $error');
        },
      );
      
      // Listen to connectivity changes for uplink orchestration
      _connectivitySubscription = _connectivityMonitor.connectivityStream.listen((status) {
        if (status != ConnectivityStatus.none && !_isUplinking && _messageQueue.size > 0) {
          triggerUplink();
        }
      });
      
      // Initial check for uplink
      if (_connectivityMonitor.currentStatus != ConnectivityStatus.none && _messageQueue.size > 0) {
        triggerUplink();
      }

      _isInitialized = true;
      _logger.i('Relay manager initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize relay manager: $e');
      throw Exception('Relay manager initialization failed: $e');
    }
  }

  /// Trigger uplink of queued messages to backend API
  Future<void> triggerUplink() async {
    if (_isUplinking || _messageQueue.size == 0) return;

    try {
      _isUplinking = true;
      _logger.i('Triggering uplink. Queued messages: ${_messageQueue.size}');

      // Stop ongoing mesh networking temporarily
      await _nearbyService.stopMeshNetworking();

      final int initialQueueSize = _messageQueue.size;
      int successCount = 0;
      int failureCount = 0;

      // Extract all current messages
      final List<EmergencyPayload> messagesToUpload = [];
      for (int i = 0; i < initialQueueSize; i++) {
        final payload = await _messageQueue.dequeue();
        if (payload != null) {
          messagesToUpload.add(payload);
        }
      }

      for (final payload in messagesToUpload) {
        // Attempt upload
        final result = await _apiClient.uploadEmergencyMessage(payload);
        
        if (result.isSuccess) {
          _logger.i('Successfully verified and uploaded message ${payload.id}');
          successCount++;
        } else {
          _logger.w('Failed to upload message ${payload.id}, reason: ${result.error}');
          
          // If it's a validation error, we toss it, else re-enqueue
          if (result.error != ApiError.validationError && result.error != ApiError.authenticationError) {
             await _messageQueue.enqueue(payload);
             failureCount++;
          } else {
             _logger.e('Message ${payload.id} rejected by backend due to client formulation error, discarding');
             // Do not re-enqueue
          }
        }
      }

      _statistics.lastUplinkTimestamp = DateTime.now().millisecondsSinceEpoch;
      
      _logger.i('Uplink complete. Success: $successCount, Failed (re-queued): $failureCount');
      
      _emitRelayEvent('uplink_completed', {
        'successCount': successCount,
        'failureCount': failureCount,
      });

    } catch (e) {
      _logger.e('Uplink process failed: $e');
    } finally {
      // Resume mesh networking using the last known username
      final String? userName = _nearbyService.currentUserName;
      if (userName != null) {
        _logger.i('Resuming mesh networking for user: $userName');
        await _nearbyService.startMeshNetworking(userName);
      } else {
        _logger.w('Could not resume mesh networking: No previous user name found.');
      }
      
      _isUplinking = false;
    }
  }

  /// Handle received payload asynchronously
  void _handleReceivedPayload(Uint8List encryptedPayload, String? endpointId) {
    processReceivedPayload(encryptedPayload, endpointId: endpointId).then((result) {
      _logger.d('Payload processing result: $result');
    }).catchError((error) {
      _logger.e('Error processing payload: $error');
    });
  }

  /// Process received encrypted payload
  Future<RelayResult> processReceivedPayload(
    Uint8List encryptedPayload, {
    String? endpointId,
  }) async {
    try {
      _ensureInitialized();
      _statistics.messagesProcessed++;

      _logger.i('Processing received payload from ${endpointId ?? "unknown"} (${encryptedPayload.length} bytes)');

      // Step 1: Decrypt payload
      final decryptResult = await _encryptionLayer.decrypt(encryptedPayload);
      
      if (!decryptResult.isSuccess || decryptResult.data == null) {
        _logger.e('Decryption failed: ${decryptResult.error}');
        _statistics.decryptionErrors++;
        _emitRelayEvent('decryption_failed', {'error': decryptResult.error});
        return RelayResult.decryptionFailed;
      }

      final jsonString = decryptResult.data!;
      _logger.d('Decrypted payload: $jsonString');

      // Step 2: Parse JSON
      EmergencyPayload payload;
      try {
        payload = EmergencyPayload.fromJsonString(jsonString);
      } catch (e) {
        _logger.e('Failed to parse JSON: $e');
        _statistics.validationErrors++;
        return RelayResult.validationFailed;
      }

      // Step 3: Validate payload
      final validationResult = _payloadValidator.validatePayload(payload.toJson());
      if (!validationResult.isValid) {
        _logger.e('Payload validation failed: ${validationResult.errorMessages}');
        _statistics.validationErrors++;
        _emitRelayEvent('validation_failed', {
          'messageId': payload.id,
          'errors': validationResult.errorMessages,
        });
        return RelayResult.validationFailed;
      }

      // Step 4: Check for duplicates
      if (_processedMessageIds.contains(payload.id)) {
        _logger.w('Duplicate message detected: ${payload.id}');
        _statistics.messagesDuplicate++;
        _emitRelayEvent('duplicate_detected', {'messageId': payload.id});
        return RelayResult.duplicate;
      }

      // Step 5: Add to processed set
      _processedMessageIds.add(payload.id);
      _logger.d('Message ${payload.id} added to processed set (total: ${_processedMessageIds.length})');

      // Step 6: Check hop count
      _logger.d('Current hop count: ${payload.hop}, max hops: ${_config.maxHops}');
      
      if (payload.hop >= _config.maxHops) {
        _logger.w('Max hops reached for message ${payload.id}, not relaying');
        _statistics.messagesDropped++;
        _emitRelayEvent('max_hops_reached', {
          'messageId': payload.id,
          'hopCount': payload.hop,
        });
        
        // Still add to queue for uplink
        await _addToQueue(payload);
        return RelayResult.maxHopsReached;
      }

      // Step 7: Increment hop count for relay
      final relayPayload = payload.incrementHop();
      _logger.d('Incremented hop count: ${relayPayload.hop}');

      // Step 8: Re-encrypt updated payload
      final encryptResult = await _encryptionLayer.encrypt(relayPayload.toJsonString());
      
      if (!encryptResult.isSuccess || encryptResult.data == null) {
        _logger.e('Re-encryption failed: ${encryptResult.error}');
        _emitRelayEvent('encryption_failed', {'messageId': payload.id});
        return RelayResult.encryptionFailed;
      }

      final reencryptedPayload = encryptResult.data!;

      // Step 9: Relay to all connected endpoints
      final sentCount = await _nearbyService.sendPayload(reencryptedPayload);
      
      if (sentCount > 0) {
        _logger.i('Message ${payload.id} relayed to $sentCount endpoints');
        _statistics.messagesRelayed++;
        _statistics.lastRelayTimestamp = DateTime.now().millisecondsSinceEpoch;
        
        _emitRelayEvent('message_relayed', {
          'messageId': payload.id,
          'hopCount': relayPayload.hop,
          'endpointCount': sentCount,
        });
      } else {
        _logger.w('No endpoints available for relay, message queued');
      }

      // Step 10: Add to message queue for uplink
      await _addToQueue(payload);

      return RelayResult.success;
    } catch (e) {
      _logger.e('Error processing received payload: $e');
      _statistics.messagesDropped++;
      return RelayResult.transmissionFailed;
    }
  }

  /// Add payload to message queue for uplink
  Future<void> _addToQueue(EmergencyPayload payload) async {
    try {
      if (_messageQueue.isFull) {
        _logger.w('Message queue is full, oldest message will be removed');
      }

      await _messageQueue.enqueue(payload);
      _logger.d('Message ${payload.id} added to queue (size: ${_messageQueue.size})');
      
      _emitRelayEvent('message_queued', {
        'messageId': payload.id,
        'queueSize': _messageQueue.size,
      });

      // Automatically trigger uplink if internet is available
      if (_connectivityMonitor.currentStatus != ConnectivityStatus.none && !_isUplinking) {
        triggerUplink();
      }
    } catch (e) {
      _logger.e('Failed to add message to queue: $e');
    }
  }

  /// Emit relay event to stream
  void _emitRelayEvent(String eventType, Map<String, dynamic> data) {
    _relayEventController.add({
      'type': eventType,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...data,
    });
  }

  /// Check if message has been processed
  bool isMessageProcessed(String messageId) {
    _ensureInitialized();
    return _processedMessageIds.contains(messageId);
  }

  /// Get processed message count
  int get processedMessageCount => _processedMessageIds.length;

  /// Get relay statistics
  RelayStatistics get statistics => _statistics;

  /// Get relay event stream
  Stream<Map<String, dynamic>> get relayEventStream => _relayEventController.stream;

  /// Check if relay manager is initialized
  bool get isInitialized => _isInitialized;

  /// Clear processed message IDs (for testing or maintenance)
  void clearProcessedMessages() {
    _ensureInitialized();
    final count = _processedMessageIds.length;
    _processedMessageIds.clear();
    _logger.i('Cleared $count processed message IDs');
  }

  /// Get configuration
  MeshNetworkConfig get config => _config;

  /// Ensure relay manager is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('Relay manager not initialized. Call initialize() first.');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _payloadSubscription?.cancel();
    await _connectivitySubscription?.cancel();
    await _relayEventController.close();
    _logger.d('Relay manager disposed');
  }

  @override
  String toString() {
    return 'RelayManager(processed: ${_processedMessageIds.length}, stats: $_statistics)';
  }
}
