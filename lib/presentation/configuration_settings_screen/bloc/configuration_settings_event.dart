part of 'configuration_settings_bloc.dart';

abstract class ConfigurationSettingsEvent extends Equatable {
  ConfigurationSettingsEvent();

  @override
  List<Object?> get props => [];
}

class ConfigurationSettingsInitialEvent extends ConfigurationSettingsEvent {}

class ToggleWifiDirectEvent extends ConfigurationSettingsEvent {
  final bool isEnabled;

  ToggleWifiDirectEvent({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class ToggleBluetoothEvent extends ConfigurationSettingsEvent {
  final bool isEnabled;

  ToggleBluetoothEvent({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class UpdatePowerThresholdEvent extends ConfigurationSettingsEvent {
  final int threshold;

  UpdatePowerThresholdEvent({required this.threshold});

  @override
  List<Object?> get props => [threshold];
}

class UpdateUserIdEvent extends ConfigurationSettingsEvent {
  final String userId;

  UpdateUserIdEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateEmergencyContactEvent extends ConfigurationSettingsEvent {
  final String emergencyContact;

  UpdateEmergencyContactEvent({required this.emergencyContact});

  @override
  List<Object?> get props => [emergencyContact];
}

class UpdateMaxHopsEvent extends ConfigurationSettingsEvent {
  final int maxHops;
  UpdateMaxHopsEvent({required this.maxHops});
  @override
  List<Object?> get props => [maxHops];
}

class UpdateMessageQueueSizeEvent extends ConfigurationSettingsEvent {
  final int size;
  UpdateMessageQueueSizeEvent({required this.size});
  @override
  List<Object?> get props => [size];
}

class UpdateUplinkRetriesEvent extends ConfigurationSettingsEvent {
  final int retries;
  UpdateUplinkRetriesEvent({required this.retries});
  @override
  List<Object?> get props => [retries];
}

class UpdateConnectionTimeoutEvent extends ConfigurationSettingsEvent {
  final int timeout;
  UpdateConnectionTimeoutEvent({required this.timeout});
  @override
  List<Object?> get props => [timeout];
}

class ResetConfigurationEvent extends ConfigurationSettingsEvent {}
