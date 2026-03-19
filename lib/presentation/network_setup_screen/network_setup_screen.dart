import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/connectivity_status_bar.dart';
import '../../widgets/connectivity_status_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_switch.dart';
import './bloc/network_setup_bloc.dart';
import './models/network_setup_model.dart';

class NetworkSetupScreen extends StatelessWidget {
  NetworkSetupScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return BlocProvider<NetworkSetupBloc>(
      create: (context) => NetworkSetupBloc(
        NetworkSetupState(networkSetupModel: NetworkSetupModel()),
      )..add(NetworkSetupInitialEvent()),
      child: NetworkSetupScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = ConnectivityStatusService();
    return Scaffold(
      backgroundColor: appTheme.gray_900,
      body: BlocConsumer<NetworkSetupBloc, NetworkSetupState>(
        listener: (context, state) {
          if (state.isActivationSuccessful ?? false) {
            NavigatorService.pushNamedAndRemoveUntil(
              AppRoutes.emergencySOSDashboardScreen,
            );
          }
        },
        builder: (context, state) {
          return ListenableBuilder(
            listenable: service,
            builder: (context, _) {
              return ConnectivitySpinnerOverlay(
                visible: service.isLoading,
                message: 'Scanning for mesh nodes...',
                child: Column(
                  children: [
                    CustomAppBar(
                      title: 'Network Setup',
                      leadingIcon: ImageConstant.imgArrowLeftGray100,
                      backgroundColor: appTheme.gray_900,
                      onLeadingPressed: () => NavigatorService.goBack(),
                    ),
                    ConnectivityStatusBar(
                      meshStatus: service.meshStatus,
                      gpsStatus: service.gpsStatus,
                      transmissionStatus: service.transmissionStatus,
                      errorMessage: service.errorMessage,
                      onDismissError: () => service.clearError(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: 24.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Permission status header
                            Padding(
                              padding: EdgeInsets.only(
                                top: 20.h,
                                left: 16.h,
                                right: 16.h,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'PERMISSION STATUS',
                                        style: TextStyleHelper
                                            .instance
                                            .body14MediumPublicSans
                                            .copyWith(color: appTheme.gray_100),
                                      ),
                                      Text(
                                        'Step 1 of 3',
                                        style: TextStyleHelper
                                            .instance
                                            .body14BoldPublicSans,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                  Container(
                                    height: 4.h,
                                    decoration: BoxDecoration(
                                      color: appTheme.color33EC5B,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Icon
                            Container(
                              margin: EdgeInsets.only(top: 36.h),
                              width: 80.h,
                              height: 80.h,
                              child: CustomImageView(
                                imagePath: ImageConstant.imgContainer,
                                height: 80.h,
                                width: 80.h,
                              ),
                            ),
                            // Title
                            Padding(
                              padding: EdgeInsets.only(
                                top: 20.h,
                                left: 16.h,
                                right: 16.h,
                              ),
                              child: Text(
                                'Initialize Mesh Node',
                                style: TextStyleHelper
                                    .instance
                                    .headline24BoldPublicSans,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // Description
                            Padding(
                              padding: EdgeInsets.only(
                                top: 12.h,
                                left: 24.h,
                                right: 24.h,
                              ),
                              child: Text(
                                'Enable critical hardware to join the local crisis network. This ensures you stay connected even when the internet is down.',
                                textAlign: TextAlign.center,
                                style: TextStyleHelper
                                    .instance
                                    .title16RegularPublicSans
                                    .copyWith(height: 1.6),
                              ),
                            ),
                            // Permission items
                            Padding(
                              padding: EdgeInsets.only(
                                top: 28.h,
                                left: 16.h,
                                right: 16.h,
                              ),
                              child: Column(
                                children: [
                                  _buildPermissionItem(
                                    context,
                                    state,
                                    iconPath:
                                        ImageConstant.imgIconDeepOrange60048x48,
                                    title: 'Bluetooth Connectivity',
                                    description:
                                        'Used for device discovery and peer-to-peer relaying.',
                                    value:
                                        state
                                            .networkSetupModel
                                            ?.isBluetoothEnabled ??
                                        false,
                                    onChanged: (value) {
                                      context.read<NetworkSetupBloc>().add(
                                        ToggleBluetoothEvent(isEnabled: value),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 10.h),
                                  _buildPermissionItem(
                                    context,
                                    state,
                                    iconPath: ImageConstant.imgOverlayBorder,
                                    title: 'Precision Location',
                                    description:
                                        'Required for network topology and spatial emergency alerts.',
                                    value:
                                        state
                                            .networkSetupModel
                                            ?.isLocationEnabled ??
                                        false,
                                    onChanged: (value) {
                                      context.read<NetworkSetupBloc>().add(
                                        ToggleLocationEvent(isEnabled: value),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 10.h),
                                  _buildPermissionItem(
                                    context,
                                    state,
                                    iconPath: ImageConstant
                                        .imgOverlayBorderDeepOrange600,
                                    title: 'Background Relay',
                                    description:
                                        'Maintain mesh integrity while the app is closed.',
                                    value:
                                        state
                                            .networkSetupModel
                                            ?.isBackgroundRelayEnabled ??
                                        false,
                                    onChanged: (value) {
                                      context.read<NetworkSetupBloc>().add(
                                        ToggleBackgroundRelayEvent(
                                          isEnabled: value,
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 10.h),
                                  _buildPermissionItem(
                                    context,
                                    state,
                                    iconPath: ImageConstant
                                        .imgOverlayBorderDeepOrange60048x48,
                                    title: 'Local Network / Wi-Fi Direct',
                                    description:
                                        'Required for high-bandwidth mesh relaying and stable peer-to-peer connections.',
                                    value:
                                        state
                                            .networkSetupModel
                                            ?.isWifiDirectEnabled ??
                                        false,
                                    onChanged: (value) {
                                      context.read<NetworkSetupBloc>().add(
                                        ToggleWifiDirectEvent(isEnabled: value),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            // Status indicator
                            Padding(
                              padding: EdgeInsets.only(
                                top: 24.h,
                                left: 16.h,
                                right: 16.h,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.h,
                                  vertical: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  color: appTheme.color0CEC5B,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: appTheme.color19EC5B,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CustomImageView(
                                      imagePath: ImageConstant
                                          .imgIconDeepOrange60010x10,
                                      height: 10.h,
                                      width: 10.h,
                                    ),
                                    SizedBox(width: 10.h),
                                    Text(
                                      'AWAITING CRITICAL PERMISSIONS',
                                      style: TextStyleHelper
                                          .instance
                                          .body12RegularPublicSans
                                          .copyWith(
                                            color: appTheme.deep_orange_600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Activate button
                            Padding(
                              padding: EdgeInsets.only(
                                top: 24.h,
                                left: 16.h,
                                right: 16.h,
                              ),
                              child: _buildActivateButton(context, state),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPermissionItem(
    BuildContext context,
    NetworkSetupState state, {
    required String iconPath,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: EdgeInsets.all(14.h),
      decoration: BoxDecoration(
        color: isHighlighted ? Color(0x4CFFFFFF) : appTheme.color0CFFFF,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          CustomIconButton(
            iconPath: iconPath,
            height: 48.h,
            width: 48.h,
            padding: EdgeInsets.all(12.h),
            backgroundColor: appTheme.color19EC5B,
            borderColor: appTheme.color33EC5B,
            borderWidth: 1,
            borderRadius: 8,
            onPressed: null,
          ),
          SizedBox(width: 14.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyleHelper.instance.title16BoldPublicSans
                      .copyWith(color: appTheme.gray_100),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyleHelper.instance.body12RegularPublicSans
                      .copyWith(height: 1.5),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          SizedBox(width: 10.h),
          CustomSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: appTheme.colorFF52D1,
          ),
        ],
      ),
    );
  }

  Widget _buildActivateButton(BuildContext context, NetworkSetupState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.read<NetworkSetupBloc>().add(ActivateNodeEvent());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: appTheme.color33EC5B,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          'Activate Mesh Node',
          style: TextStyleHelper.instance.title16BoldPublicSans.copyWith(
            color: appTheme.gray_900,
          ),
        ),
      ),
    );
  }
}
