import '../../../core/app_export.dart';

/// This class is used in the [ConfigurationSettingsScreen] screen.

// ignore_for_file: must_be_immutable
class ConfigurationSettingsModel extends Equatable {
  ConfigurationSettingsModel({
    this.userId,
    this.emergencyContact,
    this.isWifiDirectEnabled,
    this.isBluetoothEnabled,
    this.criticalPowerThreshold,
  }) {
    userId = userId ?? "NX-7742-BRAVO";
    emergencyContact = emergencyContact ?? "+1 (555) 000-0000";
    isWifiDirectEnabled = isWifiDirectEnabled ?? true;
    isBluetoothEnabled = isBluetoothEnabled ?? false;
    criticalPowerThreshold = criticalPowerThreshold ?? 10;
  }

  String? userId;
  String? emergencyContact;
  bool? isWifiDirectEnabled;
  bool? isBluetoothEnabled;
  int? criticalPowerThreshold;

  ConfigurationSettingsModel copyWith({
    String? userId,
    String? emergencyContact,
    bool? isWifiDirectEnabled,
    bool? isBluetoothEnabled,
    int? criticalPowerThreshold,
  }) {
    return ConfigurationSettingsModel(
      userId: userId ?? this.userId,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      isWifiDirectEnabled: isWifiDirectEnabled ?? this.isWifiDirectEnabled,
      isBluetoothEnabled: isBluetoothEnabled ?? this.isBluetoothEnabled,
      criticalPowerThreshold:
          criticalPowerThreshold ?? this.criticalPowerThreshold,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    emergencyContact,
    isWifiDirectEnabled,
    isBluetoothEnabled,
    criticalPowerThreshold,
  ];
}
