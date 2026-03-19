part of 'network_setup_bloc.dart';

class NetworkSetupState extends Equatable {
  final NetworkSetupModel? networkSetupModel;
  final bool? isLoading;
  final bool? isActivationSuccessful;

  NetworkSetupState({
    this.networkSetupModel,
    this.isLoading = false,
    this.isActivationSuccessful = false,
  });

  @override
  List<Object?> get props => [
    networkSetupModel,
    isLoading,
    isActivationSuccessful,
  ];

  NetworkSetupState copyWith({
    NetworkSetupModel? networkSetupModel,
    bool? isLoading,
    bool? isActivationSuccessful,
  }) {
    return NetworkSetupState(
      networkSetupModel: networkSetupModel ?? this.networkSetupModel,
      isLoading: isLoading ?? this.isLoading,
      isActivationSuccessful:
          isActivationSuccessful ?? this.isActivationSuccessful,
    );
  }
}
