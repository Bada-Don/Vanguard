import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/connectivity_status_bar.dart';
import '../../widgets/connectivity_status_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_image_view.dart';
import './bloc/sos_broadcasting_bloc.dart';
import './models/sos_broadcasting_model.dart';
import './widgets/transmission_log_item_widget.dart';

class SOSBroadcastingScreen extends StatelessWidget {
  SOSBroadcastingScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return BlocProvider<SOSBroadcastingBloc>(
      create: (context) => SOSBroadcastingBloc(
        SOSBroadcastingState(sosBroadcastingModel: SOSBroadcastingModel()),
      )..add(SOSBroadcastingInitialEvent()),
      child: SOSBroadcastingScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = ConnectivityStatusService();
    return Scaffold(
      backgroundColor: appTheme.gray_900_02,
      appBar: _buildAppBar(context),
      body: BlocConsumer<SOSBroadcastingBloc, SOSBroadcastingState>(
        listener: (context, state) {
          if (state.shouldNavigateBack ?? false) {
            Navigator.pop(context);
          }
          if (state.broadcastTerminated ?? false) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Broadcast terminated successfully'),
                backgroundColor: appTheme.red_700,
              ),
            );
          }
        },
        builder: (context, state) {
          return ListenableBuilder(
            listenable: service,
            builder: (context, _) {
              return ConnectivitySpinnerOverlay(
                visible: service.isLoading,
                message: 'Establishing secure broadcast channel...',
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
                          children: [
                            SizedBox(height: 30.h),
                            _buildEmergencySignalSection(context, state),
                            SizedBox(height: 30.h),
                            _buildNearbyDevicesSection(context, state),
                            SizedBox(height: 30.h),
                            _buildTransmissionLogSection(context, state),
                            SizedBox(height: 30.h),
                            _buildMapAndActionsSection(context, state),
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
      height: 64.h,
      backgroundColor: appTheme.gray_900_02,
      showBorder: true,
      leadingIcon: ImageConstant.imgContainerGray100,
      onLeadingPressed: () {
        context.read<SOSBroadcastingBloc>().add(CloseButtonPressedEvent());
      },
      title: 'SOS ACTIVE',
      titleColor: appTheme.gray_100,
      showStatusIndicator: true,
      statusText: 'BROADCASTING',
      statusIndicatorColor: appTheme.deep_orange_600,
      statusTextColor: appTheme.deep_orange_600,
      actionIcons: [ImageConstant.imgContainerGray10048x48],
      onActionPressed: (index) {
        context.read<SOSBroadcastingBloc>().add(RefreshButtonPressedEvent());
      },
    );
  }

  Widget _buildEmergencySignalSection(
    BuildContext context,
    SOSBroadcastingState state,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 38.h),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            ImageConstant
                .imgRippleEffectBackgroundStaticRepresentationsOfTheRequestedDynamicElement,
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 8.h),
            width: 100.h,
            height: 84.h,
            decoration: BoxDecoration(
              color: appTheme.color19EC5B,
              border: Border.all(color: appTheme.color4CEC5B, width: 1.h),
              borderRadius: BorderRadius.circular(42.h),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomImageView(
                  imagePath: ImageConstant.imgIconDeepOrange60034x50,
                  height: 34.h,
                  width: 50.h,
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'EMERGENCY SIGNAL',
            style: TextStyleHelper.instance.body14BoldPublicSans.copyWith(
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ACTIVE',
            style: TextStyleHelper.instance.display48BlackPublicSans,
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyDevicesSection(
    BuildContext context,
    SOSBroadcastingState state,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.h),
      padding: EdgeInsets.all(24.h),
      decoration: BoxDecoration(
        color: appTheme.color0CEC5B,
        border: Border.all(color: appTheme.color33EC5B, width: 1.h),
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nearby Devices Reached',
                style: TextStyleHelper.instance.title16MediumPublicSans,
              ),
              CustomImageView(
                imagePath: ImageConstant.imgIconDeepOrange60018x20,
                height: 18.h,
                width: 20.h,
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${state.sosBroadcastingModel?.nearbyDevicesCount ?? 14}',
                style: TextStyleHelper.instance.display48BoldPublicSans,
              ),
              SizedBox(width: 8.h),
              Padding(
                padding: EdgeInsets.only(bottom: 18.h),
                child: Row(
                  children: [
                    CustomImageView(
                      imagePath: ImageConstant.imgIconGreenA700,
                      height: 6.h,
                      width: 10.h,
                    ),
                    SizedBox(width: 4.h),
                    Text(
                      '+${state.sosBroadcastingModel?.additionalDevices ?? 1}',
                      style: TextStyleHelper.instance.body14BoldPublicSans
                          .copyWith(color: appTheme.green_A700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Container(
            height: 6.h,
            decoration: BoxDecoration(
              color: appTheme.color19EC5B,
              borderRadius: BorderRadius.circular(3.h),
            ),
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    color: appTheme.deep_orange_600,
                    borderRadius: BorderRadius.circular(3.h),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransmissionLogSection(
    BuildContext context,
    SOSBroadcastingState state,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transmission Log',
                style: TextStyleHelper.instance.title18BoldPublicSans.copyWith(
                  color: appTheme.gray_100,
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.read<SOSBroadcastingBloc>().add(
                    LiveUpdatesButtonPressedEvent(),
                  );
                },
                child: Text(
                  'LIVE UPDATES',
                  style: TextStyleHelper.instance.body12BoldPublicSans.copyWith(
                    color: appTheme.deep_orange_600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          BlocSelector<
            SOSBroadcastingBloc,
            SOSBroadcastingState,
            List<TransmissionLogModel>
          >(
            selector: (state) =>
                state.sosBroadcastingModel?.transmissionLogs ?? [],
            builder: (context, transmissionLogs) {
              return Column(
                children: transmissionLogs
                    .map(
                      (log) => Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: TransmissionLogItemWidget(
                          transmissionLog: log,
                          onTap: () {
                            context.read<SOSBroadcastingBloc>().add(
                              TransmissionLogItemTappedEvent(
                                logId: log.id ?? '',
                              ),
                            );
                          },
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapAndActionsSection(
    BuildContext context,
    SOSBroadcastingState state,
  ) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.h, 0, 16.h, 62.h),
      child: Column(
        children: [
          Container(
            height: 174.h,
            decoration: BoxDecoration(
              color: appTheme.color7F2216,
              border: Border.all(color: appTheme.color33EC5B, width: 1.h),
              borderRadius: BorderRadius.circular(12.h),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.h),
                    color: appTheme.blue_gray_300,
                  ),
                  child: Center(
                    child: Text(
                      'Map View\nSan Francisco',
                      textAlign: TextAlign.center,
                      style: TextStyleHelper.instance.title16SemiBold,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12.h,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Current Location Locked',
                        style: TextStyleHelper.instance.body14BoldPublicSans
                            .copyWith(color: appTheme.gray_100),
                      ),
                      SizedBox(width: 8.h),
                      Text(
                        '${state.sosBroadcastingModel?.currentLocation ?? "37.7749° N, 122.4194° W"}',
                        style: TextStyleHelper.instance.body12RegularPublicSans
                            .copyWith(color: appTheme.blue_gray_500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 26.h),
          CustomButton(
            text: 'TERMINATE BROADCAST',
            width: double.infinity,
            backgroundColor: appTheme.red_700,
            textColor: appTheme.whiteCustom,
            iconPath: ImageConstant.imgIconWhiteA70024x24,
            iconPosition: CustomButtonIconPosition.left,
            onPressed: () {
              context.read<SOSBroadcastingBloc>().add(
                TerminateBroadcastButtonPressedEvent(),
              );
            },
          ),
          SizedBox(height: 26.h),
          Text(
            'SECURE END-TO-END ENCRYPTION ACTIVE',
            style: TextStyleHelper.instance.body12BoldPublicSans.copyWith(
              color: appTheme.blue_gray_500,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}
