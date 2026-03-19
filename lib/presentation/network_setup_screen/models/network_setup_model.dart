import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';

/// This class is used in the [NetworkSetupScreen] screen.

// ignore_for_file: must_be_immutable
class NetworkSetupModel extends Equatable {
  NetworkSetupModel({
    this.isBluetoothEnabled,
    this.isLocationEnabled,
    this.isBackgroundRelayEnabled,
    this.isWifiDirectEnabled,
    this.id,
  }) {
    isBluetoothEnabled = isBluetoothEnabled ?? false;
    isLocationEnabled = isLocationEnabled ?? false;
    isBackgroundRelayEnabled = isBackgroundRelayEnabled ?? false;
    isWifiDirectEnabled = isWifiDirectEnabled ?? false;
    id = id ?? "";
  }

  bool? isBluetoothEnabled;
  bool? isLocationEnabled;
  bool? isBackgroundRelayEnabled;
  bool? isWifiDirectEnabled;
  String? id;

  NetworkSetupModel copyWith({
    bool? isBluetoothEnabled,
    bool? isLocationEnabled,
    bool? isBackgroundRelayEnabled,
    bool? isWifiDirectEnabled,
    String? id,
  }) {
    return NetworkSetupModel(
      isBluetoothEnabled: isBluetoothEnabled ?? this.isBluetoothEnabled,
      isLocationEnabled: isLocationEnabled ?? this.isLocationEnabled,
      isBackgroundRelayEnabled:
          isBackgroundRelayEnabled ?? this.isBackgroundRelayEnabled,
      isWifiDirectEnabled: isWifiDirectEnabled ?? this.isWifiDirectEnabled,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
    isBluetoothEnabled,
    isLocationEnabled,
    isBackgroundRelayEnabled,
    isWifiDirectEnabled,
    id,
  ];
}
