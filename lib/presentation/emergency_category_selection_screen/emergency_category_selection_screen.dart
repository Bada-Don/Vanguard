import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/connectivity_status_bar.dart';
import '../../widgets/connectivity_status_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_edit_text.dart';
import '../../widgets/custom_image_view.dart';
import './bloc/emergency_category_selection_bloc.dart';
import './models/emergency_category_selection_model.dart';
import '../../presentation/emergency_sos_dashboard_screen/bloc/emergency_sos_dashboard_bloc.dart';
import 'package:vanguard_crisis_response/core/models/emergency_payload.dart';

class EmergencyCategorySelectionScreen extends StatelessWidget {
  EmergencyCategorySelectionScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return BlocProvider<EmergencyCategorySelectionBloc>(
      create: (context) => EmergencyCategorySelectionBloc(
        EmergencyCategorySelectionState(
          emergencyCategorySelectionModel: EmergencyCategorySelectionModel(),
        ),
      )..add(EmergencyCategorySelectionInitialEvent()),
      child: EmergencyCategorySelectionScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = ConnectivityStatusService();
    return Scaffold(
      backgroundColor: appTheme.gray_900,
      body:
        BlocConsumer<EmergencyCategorySelectionBloc, EmergencyCategorySelectionState>(
          listener: (context, state) {
            if (state.isSubmitSuccess ?? false) {
              final typeMapping = {
                'medical': 1,
                'fire': 2,
                'search_rescue': 4,
                'supplies': 6,
                'danger': 3,
                'other': 6,
              };
              final typeId = typeMapping[state.selectedCategory ?? 'other'] ?? 6;
              context.read<EmergencySOSDashboardBloc>().add(TriggerSOSEvent(emergencyType: typeId));
              NavigatorService.goBack();
            }
          },
          builder: (context, state) {
              return ListenableBuilder(
                listenable: service,
                builder: (context, _) {
                  return ConnectivitySpinnerOverlay(
                    visible: service.isLoading,
                    message: 'Acquiring GPS lock...',
                    child: Column(
                      children: [
                        _buildAppBar(context, state),
                        ConnectivityStatusBar(
                          meshStatus: service.meshStatus,
                          gpsStatus: service.gpsStatus,
                          transmissionStatus: service.transmissionStatus,
                          errorMessage: service.errorMessage,
                          onDismissError: () => service.clearError(),
                        ),
                        _buildScrollableContent(context, state),
                      ],
                    ),
                  );
                },
              );
            },
          ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    EmergencyCategorySelectionState state,
  ) {
    return CustomAppBar(
      title: 'Broadcast Alert',
      leadingIcon: ImageConstant.imgArrowLeft,
      onLeadingPressed: () => NavigatorService.goBack(),
      showStatusIndicator: true,
      statusText: 'LIVE GPS ACTIVE',
      statusIndicatorColor: appTheme.amber_500,
      statusTextColor: appTheme.amber_500,
      backgroundColor: appTheme.colorCC1A0F,
      showShadow: true,
      actionIcons: [ImageConstant.imgIcon],
    );
  }

  Widget _buildScrollableContent(
    BuildContext context,
    EmergencyCategorySelectionState state,
  ) {
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.h, 24.h, 16.h, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(context, state),
            SizedBox(height: 20.h),
            _buildCategoriesGrid(context, state),
            SizedBox(height: 36.h),
            _buildSituationDetails(context, state),
            SizedBox(height: 70.h),
            _buildConfirmButton(context, state),
            SizedBox(height: 14.h),
            _buildWarningText(context),
            SizedBox(height: 50.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    EmergencyCategorySelectionState state,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STEP 02/03',
                style: TextStyleHelper.instance.label10BoldPublicSans.copyWith(
                  color: appTheme.deep_orange_600,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Categorize\nEmergency',
                style: TextStyleHelper.instance.headline24BoldPublicSans
                    .copyWith(height: 1.33),
              ),
            ],
          ),
        ),
        Container(
          width: 96.h,
          height: 26.h,
          decoration: BoxDecoration(
            color: appTheme.color1919EC,
            borderRadius: BorderRadius.circular(2.h),
          ),
          child: Row(
            children: [
              Container(
                width: 64.h,
                height: 4.h,
                decoration: BoxDecoration(
                  color: appTheme.deep_orange_600,
                  borderRadius: BorderRadius.circular(2.h),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid(
    BuildContext context,
    EmergencyCategorySelectionState state,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.55,
      mainAxisSpacing: 20.h,
      crossAxisSpacing: 16.h,
      children: [
        _buildCategoryCard(
          context,
          state,
          'MEDICAL',
          ImageConstant.imgIconDeepOrange600,
          'medical',
        ),
        _buildCategoryCard(
          context,
          state,
          'FIRE',
          ImageConstant.imgIconDeepOrange60028x24,
          'fire',
        ),
        _buildCategoryCard(
          context,
          state,
          'SEARCH &\nRESCUE',
          ImageConstant.imgIconDeepOrange60028x30,
          'search_rescue',
        ),
        _buildCategoryCard(
          context,
          state,
          'SUPPLIES',
          ImageConstant.imgIconDeepOrange60030x30,
          'supplies',
        ),
        _buildCategoryCard(
          context,
          state,
          'DANGER',
          ImageConstant.imgIconDeepOrange60028x32,
          'danger',
        ),
        _buildCategoryCard(
          context,
          state,
          'OTHER',
          ImageConstant.imgIconDeepOrange6006x24,
          'other',
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    EmergencyCategorySelectionState state,
    String title,
    String iconPath,
    String categoryType,
  ) {
    bool isSelected = state.selectedCategory == categoryType;

    return GestureDetector(
      onTap: () {
        context.read<EmergencyCategorySelectionBloc>().add(
          CategorySelectedEvent(category: categoryType),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Color(0x33EC5B13) : appTheme.gray_900_01,
          border: Border.all(
            color: isSelected ? Color(0xFFEC5B13) : appTheme.color33EC5B,
            width: 2.h,
          ),
          borderRadius: BorderRadius.circular(12.h),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomImageView(imagePath: iconPath, height: 30.h, width: 30.h),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyleHelper.instance.body14BoldPublicSans.copyWith(
                color: appTheme.gray_100,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSituationDetails(
    BuildContext context,
    EmergencyCategorySelectionState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.h),
          child: Text(
            'SITUATION DETAILS (OPTIONAL)',
            style: TextStyleHelper.instance.body14BoldPublicSans.copyWith(
              color: appTheme.blue_gray_300,
              letterSpacing: 1.0,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        CustomEditText(
          controller: state.situationDetailsController,
          placeholder:
              'Enter specific details, victim count, or \nstructural codes...',
          maxLines: 3,
          borderWidth: 2.h,
          borderRadius: 12.h,
          backgroundColor: appTheme.gray_900_01,
          borderColor: appTheme.color33EC5B,
          textColor: appTheme.blue_gray_300,
          hintTextColor: appTheme.blue_gray_300,
          contentPadding: EdgeInsets.fromLTRB(18.h, 20.h, 18.h, 12.h),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(
    BuildContext context,
    EmergencyCategorySelectionState state,
  ) {
    return CustomButton(
      text: 'CONFIRM & BROADCAST',
      width: double.infinity,
      backgroundColor: appTheme.deep_orange_600,
      textColor: appTheme.white_A700,
      iconPath: ImageConstant.imgIconWhiteA700,
      iconPosition: CustomButtonIconPosition.right,
      onPressed: () {
        context.read<EmergencyCategorySelectionBloc>().add(
          ConfirmAndBroadcastEvent(),
        );
      },
    );
  }

  Widget _buildWarningText(BuildContext context) {
    return Text(
      'By confirming, your precise coordinates and emergency\nstatus will be sent to all nearest responders and\nemergency services.',
      textAlign: TextAlign.center,
      style: TextStyleHelper.instance.label11RegularPublicSans.copyWith(
        height: 1.18,
      ),
    );
  }
}
