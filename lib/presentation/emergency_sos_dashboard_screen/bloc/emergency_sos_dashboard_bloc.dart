import '../../../core/app_export.dart';
import '../models/emergency_sos_dashboard_model.dart';

part 'emergency_sos_dashboard_event.dart';
part 'emergency_sos_dashboard_state.dart';

class EmergencySOSDashboardBloc
    extends Bloc<EmergencySOSDashboardEvent, EmergencySOSDashboardState> {
  EmergencySOSDashboardBloc(EmergencySOSDashboardState initialState)
    : super(initialState) {
    on<EmergencySOSDashboardInitialEvent>(_onInitialize);
    on<InitializeSOSEvent>(_onInitializeSOS);
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
