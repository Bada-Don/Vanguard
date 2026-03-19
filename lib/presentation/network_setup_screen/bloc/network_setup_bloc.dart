import '../models/network_setup_model.dart';
import '../../../core/app_export.dart';

part 'network_setup_event.dart';
part 'network_setup_state.dart';

class NetworkSetupBloc extends Bloc<NetworkSetupEvent, NetworkSetupState> {
  NetworkSetupBloc(NetworkSetupState initialState) : super(initialState) {
    on<NetworkSetupInitialEvent>(_onInitialize);
    on<ToggleBluetoothEvent>(_onToggleBluetooth);
    on<ToggleLocationEvent>(_onToggleLocation);
    on<ToggleBackgroundRelayEvent>(_onToggleBackgroundRelay);
    on<ToggleWifiDirectEvent>(_onToggleWifiDirect);
    on<ActivateNodeEvent>(_onActivateNode);
  }

  _onInitialize(
    NetworkSetupInitialEvent event,
    Emitter<NetworkSetupState> emit,
  ) async {
    emit(
      state.copyWith(networkSetupModel: NetworkSetupModel(), isLoading: false),
    );
  }

  _onToggleBluetooth(
    ToggleBluetoothEvent event,
    Emitter<NetworkSetupState> emit,
  ) async {
    emit(
      state.copyWith(
        networkSetupModel: state.networkSetupModel?.copyWith(
          isBluetoothEnabled: event.isEnabled,
        ),
      ),
    );
  }

  _onToggleLocation(
    ToggleLocationEvent event,
    Emitter<NetworkSetupState> emit,
  ) async {
    emit(
      state.copyWith(
        networkSetupModel: state.networkSetupModel?.copyWith(
          isLocationEnabled: event.isEnabled,
        ),
      ),
    );
  }

  _onToggleBackgroundRelay(
    ToggleBackgroundRelayEvent event,
    Emitter<NetworkSetupState> emit,
  ) async {
    emit(
      state.copyWith(
        networkSetupModel: state.networkSetupModel?.copyWith(
          isBackgroundRelayEnabled: event.isEnabled,
        ),
      ),
    );
  }

  _onToggleWifiDirect(
    ToggleWifiDirectEvent event,
    Emitter<NetworkSetupState> emit,
  ) async {
    emit(
      state.copyWith(
        networkSetupModel: state.networkSetupModel?.copyWith(
          isWifiDirectEnabled: event.isEnabled,
        ),
      ),
    );
  }

  _onActivateNode(
    ActivateNodeEvent event,
    Emitter<NetworkSetupState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    // Simulate activation process
    await Future.delayed(Duration(seconds: 2));

    emit(state.copyWith(isLoading: false, isActivationSuccessful: true));

    // Reset success flag after showing message
    await Future.delayed(Duration(milliseconds: 500));
    emit(state.copyWith(isActivationSuccessful: false));
  }
}
