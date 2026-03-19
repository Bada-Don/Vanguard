import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/connectivity_status_bar.dart';
import '../../widgets/connectivity_status_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_edit_text.dart';
import '../../widgets/custom_switch.dart';
import './bloc/configuration_settings_bloc.dart';
import './models/configuration_settings_model.dart';

class ConfigurationSettingsScreen extends StatelessWidget {
  ConfigurationSettingsScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return BlocProvider<ConfigurationSettingsBloc>(
      create: (context) => ConfigurationSettingsBloc(
        ConfigurationSettingsState(
          configurationSettingsModel: ConfigurationSettingsModel(),
        ),
      )..add(ConfigurationSettingsInitialEvent()),
      child: ConfigurationSettingsScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = ConnectivityStatusService();
    return Scaffold(
      backgroundColor: appTheme.gray_900_04,
      appBar: _buildAppBar(context),
      body: BlocBuilder<ConfigurationSettingsBloc, ConfigurationSettingsState>(
        builder: (context, state) {
          return ListenableBuilder(
            listenable: service,
            builder: (context, _) {
              return ConnectivitySpinnerOverlay(
                visible: service.isLoading,
                message: 'Loading configuration...',
                child: Column(
                  children: [
                    ConnectivityStatusBar(
                      meshStatus: service.meshStatus,
                      gpsStatus: service.gpsStatus,
                      transmissionStatus: service.transmissionStatus,
                      errorMessage: service.errorMessage,
                      onDismissError: () => service.clearError(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildUserInformationSection(context, state),
                            _buildHardwareConfigSection(context, state),
                            _buildPowerManagementSection(context, state),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
      title: 'Configuration',
      leadingIcon: ImageConstant.imgArrowLeftDeepOrange600,
      backgroundColor: appTheme.gray_900_04,
      titleColor: appTheme.gray_100,
      onLeadingPressed: () => Navigator.pop(context),
      height: 80.h,
    );
  }

  Widget _buildUserInformationSection(
    BuildContext context,
    ConfigurationSettingsState state,
  ) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.h, 32.h, 22.h, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'USER INFORMATION',
            style: TextStyleHelper.instance.body14BoldPublicSans.copyWith(
              letterSpacing: 1.0,
              height: 1.21,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'User ID',
            style: TextStyleHelper.instance.body14MediumPublicSans.copyWith(
              height: 1.21,
            ),
          ),
          SizedBox(height: 8.h),
          CustomEditText(
            controller: state.userIdController,
            placeholder: 'NX-7742-BRAVO',
            borderRadius: 12,
            backgroundColor: appTheme.color19EC5B,
            borderColor: appTheme.color4CEC5B,
            textColor: appTheme.gray_100,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.h,
              vertical: 14.h,
            ),
            margin: EdgeInsets.only(right: 8.h),
          ),
          SizedBox(height: 16.h),
          Text(
            'Emergency Contact',
            style: TextStyleHelper.instance.body14MediumPublicSans.copyWith(
              height: 1.21,
            ),
          ),
          SizedBox(height: 6.h),
          CustomEditText(
            controller: state.emergencyContactController,
            placeholder: '+1 (555) 000-0000',
            borderRadius: 12,
            backgroundColor: appTheme.color19EC5B,
            borderColor: appTheme.color4CEC5B,
            textColor: appTheme.gray_600,
            keyboardType: TextInputType.phone,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.h,
              vertical: 14.h,
            ),
            margin: EdgeInsets.only(right: 8.h),
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareConfigSection(
    BuildContext context,
    ConfigurationSettingsState state,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: appTheme.color19EC5B, width: 1.h),
        ),
      ),
      padding: EdgeInsets.fromLTRB(22.h, 22.h, 6.h, 24.h),
      margin: EdgeInsets.only(top: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HARDWARE CONFIG',
            style: TextStyleHelper.instance.body14BoldPublicSans.copyWith(
              letterSpacing: 1.0,
              height: 1.21,
            ),
          ),
          SizedBox(height: 16.h),
          Column(
            children: [
              _buildHardwareConfigItem(
                context,
                'Wi-Fi Direct Mesh',
                'Standard 802.11s peer-to-peer networking',
                state.configurationSettingsModel?.isWifiDirectEnabled ?? true,
                (value) {
                  context.read<ConfigurationSettingsBloc>().add(
                    ToggleWifiDirectEvent(isEnabled: value),
                  );
                },
              ),
              SizedBox(height: 16.h),
              _buildHardwareConfigItem(
                context,
                'Bluetooth LE',
                'Peripheral sync and discovery',
                state.configurationSettingsModel?.isBluetoothEnabled ?? false,
                (value) {
                  context.read<ConfigurationSettingsBloc>().add(
                    ToggleBluetoothEvent(isEnabled: value),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareConfigItem(
    BuildContext context,
    String title,
    String subtitle,
    bool isEnabled,
    Function(bool) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.color33EC5B, width: 1.h),
        boxShadow: [
          BoxShadow(
            color: appTheme.color33EC5B,
            blurRadius: 2.h,
            offset: Offset(0, 0),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.h),
      margin: EdgeInsets.only(right: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyleHelper.instance.title16SemiBoldPublicSans
                      .copyWith(height: 1.19),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyleHelper.instance.body12RegularPublicSans
                      .copyWith(height: 1.25),
                ),
              ],
            ),
          ),
          CustomSwitch(
            value: isEnabled,
            onChanged: onChanged,
            activeColor: appTheme.deep_orange_600,
            inactiveThumbColor: appTheme.white_A700,
            inactiveTrackColor: appTheme.blue_gray_500,
          ),
        ],
      ),
    );
  }

  Widget _buildPowerManagementSection(
    BuildContext context,
    ConfigurationSettingsState state,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: appTheme.color19EC5B, width: 1.h),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.h, 22.h, 16.h, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'POWER MANAGEMENT',
            style: TextStyleHelper.instance.body14BoldPublicSans.copyWith(
              letterSpacing: 1.0,
              height: 1.21,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.h),
              border: Border.all(color: appTheme.color33EC5B, width: 1.h),
              boxShadow: [
                BoxShadow(
                  color: appTheme.color33EC5B,
                  blurRadius: 2.h,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            padding: EdgeInsets.all(16.h),
            child: Column(
              children: [
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Critical Power Limiter',
                      style: TextStyleHelper.instance.title16SemiBoldPublicSans
                          .copyWith(height: 1.19),
                    ),
                    Text(
                      '${state.configurationSettingsModel?.criticalPowerThreshold ?? 10}%',
                      style: TextStyleHelper.instance.title16BoldPublicSans
                          .copyWith(
                            color: appTheme.deep_orange_600,
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Container(
                  width: double.infinity,
                  height: 8.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.h),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor:
                        (state
                                .configurationSettingsModel
                                ?.criticalPowerThreshold ??
                            10) /
                        100,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.h),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 13.h),
                Text(
                  'Automatically disable mesh networking and high-\nprecision GPS when battery reaches this threshold to\npreserve core device functions.',
                  style: TextStyleHelper.instance.body12RegularPublicSans
                      .copyWith(height: 1.58),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
