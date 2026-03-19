import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/connectivity_status_bar.dart';
import '../../widgets/connectivity_status_service.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_switch.dart';
import './bloc/passive_node_dashboard_bloc.dart';
import './models/passive_node_dashboard_model.dart';

class PassiveNodeDashboardScreen extends StatelessWidget {
  PassiveNodeDashboardScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return BlocProvider<PassiveNodeDashboardBloc>(
      create: (context) => PassiveNodeDashboardBloc(
        PassiveNodeDashboardState(
          passiveNodeDashboardModel: PassiveNodeDashboardModel(),
        ),
      )..add(PassiveNodeDashboardInitialEvent()),
      child: PassiveNodeDashboardScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = ConnectivityStatusService();
    return Scaffold(
      backgroundColor: appTheme.black_900,
      body: BlocConsumer<PassiveNodeDashboardBloc, PassiveNodeDashboardState>(
        listener: (context, state) {
          // Handle side effects if needed
        },
        builder: (context, state) {
          return ListenableBuilder(
            listenable: service,
            builder: (context, _) {
              return ConnectivitySpinnerOverlay(
                visible: service.isLoading,
                message: 'Syncing passive node data...',
                child: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: appTheme.black_900,
                                  border: Border(
                                    left: BorderSide(
                                      color: appTheme.color1919EC,
                                      width: 1.h,
                                    ),
                                    right: BorderSide(
                                      color: appTheme.color1919EC,
                                      width: 1.h,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    _buildHeaderSection(context, state),
                                    ConnectivityStatusBar(
                                      meshStatus: service.meshStatus,
                                      gpsStatus: service.gpsStatus,
                                      transmissionStatus:
                                          service.transmissionStatus,
                                      errorMessage: service.errorMessage,
                                      onDismissError: () =>
                                          service.clearError(),
                                    ),
                                    SizedBox(height: 16.h),
                                    _buildDashboardContent(context, state),
                                  ],
                                ),
                              ),
                              SizedBox(height: 77.h),
                              CustomImageView(
                                imagePath: ImageConstant.imgText,
                                width: 10.h,
                                height: 22.h,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    PassiveNodeDashboardState state,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
      decoration: BoxDecoration(
        color: appTheme.black_900,
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF8888).withAlpha(128),
            blurRadius: 12.h,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => NavigatorService.goBack(),
            child: Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: CustomImageView(
                imagePath: ImageConstant.imgArrowLeftGray100,
                width: 24.h,
                height: 24.h,
              ),
            ),
          ),
          SizedBox(width: 8.h),
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: CustomImageView(
              imagePath: ImageConstant.imgContainerDeepOrange600,
              width: 40.h,
              height: 40.h,
            ),
          ),
          SizedBox(width: 12.h),
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              'Passive Node',
              style: TextStyleHelper.instance.title18BoldPublicSans.copyWith(
                color: appTheme.gray_100,
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Container(
              width: 8.h,
              height: 8.h,
              decoration: BoxDecoration(
                color: appTheme.green_A700,
                borderRadius: BorderRadius.circular(4.h),
                boxShadow: [
                  BoxShadow(color: appTheme.color6622C5, blurRadius: 10.h),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.h),
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Text(
              'ACTIVE',
              style: TextStyleHelper.instance.label10BoldPublicSans.copyWith(
                color: appTheme.green_A700,
                letterSpacing: 1.h,
              ),
            ),
          ),
          CustomIconButton(
            iconPath: ImageConstant.imgMargin,
            height: 44.h,
            width: 44.h,
            onPressed: () => _onSettingsPressed(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    PassiveNodeDashboardState state,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.h, 0, 6.h, 148.h),
      child: Column(
        children: [
          _buildMetricsRow(context, state),
          SizedBox(height: 16.h),
          _buildLiveStatsSection(context, state),
          SizedBox(height: 16.h),
          _buildEnergyImpactCard(context, state),
          SizedBox(height: 16.h),
          _buildNetworkMapSection(context, state),
          SizedBox(height: 42.h),
          _buildNodeManagementSection(context, state),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(
    BuildContext context,
    PassiveNodeDashboardState state,
  ) {
    return Padding(
      padding: EdgeInsets.only(right: 8.h),
      child: Row(
        spacing: 16.h,
        children: [
          _buildRelayedPayloadsCard(context, state),
          _buildUptimeCard(context, state),
        ],
      ),
    );
  }

  Widget _buildRelayedPayloadsCard(
    BuildContext context,
    PassiveNodeDashboardState state,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20.h),
        decoration: BoxDecoration(
          color: appTheme.color1919EC,
          border: Border.all(color: appTheme.color3333EC, width: 1.h),
          borderRadius: BorderRadius.circular(12.h),
        ),
        child: Column(
          spacing: 6.h,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomImageView(
                  imagePath: ImageConstant.imgIconDeepOrange60018x18,
                  width: 18.h,
                  height: 18.h,
                ),
                SizedBox(width: 8.h),
                Expanded(
                  child: Text(
                    'RELAYED\nPAYLOADS',
                    style: TextStyleHelper.instance.body12SemiBoldPublicSans,
                  ),
                ),
              ],
            ),
            Text(
              '${state.processedMessagesCount}',
              style: TextStyleHelper.instance.headline30BoldPublicSans,
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.imgIconGreenA700,
                    width: 20.h,
                    height: 12.h,
                  ),
                  SizedBox(width: 4.h),
                  Text(
                    '+12.4%',
                    style: TextStyleHelper.instance.body12MediumPublicSans
                        .copyWith(color: appTheme.green_A700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUptimeCard(
    BuildContext context,
    PassiveNodeDashboardState state,
  ) {
    return Container(
      width: 170.h,
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: appTheme.color1919EC,
        border: Border.all(color: appTheme.color3333EC, width: 1.h),
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Column(
        spacing: 8.h,
        children: [
          Row(
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgIconDeepOrange60020x20,
                width: 20.h,
                height: 20.h,
              ),
              SizedBox(width: 8.h),
              Text(
                'UPTIME',
                style: TextStyleHelper.instance.body12SemiBoldPublicSans,
              ),
            ],
          ),
          Text(
            state.connectedEndpointsCount > 0 ? '18h 42m' : '0h 0m',
            style: TextStyleHelper.instance.headline30BoldPublicSans,
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                CustomImageView(
                  imagePath: ImageConstant.imgIconGreenA70020x20,
                  width: 20.h,
                  height: 20.h,
                ),
                SizedBox(width: 4.h),
                Text(
                  '99.9% stable',
                  style: TextStyleHelper.instance.body12MediumPublicSans
                      .copyWith(color: appTheme.green_A700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatsSection(
    BuildContext context,
    PassiveNodeDashboardState state,
  ) {
    return Padding(
      padding: EdgeInsets.only(right: 8.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          color: appTheme.color1919EC,
          border: Border.all(color: appTheme.color3333EC, width: 1.h),
          borderRadius: BorderRadius.circular(12.h),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LIVE RELAY STATUS',
              style: TextStyleHelper.instance.body12SemiBoldPublicSans.copyWith(letterSpacing: 1.0),
            ),
            SizedBox(height: 12.h),
            _buildStatRow('Queued Messages', '${state.queuedMessagesCount}'),
            SizedBox(height: 8.h),
            _buildStatRow('Last Relay', state.lastRelayTimestamp ?? '–'),
            SizedBox(height: 8.h),
            _buildStatRow('Last Uplink', state.lastUplinkTimestamp ?? '–'),
            SizedBox(height: 8.h),
            _buildStatRow('Relay Mode', state.isRelayModeEnabled ? 'Active' : 'Suspended'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyleHelper.instance.body12RegularPublicSans),
        Text(
          value,
          style: TextStyleHelper.instance.body12SemiBoldPublicSans.copyWith(color: appTheme.deep_orange_600),
        ),
      ],
    );
  }

  Widget _buildEnergyImpactCard(
    BuildContext context,
    PassiveNodeDashboardState state,
  ) {
    return Padding(
      padding: EdgeInsets.only(right: 8.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          color: appTheme.color4C1E29,
          border: Border.all(color: appTheme.color4CEC5B, width: 1.h),
          borderRadius: BorderRadius.circular(12.h),
          boxShadow: [BoxShadow(color: appTheme.color66EC5B, blurRadius: 15.h)],
        ),
        child: Column(
          spacing: 16.h,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  spacing: 4.h,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Energy Impact',
                      style: TextStyleHelper.instance.title16BoldPublicSans
                          .copyWith(color: appTheme.gray_100),
                    ),
                    Text(
                      'Dedicated to background relaying',
                      style: TextStyleHelper.instance.body12RegularPublicSans,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '24%',
                      style: TextStyleHelper.instance.headline24BoldPublicSans
                          .copyWith(color: appTheme.deep_orange_600),
                    ),
                    Text(
                      'TOTAL USAGE',
                      style: TextStyleHelper.instance.label10RegularPublicSans,
                    ),
                  ],
                ),
              ],
            ),
            Container(
              height: 8.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: appTheme.blue_gray_800,
                borderRadius: BorderRadius.circular(8.h),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 75.h, // 24% of progress
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: appTheme.deep_orange_600,
                    borderRadius: BorderRadius.circular(8.h),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6.h,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: appTheme.deep_orange_600,
                    borderRadius: BorderRadius.circular(3.h),
                  ),
                ),
                SizedBox(width: 8.h),
                Text(
                  'Heavy Network Load',
                  style: TextStyleHelper.instance.label11SemiBoldPublicSans,
                ),
                Spacer(),
                CustomImageView(
                  imagePath: ImageConstant.imgIconDeepOrange60020x16,
                  width: 16.h,
                  height: 20.h,
                ),
                SizedBox(width: 6.h),
                Text(
                  'HIGH POWER USAGE',
                  style: TextStyleHelper.instance.label11BoldPublicSans,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkMapSection(
    BuildContext context,
    PassiveNodeDashboardState state,
  ) {
    return Padding(
      padding: EdgeInsets.only(right: 8.h),
      child: Container(
        width: double.infinity,
        height: 160.h,
        child: Stack(
          children: [
            CustomImageView(
              imagePath: ImageConstant.imgAb6axubkodvebtb,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.fromLTRB(12.h, 12.h, 12.h, 12.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00160F0B), appTheme.colorCC160F],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: CustomImageView(
                      imagePath: ImageConstant.imgContainerGreenA700,
                      width: 20.h,
                      height: 24.h,
                    ),
                  ),
                  SizedBox(height: 76.h),
                  Text(
                    'NETWORK MAP',
                    style: TextStyleHelper.instance.label10BoldPublicSans.copyWith(
                      color: appTheme.deep_orange_600,
                      letterSpacing: 1.h,
                    ),
                  ),
                  Text(
                    state.connectedEndpointsCount > 0
                        ? '${state.connectedEndpointsCount} Active Peer Node${state.connectedEndpointsCount == 1 ? '' : 's'} Connected'
                        : '14 Active Peer Nodes Connected',
                    style: TextStyleHelper.instance.body14MediumPublicSans.copyWith(color: appTheme.white_A700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeManagementSection(
    BuildContext context,
    PassiveNodeDashboardState state,
  ) {
    return Column(
      children: [
        Text(
          'Node Management',
          style: TextStyleHelper.instance.title16BoldPublicSans.copyWith(
            color: appTheme.gray_100,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Suspend node activity to enter deep sleep\nand save maximum battery life.',
          textAlign: TextAlign.center,
          style: TextStyleHelper.instance.body12RegularPublicSans.copyWith(
            height: 1.33,
          ),
        ),
        SizedBox(height: 18.h),
        Padding(
          padding: EdgeInsets.fromLTRB(14.h, 0, 22.h, 0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0x3FEC5B13), appTheme.orange_900_3f],
              ),
              borderRadius: BorderRadius.circular(12.h),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFF8888).withAlpha(128),
                  blurRadius: 8.h,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            padding: EdgeInsets.all(4.h),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              decoration: BoxDecoration(
                color: appTheme.blue_gray_900,
                border: Border.all(color: appTheme.blue_gray_800, width: 1.h),
                borderRadius: BorderRadius.circular(12.h),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconButton(
                    iconPath: ImageConstant.imgOverlayBorder48x48,
                    height: 48.h,
                    width: 48.h,
                    backgroundColor: appTheme.color1919EC,
                    borderColor: appTheme.color3333EC,
                    borderWidth: 1.h,
                    borderRadius: 24.h,
                    padding: EdgeInsets.all(16.h),
                  ),
                  SizedBox(width: 16.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suspend Node',
                        style: TextStyleHelper.instance.title16BoldPublicSans
                            .copyWith(color: appTheme.gray_100),
                      ),
                      Text(
                        'ENTER POWER SAVING',
                        style: TextStyleHelper.instance.label10MediumPublicSans,
                      ),
                    ],
                  ),
                  Spacer(),
                  BlocSelector<
                    PassiveNodeDashboardBloc,
                    PassiveNodeDashboardState,
                    bool
                  >(
                    selector: (state) =>
                        state.passiveNodeDashboardModel?.isSuspendNodeEnabled ??
                        false,
                    builder: (context, isSuspendNodeEnabled) {
                      return CustomSwitch(
                        value: isSuspendNodeEnabled,
                        onChanged: (value) {
                          context.read<PassiveNodeDashboardBloc>().add(
                            ToggleSuspendNodeEvent(value: value),
                          );
                        },
                        activeColor: appTheme.colorFF52D1,
                        inactiveThumbColor: appTheme.white_A700,
                        inactiveTrackColor: appTheme.colorFFE0E0,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onSettingsPressed(BuildContext context) {
    NavigatorService.pushNamed(AppRoutes.configurationSettingsScreen);
  }
}
