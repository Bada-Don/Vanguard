part of 'configuration_settings_bloc.dart';

class ConfigurationSettingsState extends Equatable {
  final TextEditingController? userIdController;
  final TextEditingController? emergencyContactController;
  final ConfigurationSettingsModel? configurationSettingsModel;
  final MeshNetworkConfig meshNetworkConfig;
  final bool isLoading;
  final String? validationError;

  ConfigurationSettingsState({
    this.userIdController,
    this.emergencyContactController,
    this.configurationSettingsModel,
    this.meshNetworkConfig = MeshNetworkConfig.defaultConfig,
    this.isLoading = false,
    this.validationError,
  });

  @override
  List<Object?> get props => [
        userIdController,
        emergencyContactController,
        configurationSettingsModel,
        meshNetworkConfig,
        isLoading,
        validationError,
      ];

  ConfigurationSettingsState copyWith({
    TextEditingController? userIdController,
    TextEditingController? emergencyContactController,
    ConfigurationSettingsModel? configurationSettingsModel,
    MeshNetworkConfig? meshNetworkConfig,
    bool? isLoading,
    String? validationError,
    bool clearValidationError = false,
  }) {
    return ConfigurationSettingsState(
      userIdController: userIdController ?? this.userIdController,
      emergencyContactController:
          emergencyContactController ?? this.emergencyContactController,
      configurationSettingsModel:
          configurationSettingsModel ?? this.configurationSettingsModel,
      meshNetworkConfig: meshNetworkConfig ?? this.meshNetworkConfig,
      isLoading: isLoading ?? this.isLoading,
      validationError:
          clearValidationError ? null : (validationError ?? this.validationError),
    );
  }
}
