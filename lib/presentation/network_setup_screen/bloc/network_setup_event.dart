part of 'network_setup_bloc.dart';

abstract class NetworkSetupEvent extends Equatable {
  NetworkSetupEvent();

  @override
  List<Object?> get props => [];
}

class NetworkSetupInitialEvent extends NetworkSetupEvent {}

class ToggleBluetoothEvent extends NetworkSetupEvent {
  final bool isEnabled;

  ToggleBluetoothEvent({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class ToggleLocationEvent extends NetworkSetupEvent {
  final bool isEnabled;

  ToggleLocationEvent({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class ToggleBackgroundRelayEvent extends NetworkSetupEvent {
  final bool isEnabled;

  ToggleBackgroundRelayEvent({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class ToggleWifiDirectEvent extends NetworkSetupEvent {
  final bool isEnabled;

  ToggleWifiDirectEvent({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class ActivateNodeEvent extends NetworkSetupEvent {}
