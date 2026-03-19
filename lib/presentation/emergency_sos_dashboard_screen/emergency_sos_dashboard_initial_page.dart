import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/connectivity_status_bar.dart';
import '../../widgets/connectivity_status_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_image_view.dart';
import './bloc/emergency_sos_dashboard_bloc.dart';

class EmergencySOSDashboardInitialPage extends StatelessWidget {
  const EmergencySOSDashboardInitialPage({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<EmergencySOSDashboardBloc>(context),
      child: EmergencySOSDashboardInitialPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = ConnectivityStatusService();
    return BlocBuilder<EmergencySOSDashboardBloc, EmergencySOSDashboardState>(
      builder: (context, state) {
        return ListenableBuilder(
          listenable: service,
          builder: (context, _) {
            return ConnectivitySpinnerOverlay(
              visible: service.isLoading,
              message: 'Initializing mesh network...',
              child: Scaffold(
                backgroundColor: appTheme.black_900_01,
                appBar: _buildAppBar(context),
                body: Column(
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
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.h, 16.h, 16.h, 0),
                          child: Column(
                            children: [
                              _buildStatusCards(context),
                              SizedBox(height: 32.h),
                              _buildSOSButton(context),
                              SizedBox(height: 32.h),
                              _buildMapPreview(context),
                              SizedBox(height: 16.h),
                            ],
                          ),
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
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
      title: 'Vanguard',
      subtitle: 'Crisis Response Network',
      leadingIcon: ImageConstant.imgOverlay,
      actionIcons: [ImageConstant.imgButton],
      backgroundColor: appTheme.colorCC120A,
      titleColor: appTheme.gray_100,
      subtitleColor: appTheme.blue_gray_300,
      showShadow: true,
      onActionPressed: (index) {
        NavigatorService.pushNamed(AppRoutes.configurationSettingsScreen);
      },
    );
  }

  Widget _buildStatusCards(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildConnectivityCard(context)),
        SizedBox(width: 12.h),
        Expanded(child: _buildMeshNodesCard(context)),
      ],
    );
  }

  Widget _buildConnectivityCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: appTheme.gray_900_03,
        border: Border.all(color: appTheme.blue_gray_900),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgIconCyanA400,
                height: 8.h,
                width: 12.h,
              ),
              SizedBox(width: 8.h),
              Text(
                'CONNECTIVITY',
                style: TextStyleHelper.instance.label10Bold.copyWith(
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Online',
            style: TextStyleHelper.instance.title18Bold,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            height: 4.h,
            decoration: BoxDecoration(
              color: appTheme.cyan_A400,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeshNodesCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: appTheme.gray_900_03,
        border: Border.all(color: appTheme.blue_gray_900),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgIconDeepOrange60012x14,
                height: 12.h,
                width: 14.h,
              ),
              SizedBox(width: 8.h),
              Text(
                'MESH NODES',
                style: TextStyleHelper.instance.label10Bold.copyWith(
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '8 Active',
            style: TextStyleHelper.instance.title18Bold.copyWith(
              color: appTheme.deep_orange_600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildNodeDot(appTheme.deep_orange_600),
              SizedBox(width: 4.h),
              _buildNodeDot(appTheme.deep_orange_600),
              SizedBox(width: 4.h),
              _buildNodeDot(appTheme.deep_orange_600),
              SizedBox(width: 4.h),
              _buildNodeDot(appTheme.blue_gray_800),
              SizedBox(width: 4.h),
              _buildNodeDot(appTheme.blue_gray_800),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNodeDot(Color color) {
    return Container(
      height: 6.h,
      width: 6.h,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildSOSButton(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 320.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outermost glow ring
              Container(
                width: 300.h,
                height: 300.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appTheme.color19FF00.withAlpha(38),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: appTheme.deep_orange_600.withAlpha(20),
                      blurRadius: 40.h,
                      spreadRadius: 20.h,
                    ),
                  ],
                ),
              ),
              // Middle ring
              Container(
                width: 250.h,
                height: 250.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appTheme.color4CFF00.withAlpha(51),
                    width: 1,
                  ),
                ),
              ),
              // Inner ring
              Container(
                width: 200.h,
                height: 200.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appTheme.deep_orange_600.withAlpha(77),
                    width: 1,
                  ),
                ),
              ),
              // Main SOS button
              GestureDetector(
                onLongPress: () {
                  context.read<EmergencySOSDashboardBloc>().add(
                    InitializeSOSEvent(),
                  );
                },
                child: Container(
                  width: 160.h,
                  height: 160.h,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        Color(0xFFFF003C),
                        appTheme.pink_900,
                        Color(0xFF4A0A0A),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: appTheme.red_A400.withAlpha(153),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: appTheme.red_A400.withAlpha(102),
                        blurRadius: 30.h,
                        spreadRadius: 4.h,
                      ),
                      BoxShadow(
                        color: appTheme.deep_orange_600.withAlpha(51),
                        blurRadius: 60.h,
                        spreadRadius: 10.h,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomImageView(
                        imagePath: ImageConstant.imgIconWhiteA70068x44,
                        height: 40.h,
                        width: 28.h,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'SOS',
                        style: TextStyleHelper.instance.title20Black.copyWith(
                          letterSpacing: 3.0,
                          fontSize: 18.fSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Text('Emergency Trigger', style: TextStyleHelper.instance.title20Bold),
        SizedBox(height: 6.h),
        Text(
          'Hold for 3 seconds to broadcast emergency\nsignal to all nearby nodes and authorities.',
          textAlign: TextAlign.center,
          style: TextStyleHelper.instance.body14Regular.copyWith(height: 1.5),
        ),
      ],
    );
  }

  Widget _buildMapPreview(BuildContext context) {
    return Container(
      height: 160.h,
      decoration: BoxDecoration(
        border: Border.all(color: appTheme.blue_gray_900),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Stack(
        children: [
          CustomImageView(
            imagePath: ImageConstant.imgMapViewShowing,
            height: 158.h,
            width: double.infinity,
            fit: BoxFit.cover,
            radius: BorderRadius.circular(12.0),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  appTheme.black_900_01.withAlpha(217),
                ],
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          Positioned(
            left: 16.h,
            right: 16.h,
            bottom: 12.h,
            child: Row(
              children: [
                CustomImageView(
                  imagePath: ImageConstant.imgIconCyanA40020x16,
                  height: 20.h,
                  width: 16.h,
                ),
                SizedBox(width: 8.h),
                Expanded(
                  child: Text(
                    'SECTOR 7-G • HIGH ALERT',
                    style: TextStyleHelper.instance.body12Bold.copyWith(
                      letterSpacing: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: appTheme.red_700.withAlpha(217),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    'LIVE',
                    style: TextStyleHelper.instance.label10Bold.copyWith(
                      color: appTheme.white_A700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
