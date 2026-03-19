part of 'configuration_settings_bloc.dart';

class ConfigurationSettingsState extends Equatable {
  final TextEditingController? userIdController;
  final TextEditingController? emergencyContactController;
  final ConfigurationSettingsModel? configurationSettingsModel;
  final bool isLoading;

  ConfigurationSettingsState({
    this.userIdController,
    this.emergencyContactController,
    this.configurationSettingsModel,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [
    userIdController,
    emergencyContactController,
    configurationSettingsModel,
    isLoading,
  ];

  ConfigurationSettingsState copyWith({
    TextEditingController? userIdController,
    TextEditingController? emergencyContactController,
    ConfigurationSettingsModel? configurationSettingsModel,
    bool? isLoading,
  }) {
    return ConfigurationSettingsState(
      userIdController: userIdController ?? this.userIdController,
      emergencyContactController:
          emergencyContactController ?? this.emergencyContactController,
      configurationSettingsModel:
          configurationSettingsModel ?? this.configurationSettingsModel,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
