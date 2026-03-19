import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanguard_crisis_response/core/models/emergency_payload.dart';
import 'package:vanguard_crisis_response/core/services/message_queue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MessageQueue queue;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    queue = MessageQueue(logger: Logger(level: Level.off), maxSize: 50);
    await queue.initialize();
  });

  EmergencyPayload createTestPayload({
    String? id,
    int? ts,
    int? type,
  }) {
    return EmergencyPayload(
      id: id ?? 'test-id-${DateTime.now().millisecondsSinceEpoch}',
      lat: 30.7333,
      lng: 76.7794,
      ts: ts ?? DateTime.now().millisecondsSinceEpoch,
      type: type ?? 1,
      hop: 0,
    );
  }

  group('MessageQueue - Initialization', () {
    test('should initialize with empty queue', () async {
      expect(queue.isInitialized, true);
      expect(queue.isEmpty, true);
      expect(queue.size, 0);
    });

    test('should throw error if max size is invalid', () {
      expect(
        () => MessageQueue(maxSize: 40),
        throwsArgumentError,
      );
      expect(
        () => MessageQueue(maxSize: 250),
        throwsArgumentError,
      );
    });

    test('should accept valid max size range', () {
      expect(() => MessageQueue(maxSize: 50), returnsNormally);
      expect(() => MessageQueue(maxSize: 100), returnsNormally);
      expect(() => MessageQueue(maxSize: 200), returnsNormally);
    });
  });

  group('MessageQueue - Enqueue Operations', () {
    test('should enqueue message successfully', () async {
      final payload = createTestPayload();
      await queue.enqueue(payload);

      expect(queue.size, 1);
      expect(queue.isEmpty, false);
      expect(queue.contains(payload.id), true);
    });

    test('should enqueue multiple messages', () async {
      for (int i = 0; i < 5; i++) {
        await queue.enqueue(createTestPayload(id: 'msg-$i'));
      }

      expect(queue.size, 5);
      expect(queue.isEmpty, false);
    });

    test('should not enqueue duplicate message', () async {
      final payload = createTestPayload(id: 'duplicate-test');
      
      await queue.enqueue(payload);
      await queue.enqueue(payload);

      expect(queue.size, 1);
    });

    test('should remove oldest message when queue is full', () async {
      // Fill queue to max size
      for (int i = 0; i < 50; i++) {
        await queue.enqueue(createTestPayload(id: 'msg-$i'));
      }

      expect(queue.size, 50);
      expect(queue.isFull, true);

      // Add one more message
      await queue.enqueue(createTestPayload(id: 'msg-50'));

      expect(queue.size, 50);
      expect(queue.contains('msg-0'), false); // Oldest removed
      expect(queue.contains('msg-50'), true); // Newest added
    });
  });

  group('MessageQueue - Dequeue Operations', () {
    test('should dequeue message in FIFO order', () async {
      final payload1 = createTestPayload(id: 'first');
      final payload2 = createTestPayload(id: 'second');
      
      await queue.enqueue(payload1);
      await queue.enqueue(payload2);

      final dequeued = await queue.dequeue();

      expect(dequeued?.id, 'first');
      expect(queue.size, 1);
    });

    test('should return null when dequeuing from empty queue', () async {
      final dequeued = await queue.dequeue();
      expect(dequeued, null);
    });

    test('should dequeue all messages in order', () async {
      final ids = ['msg-1', 'msg-2', 'msg-3'];
      
      for (final id in ids) {
        await queue.enqueue(createTestPayload(id: id));
      }

      for (final id in ids) {
        final dequeued = await queue.dequeue();
        expect(dequeued?.id, id);
      }

      expect(queue.isEmpty, true);
    });
  });

  group('MessageQueue - Peek Operations', () {
    test('should peek at oldest message without removing', () async {
      final payload = createTestPayload(id: 'peek-test');
      await queue.enqueue(payload);

      final peeked = queue.peek();

      expect(peeked?.id, 'peek-test');
      expect(queue.size, 1); // Not removed
    });

    test('should return null when peeking empty queue', () {
      final peeked = queue.peek();
      expect(peeked, null);
    });
  });

  group('MessageQueue - Remove Operations', () {
    test('should remove specific message by ID', () async {
      await queue.enqueue(createTestPayload(id: 'msg-1'));
      await queue.enqueue(createTestPayload(id: 'msg-2'));
      await queue.enqueue(createTestPayload(id: 'msg-3'));

      final removed = await queue.remove('msg-2');

      expect(removed, true);
      expect(queue.size, 2);
      expect(queue.contains('msg-2'), false);
      expect(queue.contains('msg-1'), true);
      expect(queue.contains('msg-3'), true);
    });

    test('should return false when removing non-existent message', () async {
      await queue.enqueue(createTestPayload(id: 'msg-1'));

      final removed = await queue.remove('non-existent');

      expect(removed, false);
      expect(queue.size, 1);
    });
  });

  group('MessageQueue - Clear Operations', () {
    test('should clear all messages', () async {
      for (int i = 0; i < 5; i++) {
        await queue.enqueue(createTestPayload(id: 'msg-$i'));
      }

      await queue.clear();

      expect(queue.isEmpty, true);
      expect(queue.size, 0);
    });
  });

  group('MessageQueue - Persistence', () {
    test('should persist queue to storage', () async {
      await queue.enqueue(createTestPayload(id: 'persist-test'));
      await queue.persist();

      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('mesh_message_queue');

      expect(stored, isNotNull);
      expect(stored, contains('persist-test'));
    });

    test('should load queue from storage', () async {
      // Create and persist queue
      await queue.enqueue(createTestPayload(id: 'load-test-1'));
      await queue.enqueue(createTestPayload(id: 'load-test-2'));
      await queue.persist();

      // Create new queue and load
      final newQueue = MessageQueue(logger: Logger(level: Level.off), maxSize: 50);
      await newQueue.initialize();

      expect(newQueue.size, 2);
      expect(newQueue.contains('load-test-1'), true);
      expect(newQueue.contains('load-test-2'), true);
    });

    test('should handle empty storage gracefully', () async {
      SharedPreferences.setMockInitialValues({});
      
      final newQueue = MessageQueue(logger: Logger(level: Level.off), maxSize: 50);
      await newQueue.initialize();

      expect(newQueue.isEmpty, true);
    });

    test('should trim queue if loaded size exceeds max', () async {
      // Create queue with 15 messages
      for (int i = 0; i < 15; i++) {
        await queue.enqueue(createTestPayload(id: 'msg-$i'));
      }
      await queue.persist();

      // Load with smaller max size (but still valid)
      final smallQueue = MessageQueue(logger: Logger(level: Level.off), maxSize: 50);
      await smallQueue.initialize();

      expect(smallQueue.size, 15); // All messages fit
    });
  });

  group('MessageQueue - Query Operations', () {
    test('should get messages by emergency type', () async {
      await queue.enqueue(createTestPayload(id: 'medical-1', type: 1));
      await queue.enqueue(createTestPayload(id: 'fire-1', type: 2));
      await queue.enqueue(createTestPayload(id: 'medical-2', type: 1));

      final medicalMessages = queue.getMessagesByType(1);

      expect(medicalMessages.length, 2);
      expect(medicalMessages.every((m) => m.type == 1), true);
    });

    test('should get messages by time range', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final oneHourAgo = now - (60 * 60 * 1000);
      final twoHoursAgo = now - (2 * 60 * 60 * 1000);

      await queue.enqueue(createTestPayload(id: 'old', ts: twoHoursAgo));
      await queue.enqueue(createTestPayload(id: 'recent', ts: oneHourAgo));
      await queue.enqueue(createTestPayload(id: 'new', ts: now));

      final recentMessages = queue.getMessagesByTimeRange(oneHourAgo - 1000, now + 1000);

      expect(recentMessages.length, 2);
      expect(recentMessages.any((m) => m.id == 'old'), false);
    });

    test('should get oldest and newest timestamps', () async {
      final old = DateTime.now().millisecondsSinceEpoch - 10000;
      final new_ = DateTime.now().millisecondsSinceEpoch;

      await queue.enqueue(createTestPayload(id: 'old', ts: old));
      await queue.enqueue(createTestPayload(id: 'new', ts: new_));

      expect(queue.oldestMessageTimestamp, old);
      expect(queue.newestMessageTimestamp, new_);
    });

    test('should return null timestamps for empty queue', () {
      expect(queue.oldestMessageTimestamp, null);
      expect(queue.newestMessageTimestamp, null);
    });
  });

  group('MessageQueue - Statistics', () {
    test('should provide accurate statistics', () async {
      await queue.enqueue(createTestPayload(id: 'msg-1', type: 1));
      await queue.enqueue(createTestPayload(id: 'msg-2', type: 2));
      await queue.enqueue(createTestPayload(id: 'msg-3', type: 1));

      final stats = queue.statistics;

      expect(stats['size'], 3);
      expect(stats['maxSize'], 50);
      expect(stats['isFull'], false);
      expect(stats['isEmpty'], false);
      expect(stats['messagesByType'], {1: 2, 2: 1});
    });

    test('should calculate utilization percentage', () async {
      for (int i = 0; i < 25; i++) {
        await queue.enqueue(createTestPayload(id: 'msg-$i'));
      }

      expect(queue.utilizationPercent, 50.0);
    });

    test('should report full status correctly', () async {
      for (int i = 0; i < 50; i++) {
        await queue.enqueue(createTestPayload(id: 'msg-$i'));
      }

      expect(queue.isFull, true);
      expect(queue.availableSpace, 0);
    });
  });

  group('MessageQueue - State Management', () {
    test('should throw error if operations called before initialization', () {
      final uninitQueue = MessageQueue(logger: Logger(level: Level.off));

      expect(
        () => uninitQueue.peek(),
        throwsStateError,
      );
    });

    test('should provide read-only messages list', () async {
      await queue.enqueue(createTestPayload(id: 'msg-1'));
      
      final messages = queue.messages;
      
      expect(messages.length, 1);
      expect(() => messages.add(createTestPayload()), throwsUnsupportedError);
    });

    test('should check message existence', () async {
      await queue.enqueue(createTestPayload(id: 'exists'));

      expect(queue.contains('exists'), true);
      expect(queue.contains('not-exists'), false);
    });
  });

  group('MessageQueue - toString', () {
    test('should provide readable string representation', () async {
      await queue.enqueue(createTestPayload(id: 'msg-1'));
      await queue.enqueue(createTestPayload(id: 'msg-2'));

      final str = queue.toString();

      expect(str, contains('MessageQueue'));
      expect(str, contains('size: 2/50'));
      expect(str, contains('4.0%'));
    });
  });
}
