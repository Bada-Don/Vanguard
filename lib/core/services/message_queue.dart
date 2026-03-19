import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanguard_crisis_response/core/models/emergency_payload.dart';

/// Message queue for storing payloads awaiting transmission or uplink
/// Implements FIFO queue with persistence to shared_preferences
class MessageQueue {
  static const String _storageKey = 'mesh_message_queue';
  static const int _defaultMaxSize = 100;

  final Logger _logger;
  final int maxSize;
  final List<EmergencyPayload> _queue = [];
  
  bool _isInitialized = false;

  MessageQueue({
    Logger? logger,
    this.maxSize = _defaultMaxSize,
  }) : _logger = logger ?? Logger() {
    if (maxSize < 50 || maxSize > 200) {
      throw ArgumentError('Max size must be between 50 and 200');
    }
  }

  /// Initialize queue by loading persisted messages
  Future<void> initialize() async {
    try {
      _logger.i('Initializing message queue (max size: $maxSize)');
      await load();
      _isInitialized = true;
      _logger.i('Message queue initialized with ${_queue.length} messages');
    } catch (e) {
      _logger.e('Failed to initialize message queue: $e');
      throw Exception('Message queue initialization failed: $e');
    }
  }

  /// Enqueue a new emergency payload
  /// 
  /// If queue is full, removes oldest message (FIFO)
  /// Automatically persists queue after enqueue
  Future<void> enqueue(EmergencyPayload payload) async {
    try {
      _ensureInitialized();

      _logger.d('Enqueuing message: ${payload.id}');

      // Check if message already exists in queue
      if (_queue.any((p) => p.id == payload.id)) {
        _logger.w('Message ${payload.id} already in queue, skipping');
        return;
      }

      // Remove oldest message if queue is full
      if (_queue.length >= maxSize) {
        final removed = _queue.removeAt(0);
        _logger.w('Queue full, removed oldest message: ${removed.id}');
      }

      // Add new message to end of queue
      _queue.add(payload);
      _logger.i('Message enqueued: ${payload.id} (queue size: ${_queue.length}/$maxSize)');

      // Persist queue
      await persist();
    } catch (e) {
      _logger.e('Failed to enqueue message: $e');
      rethrow;
    }
  }

  /// Dequeue the oldest emergency payload
  /// 
  /// Returns null if queue is empty
  /// Automatically persists queue after dequeue
  Future<EmergencyPayload?> dequeue() async {
    try {
      _ensureInitialized();

      if (_queue.isEmpty) {
        _logger.d('Queue is empty, nothing to dequeue');
        return null;
      }

      final payload = _queue.removeAt(0);
      _logger.i('Message dequeued: ${payload.id} (remaining: ${_queue.length})');

      // Persist queue
      await persist();

      return payload;
    } catch (e) {
      _logger.e('Failed to dequeue message: $e');
      rethrow;
    }
  }

  /// Peek at the oldest message without removing it
  EmergencyPayload? peek() {
    _ensureInitialized();
    
    if (_queue.isEmpty) {
      return null;
    }

    return _queue.first;
  }

  /// Remove a specific message by ID
  Future<bool> remove(String messageId) async {
    try {
      _ensureInitialized();

      final initialLength = _queue.length;
      _queue.removeWhere((p) => p.id == messageId);

      if (_queue.length < initialLength) {
        _logger.i('Message removed: $messageId (remaining: ${_queue.length})');
        await persist();
        return true;
      }

      _logger.d('Message not found in queue: $messageId');
      return false;
    } catch (e) {
      _logger.e('Failed to remove message: $e');
      rethrow;
    }
  }

  /// Clear all messages from queue
  Future<void> clear() async {
    try {
      _ensureInitialized();

      final count = _queue.length;
      _queue.clear();
      _logger.i('Queue cleared ($count messages removed)');

      await persist();
    } catch (e) {
      _logger.e('Failed to clear queue: $e');
      rethrow;
    }
  }

  /// Persist queue to shared_preferences
  Future<void> persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert queue to JSON array
      final jsonArray = _queue.map((p) => p.toJson()).toList();
      final jsonString = jsonEncode(jsonArray);

      await prefs.setString(_storageKey, jsonString);
      _logger.d('Queue persisted (${_queue.length} messages)');
    } catch (e) {
      _logger.e('Failed to persist queue: $e');
      throw Exception('Queue persistence failed: $e');
    }
  }

  /// Load queue from shared_preferences
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        _logger.d('No persisted queue found, starting with empty queue');
        _queue.clear();
        return;
      }

      // Parse JSON array
      final jsonArray = jsonDecode(jsonString) as List<dynamic>;
      _queue.clear();

      for (final json in jsonArray) {
        try {
          final payload = EmergencyPayload.fromJson(json as Map<String, dynamic>);
          _queue.add(payload);
        } catch (e) {
          _logger.w('Failed to parse persisted message, skipping: $e');
        }
      }

      _logger.i('Queue loaded from storage (${_queue.length} messages)');

      // Trim queue if it exceeds max size
      if (_queue.length > maxSize) {
        final excess = _queue.length - maxSize;
        _queue.removeRange(0, excess);
        _logger.w('Queue exceeded max size, removed $excess oldest messages');
        await persist();
      }
    } catch (e) {
      _logger.e('Failed to load queue: $e');
      // Don't throw, just start with empty queue
      _queue.clear();
    }
  }

  /// Check if queue is full
  bool get isFull => _queue.length >= maxSize;

  /// Check if queue is empty
  bool get isEmpty => _queue.isEmpty;

  /// Get current queue size
  int get size => _queue.length;

  /// Get available space in queue
  int get availableSpace => maxSize - _queue.length;

  /// Get queue utilization percentage (0-100)
  double get utilizationPercent => (_queue.length / maxSize) * 100;

  /// Check if queue is initialized
  bool get isInitialized => _isInitialized;

  /// Get all messages in queue (read-only)
  List<EmergencyPayload> get messages => List.unmodifiable(_queue);

  /// Get messages by emergency type
  List<EmergencyPayload> getMessagesByType(int emergencyType) {
    _ensureInitialized();
    return _queue.where((p) => p.type == emergencyType).toList();
  }

  /// Get messages within time range
  List<EmergencyPayload> getMessagesByTimeRange(int startTs, int endTs) {
    _ensureInitialized();
    return _queue.where((p) => p.ts >= startTs && p.ts <= endTs).toList();
  }

  /// Get oldest message timestamp
  int? get oldestMessageTimestamp {
    if (_queue.isEmpty) return null;
    return _queue.first.ts;
  }

  /// Get newest message timestamp
  int? get newestMessageTimestamp {
    if (_queue.isEmpty) return null;
    return _queue.last.ts;
  }

  /// Check if message exists in queue
  bool contains(String messageId) {
    _ensureInitialized();
    return _queue.any((p) => p.id == messageId);
  }

  /// Get queue statistics
  Map<String, dynamic> get statistics {
    _ensureInitialized();

    final typeCount = <int, int>{};
    for (final payload in _queue) {
      typeCount[payload.type] = (typeCount[payload.type] ?? 0) + 1;
    }

    return {
      'size': _queue.length,
      'maxSize': maxSize,
      'isFull': isFull,
      'isEmpty': isEmpty,
      'utilizationPercent': utilizationPercent.toStringAsFixed(1),
      'messagesByType': typeCount,
      'oldestTimestamp': oldestMessageTimestamp,
      'newestTimestamp': newestMessageTimestamp,
    };
  }

  /// Ensure queue is initialized before operations
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('Message queue not initialized. Call initialize() first.');
    }
  }

  @override
  String toString() {
    return 'MessageQueue(size: ${_queue.length}/$maxSize, utilization: ${utilizationPercent.toStringAsFixed(1)}%)';
  }
}
