part of 'emergency_sos_dashboard_bloc.dart';

class EmergencySOSDashboardState extends Equatable {
  final EmergencySOSDashboardModel? emergencySOSDashboardModelObj;
  final bool isLoading;
  final bool isSOSActivating;
  final bool isSOSActive;
  final String connectivityStatus;
  final int meshNodesCount;
  final String sectorInfo;
  final DateTime? sosActivationTime;
  final String? errorMessage;

  EmergencySOSDashboardState({
    this.emergencySOSDashboardModelObj,
    this.isLoading = false,
    this.isSOSActivating = false,
    this.isSOSActive = false,
    this.connectivityStatus = 'Offline',
    this.meshNodesCount = 0,
    this.sectorInfo = 'SECTOR 7-G • LOW ALERT',
    this.sosActivationTime,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    emergencySOSDashboardModelObj,
    isLoading,
    isSOSActivating,
    isSOSActive,
    connectivityStatus,
    meshNodesCount,
    sectorInfo,
    sosActivationTime,
    errorMessage,
  ];

  EmergencySOSDashboardState copyWith({
    EmergencySOSDashboardModel? emergencySOSDashboardModelObj,
    bool? isLoading,
    bool? isSOSActivating,
    bool? isSOSActive,
    String? connectivityStatus,
    int? meshNodesCount,
    String? sectorInfo,
    DateTime? sosActivationTime,
    String? errorMessage,
  }) {
    return EmergencySOSDashboardState(
      emergencySOSDashboardModelObj:
          emergencySOSDashboardModelObj ?? this.emergencySOSDashboardModelObj,
      isLoading: isLoading ?? this.isLoading,
      isSOSActivating: isSOSActivating ?? this.isSOSActivating,
      isSOSActive: isSOSActive ?? this.isSOSActive,
      connectivityStatus: connectivityStatus ?? this.connectivityStatus,
      meshNodesCount: meshNodesCount ?? this.meshNodesCount,
      sectorInfo: sectorInfo ?? this.sectorInfo,
      sosActivationTime: sosActivationTime ?? this.sosActivationTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SOSTriggeredState extends EmergencySOSDashboardState {
  SOSTriggeredState(EmergencySOSDashboardState state) : super(
    emergencySOSDashboardModelObj: state.emergencySOSDashboardModelObj,
    isLoading: state.isLoading,
    isSOSActivating: state.isSOSActivating,
    isSOSActive: true,
    connectivityStatus: state.connectivityStatus,
    meshNodesCount: state.meshNodesCount,
    sectorInfo: state.sectorInfo,
    sosActivationTime: state.sosActivationTime,
    errorMessage: state.errorMessage,
  );
}

class SOSTransmittingState extends EmergencySOSDashboardState {
  SOSTransmittingState(EmergencySOSDashboardState state) : super(
    emergencySOSDashboardModelObj: state.emergencySOSDashboardModelObj,
    isLoading: state.isLoading,
    isSOSActivating: true,
    isSOSActive: true,
    connectivityStatus: state.connectivityStatus,
    meshNodesCount: state.meshNodesCount,
    sectorInfo: state.sectorInfo,
    sosActivationTime: state.sosActivationTime,
    errorMessage: state.errorMessage,
  );
}

class SOSSuccessState extends EmergencySOSDashboardState {
  SOSSuccessState(EmergencySOSDashboardState state) : super(
    emergencySOSDashboardModelObj: state.emergencySOSDashboardModelObj,
    isLoading: state.isLoading,
    isSOSActivating: false,
    isSOSActive: true,
    connectivityStatus: state.connectivityStatus,
    meshNodesCount: state.meshNodesCount,
    sectorInfo: state.sectorInfo,
    sosActivationTime: state.sosActivationTime,
    errorMessage: null,
  );
}

class SOSErrorState extends EmergencySOSDashboardState {
  SOSErrorState(EmergencySOSDashboardState state, String error) : super(
    emergencySOSDashboardModelObj: state.emergencySOSDashboardModelObj,
    isLoading: false,
    isSOSActivating: false,
    isSOSActive: state.isSOSActive,
    connectivityStatus: state.connectivityStatus,
    meshNodesCount: state.meshNodesCount,
    sectorInfo: state.sectorInfo,
    sosActivationTime: state.sosActivationTime,
    errorMessage: error,
  );
}
