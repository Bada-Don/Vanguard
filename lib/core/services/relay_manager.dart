import 'dart:async';
import 'dart:typed_data';
import 'package:logger/logger.dart';
import 'package:vanguard_crisis_response/core/models/emergency_payload.dart';
import 'package:vanguard_crisis_response/core/models/mesh_network_config.dart';
import 'package:vanguard_crisis_response/core/services/encryption_layer.dart';
import 'package:vanguard_crisis_response/core/services/message_queue.dart';
import 'package:vanguard_crisis_response/core/services/nearby_service.dart';
import 'package:vanguard_crisis_response/core/services/payload_validator.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'messagesProcessed': messagesProcessed,
      'messagesRelayed': messagesRelayed,
      'messagesDuplicate': messagesDuplicate,
      'messagesDropped': messagesDropped,
      'validationErrors': validationErrors,
      'decryptionErrors': decryptionErrors,
      'lastRelayTimestamp': lastRelayTimestamp,
    };
  }

  @override
  String toString() {
    return 'RelayStatistics(processed: $messagesProcessed, relayed: $messagesRelayed, duplicate: $messagesDuplicate, dropped: $messagesDropped)';
  }
}

/// Relay manager for message reception, duplicate prevention, and multi-hop relay
/// Core component of mesh networking that handles message propagation
class RelayManager {
  final EncryptionLayer _encryptionLayer;
  final PayloadValidator _payloadValidator;
  final NearbyService _nearbyService;
  final MessageQueue _messageQueue;
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
  bool _isInitialized = false;

  RelayManager({
    required EncryptionLayer encryptionLayer,
    required PayloadValidator payloadValidator,
    required NearbyService nearbyService,
    required MessageQueue messageQueue,
    MeshNetworkConfig? config,
    Logger? logger,
  })  : _encryptionLayer = encryptionLayer,
        _payloadValidator = payloadValidator,
        _nearbyService = nearbyService,
        _messageQueue = messageQueue,
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

      _isInitialized = true;
      _logger.i('Relay manager initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize relay manager: $e');
      throw Exception('Relay manager initialization failed: $e');
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
  /// 
  /// Process:
  /// 1. Decrypt payload using EncryptionLayer
  /// 2. Parse JSON and validate all required fields
  /// 3. Check Message_ID against Processed_Messages_Set
  /// 4. Discard duplicates without further processing
  /// 5. Add new Message_IDs to Processed_Messages_Set
  /// 6. Extract and validate hop count
  /// 7. Check if hop < MAX_HOPS
  /// 8. Increment hop count if relaying
  /// 9. Re-encrypt updated payload
  /// 10. Trigger NearbyService.sendPayload for relay
  /// 11. Add to message queue for uplink
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
    await _relayEventController.close();
    _logger.d('Relay manager disposed');
  }

  @override
  String toString() {
    return 'RelayManager(processed: ${_processedMessageIds.length}, stats: $_statistics)';
  }
}
