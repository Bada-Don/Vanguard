part of 'sos_broadcasting_bloc.dart';

class SOSBroadcastingState extends Equatable {
  final SOSBroadcastingModel? sosBroadcastingModel;
  final bool? shouldNavigateBack;
  final bool? broadcastTerminated;

  SOSBroadcastingState({
    this.sosBroadcastingModel,
    this.shouldNavigateBack,
    this.broadcastTerminated,
  });

  @override
  List<Object?> get props => [
    sosBroadcastingModel,
    shouldNavigateBack,
    broadcastTerminated,
  ];

  SOSBroadcastingState copyWith({
    SOSBroadcastingModel? sosBroadcastingModel,
    bool? shouldNavigateBack,
    bool? broadcastTerminated,
  }) {
    return SOSBroadcastingState(
      sosBroadcastingModel: sosBroadcastingModel ?? this.sosBroadcastingModel,
      shouldNavigateBack: shouldNavigateBack ?? this.shouldNavigateBack,
      broadcastTerminated: broadcastTerminated ?? this.broadcastTerminated,
    );
  }
}
