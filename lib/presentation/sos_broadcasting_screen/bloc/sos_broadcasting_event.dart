part of 'sos_broadcasting_bloc.dart';

abstract class SOSBroadcastingEvent extends Equatable {
  SOSBroadcastingEvent();

  @override
  List<Object?> get props => [];
}

class SOSBroadcastingInitialEvent extends SOSBroadcastingEvent {}

class CloseButtonPressedEvent extends SOSBroadcastingEvent {}

class RefreshButtonPressedEvent extends SOSBroadcastingEvent {}

class LiveUpdatesButtonPressedEvent extends SOSBroadcastingEvent {}

class TransmissionLogItemTappedEvent extends SOSBroadcastingEvent {
  final String logId;

  TransmissionLogItemTappedEvent({required this.logId});

  @override
  List<Object?> get props => [logId];
}

class TerminateBroadcastButtonPressedEvent extends SOSBroadcastingEvent {}
