import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanguard_crisis_response/presentation/emergency_sos_dashboard_screen/bloc/emergency_sos_dashboard_bloc.dart';
import 'package:vanguard_crisis_response/core/services/payload_generator.dart';
import 'package:vanguard_crisis_response/core/services/encryption_layer.dart';
import 'package:vanguard_crisis_response/core/services/nearby_service.dart';
import 'package:vanguard_crisis_response/core/models/emergency_payload.dart';

class MockPayloadGenerator extends Fake implements PayloadGenerator {
  @override
  Future<PayloadResult<EmergencyPayload, PayloadError>> generatePayload({
    required EmergencyType emergencyType,
  }) async {
    final payload = EmergencyPayload(
      id: 'test_id',
      lat: 0.0,
      lng: 0.0,
      ts: 12345678,
      type: emergencyType.value,
      hop: 0,
      accuracy: 10.0,
    );
    return PayloadResult.success(payload);
  }
}

class MockEncryptionLayer extends Fake implements EncryptionLayer {
  @override
  Future<EncryptionResult<Uint8List>> encrypt(String data) async {
    return EncryptionResult.success(Uint8List.fromList([1, 2, 3]));
  }
}

class MockNearbyService extends Fake implements NearbyService {
  @override
  Future<int> sendPayload(Uint8List encryptedPayload) async {
    return 1;
  }
  
  @override
  int get queuedPayloadsCount => 0;
}

void main() {
  group('EmergencySOSDashboardBloc Tests', () {
    late EmergencySOSDashboardBloc bloc;

    setUp(() {
      bloc = EmergencySOSDashboardBloc(
        initialState: EmergencySOSDashboardState(),
        payloadGenerator: MockPayloadGenerator(),
        encryptionLayer: MockEncryptionLayer(),
        nearbyService: MockNearbyService(),
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('TriggerSOSEvent progresses through triggered/transmitting/success states', () async {
      final states = <Type>[];
      bloc.stream.listen((state) {
        states.add(state.runtimeType);
      });

      bloc.add(TriggerSOSEvent(emergencyType: 1));
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(states.contains(SOSTriggeredState), isTrue);
      expect(states.contains(SOSTransmittingState), isTrue);
      expect(states.contains(SOSSuccessState), isTrue);
      expect(states.contains(SOSErrorState), isFalse);
    });
  });
}
