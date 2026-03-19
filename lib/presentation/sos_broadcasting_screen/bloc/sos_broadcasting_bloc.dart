import '../../../core/app_export.dart';
import '../models/sos_broadcasting_model.dart';

part 'sos_broadcasting_event.dart';
part 'sos_broadcasting_state.dart';

class SOSBroadcastingBloc
    extends Bloc<SOSBroadcastingEvent, SOSBroadcastingState> {
  SOSBroadcastingBloc(SOSBroadcastingState initialState) : super(initialState) {
    on<SOSBroadcastingInitialEvent>(_onInitialize);
    on<CloseButtonPressedEvent>(_onCloseButtonPressed);
    on<RefreshButtonPressedEvent>(_onRefreshButtonPressed);
    on<LiveUpdatesButtonPressedEvent>(_onLiveUpdatesButtonPressed);
    on<TransmissionLogItemTappedEvent>(_onTransmissionLogItemTapped);
    on<TerminateBroadcastButtonPressedEvent>(
      _onTerminateBroadcastButtonPressed,
    );
  }

  _onInitialize(
    SOSBroadcastingInitialEvent event,
    Emitter<SOSBroadcastingState> emit,
  ) async {
    emit(
      state.copyWith(
        sosBroadcastingModel: SOSBroadcastingModel(
          nearbyDevicesCount: 14,
          additionalDevices: 1,
          currentLocation: "37.7749° N, 122.4194° W",
          transmissionLogs: [
            TransmissionLogModel(
              id: '1',
              sourceNode: 'Node A82',
              destinationNode: 'Node B12',
              details: 'Signal strength: High (-64 dBm)',
              timestamp: 'Just now',
              icon: ImageConstant.imgIconDeepOrange60010x10,
            ),
            TransmissionLogModel(
              id: '2',
              sourceNode: 'Node B12',
              destinationNode: 'Node C04',
              details: 'Hops: 2 | Relay confirmed',
              timestamp: '12s ago',
              icon: ImageConstant.imgIconDeepOrange60010x10,
            ),
            TransmissionLogModel(
              id: '3',
              sourceNode: 'Gateway Entry',
              destinationNode: '',
              details: 'Signal successfully reached mesh entry',
              timestamp: '45s ago',
              icon: ImageConstant.imgIconDeepOrange60010x10,
            ),
          ],
        ),
      ),
    );
  }

  _onCloseButtonPressed(
    CloseButtonPressedEvent event,
    Emitter<SOSBroadcastingState> emit,
  ) async {
    emit(state.copyWith(shouldNavigateBack: true));
  }

  _onRefreshButtonPressed(
    RefreshButtonPressedEvent event,
    Emitter<SOSBroadcastingState> emit,
  ) async {
    int newDeviceCount =
        (state.sosBroadcastingModel?.nearbyDevicesCount ?? 14) + 1;
    int newAdditionalDevices =
        (state.sosBroadcastingModel?.additionalDevices ?? 1) + 1;

    emit(
      state.copyWith(
        sosBroadcastingModel: state.sosBroadcastingModel?.copyWith(
          nearbyDevicesCount: newDeviceCount,
          additionalDevices: newAdditionalDevices,
        ),
      ),
    );
  }

  _onLiveUpdatesButtonPressed(
    LiveUpdatesButtonPressedEvent event,
    Emitter<SOSBroadcastingState> emit,
  ) async {
    List<TransmissionLogModel> currentLogs =
        state.sosBroadcastingModel?.transmissionLogs ?? [];
    List<TransmissionLogModel> updatedLogs = [
      TransmissionLogModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sourceNode: 'Node X${DateTime.now().second}',
        destinationNode: 'Node Y${DateTime.now().minute}',
        details: 'New relay established',
        timestamp: 'Just now',
        icon: ImageConstant.imgIconDeepOrange60010x10,
      ),
      ...currentLogs,
    ];

    emit(
      state.copyWith(
        sosBroadcastingModel: state.sosBroadcastingModel?.copyWith(
          transmissionLogs: updatedLogs,
        ),
      ),
    );
  }

  _onTransmissionLogItemTapped(
    TransmissionLogItemTappedEvent event,
    Emitter<SOSBroadcastingState> emit,
  ) async {
    // Handle transmission log item tap for detailed view
  }

  _onTerminateBroadcastButtonPressed(
    TerminateBroadcastButtonPressedEvent event,
    Emitter<SOSBroadcastingState> emit,
  ) async {
    emit(state.copyWith(broadcastTerminated: true, shouldNavigateBack: true));
  }
}
