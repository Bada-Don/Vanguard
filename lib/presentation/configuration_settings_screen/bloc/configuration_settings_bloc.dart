import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/configuration_settings_model.dart';
import '../../../core/app_export.dart';
import 'package:vanguard_crisis_response/core/models/mesh_network_config.dart';

part 'configuration_settings_event.dart';
part 'configuration_settings_state.dart';

class ConfigurationSettingsBloc
    extends Bloc<ConfigurationSettingsEvent, ConfigurationSettingsState> {
    
  static const String _meshConfigPrefsKey = 'mesh_network_config';

  ConfigurationSettingsBloc(ConfigurationSettingsState initialState)
    : super(initialState) {
    on<ConfigurationSettingsInitialEvent>(_onInitialize);
    on<ToggleWifiDirectEvent>(_onToggleWifiDirect);
    on<ToggleBluetoothEvent>(_onToggleBluetooth);
    on<UpdatePowerThresholdEvent>(_onUpdatePowerThreshold);
    on<UpdateUserIdEvent>(_onUpdateUserId);
    on<UpdateEmergencyContactEvent>(_onUpdateEmergencyContact);
    
    // Mesh config events
    on<UpdateMaxHopsEvent>(_onUpdateMaxHops);
    on<UpdateMessageQueueSizeEvent>(_onUpdateMessageQueueSize);
    on<UpdateUplinkRetriesEvent>(_onUpdateUplinkRetries);
    on<UpdateConnectionTimeoutEvent>(_onUpdateConnectionTimeout);
    on<ResetConfigurationEvent>(_onResetConfiguration);
  }

  _onInitialize(
    ConfigurationSettingsInitialEvent event,
    Emitter<ConfigurationSettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final String? configJson = prefs.getString(_meshConfigPrefsKey);
    
    MeshNetworkConfig loadedConfig = MeshNetworkConfig.defaultConfig;
    if (configJson != null) {
      try {
        loadedConfig = MeshNetworkConfig.fromJsonString(configJson);
      } catch (e) {
        // Fallback to default
      }
    }

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
        meshNetworkConfig: loadedConfig,
      ),
    );
  }

  Future<void> _updateAndPersistConfig(MeshNetworkConfig newConfig, Emitter<ConfigurationSettingsState> emit) async {
    if (newConfig.isValid) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_meshConfigPrefsKey, newConfig.toJsonString());
      emit(state.copyWith(meshNetworkConfig: newConfig, clearValidationError: true));
    } else {
      emit(state.copyWith(validationError: newConfig.validationErrors.first));
    }
  }

  _onUpdateMaxHops(UpdateMaxHopsEvent event, Emitter<ConfigurationSettingsState> emit) async {
    final newConfig = state.meshNetworkConfig.copyWith(maxHops: event.maxHops);
    await _updateAndPersistConfig(newConfig, emit);
  }

  _onUpdateMessageQueueSize(UpdateMessageQueueSizeEvent event, Emitter<ConfigurationSettingsState> emit) async {
    final newConfig = state.meshNetworkConfig.copyWith(messageQueueSize: event.size);
    await _updateAndPersistConfig(newConfig, emit);
  }

  _onUpdateUplinkRetries(UpdateUplinkRetriesEvent event, Emitter<ConfigurationSettingsState> emit) async {
    final newConfig = state.meshNetworkConfig.copyWith(uplinkRetryAttempts: event.retries);
    await _updateAndPersistConfig(newConfig, emit);
  }

  _onUpdateConnectionTimeout(UpdateConnectionTimeoutEvent event, Emitter<ConfigurationSettingsState> emit) async {
    final newConfig = state.meshNetworkConfig.copyWith(connectionTimeout: event.timeout);
    await _updateAndPersistConfig(newConfig, emit);
  }

  _onResetConfiguration(ResetConfigurationEvent event, Emitter<ConfigurationSettingsState> emit) async {
    await _updateAndPersistConfig(MeshNetworkConfig.defaultConfig, emit);
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
