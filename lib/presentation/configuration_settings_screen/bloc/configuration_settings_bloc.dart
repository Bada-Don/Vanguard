import 'package:flutter/material.dart';
import '../models/configuration_settings_model.dart';
import '../../../core/app_export.dart';

part 'configuration_settings_event.dart';
part 'configuration_settings_state.dart';

class ConfigurationSettingsBloc
    extends Bloc<ConfigurationSettingsEvent, ConfigurationSettingsState> {
  ConfigurationSettingsBloc(ConfigurationSettingsState initialState)
    : super(initialState) {
    on<ConfigurationSettingsInitialEvent>(_onInitialize);
    on<ToggleWifiDirectEvent>(_onToggleWifiDirect);
    on<ToggleBluetoothEvent>(
      _onToggleBluetooth,
    ); // Modified: Added missing parenthesis
    on<UpdatePowerThresholdEvent>(_onUpdatePowerThreshold);
    on<UpdateUserIdEvent>(_onUpdateUserId);
    on<UpdateEmergencyContactEvent>(_onUpdateEmergencyContact);
  }

  _onInitialize(
    ConfigurationSettingsInitialEvent event,
    Emitter<ConfigurationSettingsState> emit,
  ) async {
    emit(
      state.copyWith(
        userIdController: TextEditingController(
          text: state.configurationSettingsModel?.userId ?? 'NX-7742-BRAVO',
        ),
        emergencyContactController: TextEditingController(
          text:
              state.configurationSettingsModel?.emergencyContact ??
              '+1 (555) 000-0000',
        ),
      ),
    );
  }

  _onToggleWifiDirect(
    ToggleWifiDirectEvent event,
    Emitter<ConfigurationSettingsState> emit,
  ) async {
    emit(
      state.copyWith(
        configurationSettingsModel: state.configurationSettingsModel?.copyWith(
          isWifiDirectEnabled: event.isEnabled,
        ),
      ),
    );
  }

  _onToggleBluetooth(
    ToggleBluetoothEvent event,
    Emitter<ConfigurationSettingsState> emit,
  ) async {
    emit(
      state.copyWith(
        configurationSettingsModel: state.configurationSettingsModel?.copyWith(
          isBluetoothEnabled: event.isEnabled,
        ),
      ),
    );
  }

  _onUpdatePowerThreshold(
    UpdatePowerThresholdEvent event,
    Emitter<ConfigurationSettingsState> emit,
  ) async {
    emit(
      state.copyWith(
        configurationSettingsModel: state.configurationSettingsModel?.copyWith(
          criticalPowerThreshold: event.threshold,
        ),
      ),
    );
  }

  _onUpdateUserId(
    UpdateUserIdEvent event,
    Emitter<ConfigurationSettingsState> emit,
  ) async {
    emit(
      state.copyWith(
        configurationSettingsModel: state.configurationSettingsModel?.copyWith(
          userId: event.userId,
        ),
      ),
    );
  }

  _onUpdateEmergencyContact(
    UpdateEmergencyContactEvent event,
    Emitter<ConfigurationSettingsState> emit,
  ) async {
    emit(
      state.copyWith(
        configurationSettingsModel: state.configurationSettingsModel?.copyWith(
          emergencyContact: event.emergencyContact,
        ),
      ),
    );
  }
}
