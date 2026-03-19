import '../../../core/app_export.dart';
import '../models/emergency_sos_dashboard_model.dart';
import 'package:vanguard_crisis_response/core/services/payload_generator.dart';
import 'package:vanguard_crisis_response/core/services/encryption_layer.dart';
import 'package:vanguard_crisis_response/core/services/nearby_service.dart';
import 'package:vanguard_crisis_response/core/models/emergency_payload.dart';

part 'emergency_sos_dashboard_event.dart';
part 'emergency_sos_dashboard_state.dart';

class EmergencySOSDashboardBloc
    extends Bloc<EmergencySOSDashboardEvent, EmergencySOSDashboardState> {
  final PayloadGenerator payloadGenerator;
  final EncryptionLayer encryptionLayer;
  final NearbyService nearbyService;

  EmergencySOSDashboardBloc({
    required EmergencySOSDashboardState initialState,
    required this.payloadGenerator,
    required this.encryptionLayer,
    required this.nearbyService,
  }) : super(initialState) {
    on<EmergencySOSDashboardInitialEvent>(_onInitialize);
    on<InitializeSOSEvent>(_onInitializeSOS);
    on<TriggerSOSEvent>(_onTriggerSOS);
    on<UpdateConnectivityStatusEvent>(_onUpdateConnectivityStatus);
    on<UpdateMeshNodesEvent>(_onUpdateMeshNodes);
    on<NavigateToSettingsEvent>(_onNavigateToSettings);
  }

  _onInitialize(
    EmergencySOSDashboardInitialEvent event,
    Emitter<EmergencySOSDashboardState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: false,
        connectivityStatus: 'Online',
        meshNodesCount: 8,
        sectorInfo: 'SECTOR 7-G • HIGH ALERT',
        isSOSActive: false,
      ),
    );
  }

  _onInitializeSOS(
    InitializeSOSEvent event,
    Emitter<EmergencySOSDashboardState> emit,
  ) async {
    emit(state.copyWith(isSOSActivating: true));

    // Simulate SOS initialization process
    await Future.delayed(Duration(seconds: 1));

    emit(
      state.copyWith(
        isSOSActivating: false,
        isSOSActive: true,
        sosActivationTime: DateTime.now(),
      ),
    );

    // Navigate to Emergency Category Selection screen
    NavigatorService.pushNamed(AppRoutes.emergencyCategorySelectionScreen);
  }

  _onTriggerSOS(
    TriggerSOSEvent event,
    Emitter<EmergencySOSDashboardState> emit,
  ) async {
    emit(SOSTriggeredState(state));
    emit(SOSTransmittingState(state));
    
    try {
      final emergencyTypeEnum = EmergencyType.values.firstWhere(
        (e) => e.value == event.emergencyType,
        orElse: () => EmergencyType.other,
      );

      final payloadResult = await payloadGenerator.generatePayload(
        emergencyType: emergencyTypeEnum,
      );

      if (!payloadResult.isSuccess || payloadResult.data == null) {
        emit(SOSErrorState(state, 'Payload generation failed: ${payloadResult.error}'));
        return;
      }

      final payloadData = payloadResult.data!;
      final jsonPayload = payloadData.toJsonString();
      
      final encryptResult = await encryptionLayer.encrypt(jsonPayload);
      
      if (!encryptResult.isSuccess || encryptResult.data == null) {
        emit(SOSErrorState(state, 'Payload encryption failed: ${encryptResult.error}'));
        return;
      }

      final encryptedPayload = encryptResult.data!;
      final sendResultCount = await nearbyService.sendPayload(encryptedPayload);

      // Either we actually transmitted it, or the nearby service queued it up 
      if (sendResultCount > 0 || nearbyService.queuedPayloadsCount > 0) {
        emit(SOSSuccessState(state));
      } else {
        emit(SOSErrorState(state, 'Failed to transmit payload directly. Please get closer.'));
      }
    } catch (e) {
      emit(SOSErrorState(state, 'Unexpected error triggering SOS: $e'));
    }
  }

  _onUpdateConnectivityStatus(
    UpdateConnectivityStatusEvent event,
    Emitter<EmergencySOSDashboardState> emit,
  ) async {
    emit(state.copyWith(connectivityStatus: event.status));
  }

  _onUpdateMeshNodes(
    UpdateMeshNodesEvent event,
    Emitter<EmergencySOSDashboardState> emit,
  ) async {
    emit(state.copyWith(meshNodesCount: event.count));
  }

  _onNavigateToSettings(
    NavigateToSettingsEvent event,
    Emitter<EmergencySOSDashboardState> emit,
  ) async {
    NavigatorService.pushNamed(AppRoutes.configurationSettingsScreen);
  }
}
