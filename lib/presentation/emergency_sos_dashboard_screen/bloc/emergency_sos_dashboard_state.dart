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

  EmergencySOSDashboardState({
    this.emergencySOSDashboardModelObj,
    this.isLoading = false,
    this.isSOSActivating = false,
    this.isSOSActive = false,
    this.connectivityStatus = 'Offline',
    this.meshNodesCount = 0,
    this.sectorInfo = 'SECTOR 7-G • LOW ALERT',
    this.sosActivationTime,
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
    );
  }
}
