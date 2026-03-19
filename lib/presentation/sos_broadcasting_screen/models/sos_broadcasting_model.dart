import '../../../core/app_export.dart';

/// This class is used in the [sos_broadcasting_screen] screen.

// ignore_for_file: must_be_immutable
class SOSBroadcastingModel extends Equatable {
  SOSBroadcastingModel({
    this.nearbyDevicesCount,
    this.additionalDevices,
    this.currentLocation,
    this.transmissionLogs,
  }) {
    nearbyDevicesCount = nearbyDevicesCount ?? 14;
    additionalDevices = additionalDevices ?? 1;
    currentLocation = currentLocation ?? "37.7749° N, 122.4194° W";
    transmissionLogs = transmissionLogs ?? [];
  }

  int? nearbyDevicesCount;
  int? additionalDevices;
  String? currentLocation;
  List<TransmissionLogModel>? transmissionLogs;

  SOSBroadcastingModel copyWith({
    int? nearbyDevicesCount,
    int? additionalDevices,
    String? currentLocation,
    List<TransmissionLogModel>? transmissionLogs,
  }) {
    return SOSBroadcastingModel(
      nearbyDevicesCount: nearbyDevicesCount ?? this.nearbyDevicesCount,
      additionalDevices: additionalDevices ?? this.additionalDevices,
      currentLocation: currentLocation ?? this.currentLocation,
      transmissionLogs: transmissionLogs ?? this.transmissionLogs,
    );
  }

  @override
  List<Object?> get props => [
    nearbyDevicesCount,
    additionalDevices,
    currentLocation,
    transmissionLogs,
  ];
}

// ignore_for_file: must_be_immutable
class TransmissionLogModel extends Equatable {
  TransmissionLogModel({
    this.id,
    this.sourceNode,
    this.destinationNode,
    this.details,
    this.timestamp,
    this.icon,
  }) {
    id = id ?? "";
    sourceNode = sourceNode ?? "";
    destinationNode = destinationNode ?? "";
    details = details ?? "";
    timestamp = timestamp ?? "";
    icon = icon ?? "";
  }

  String? id;
  String? sourceNode;
  String? destinationNode;
  String? details;
  String? timestamp;
  String? icon;

  TransmissionLogModel copyWith({
    String? id,
    String? sourceNode,
    String? destinationNode,
    String? details,
    String? timestamp,
    String? icon,
  }) {
    return TransmissionLogModel(
      id: id ?? this.id,
      sourceNode: sourceNode ?? this.sourceNode,
      destinationNode: destinationNode ?? this.destinationNode,
      details: details ?? this.details,
      timestamp: timestamp ?? this.timestamp,
      icon: icon ?? this.icon,
    );
  }

  @override
  List<Object?> get props => [
    id,
    sourceNode,
    destinationNode,
    details,
    timestamp,
    icon,
  ];
}
