import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import './bloc/app_navigation_bloc.dart';
import './models/app_navigation_model.dart';

class AppNavigationScreen extends StatelessWidget {
  const AppNavigationScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return BlocProvider<AppNavigationBloc>(
      create: (context) => AppNavigationBloc(
        AppNavigationState(appNavigationModelObj: AppNavigationModel()),
      )..add(AppNavigationInitialEvent()),
      child: AppNavigationScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0XFFFFFFFF),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Column(
                    children: [
                      _buildScreenTitle(
                        context,
                        screenTitle: "Emergency Categorization",
                        onTapScreenTitle: () => onTapScreenTitle(
                          context,
                          AppRoutes.emergencyCategorySelectionScreen,
                        ),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Home / Main Action",
                        onTapScreenTitle: () => onTapScreenTitle(
                          context,
                          AppRoutes.emergencySOSDashboardScreen,
                        ),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Updated Configuration",
                        onTapScreenTitle: () => onTapScreenTitle(
                          context,
                          AppRoutes.configurationSettingsScreen,
                        ),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Onboarding & Permissions",
                        onTapScreenTitle: () => onTapScreenTitle(
                          context,
                          AppRoutes.networkSetupScreen,
                        ),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Broadcast Status (Realistic)",
                        onTapScreenTitle: () => onTapScreenTitle(
                          context,
                          AppRoutes.sOSBroadcastingScreen,
                        ),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "Passive Node (Realistic Power)",
                        onTapScreenTitle: () => onTapScreenTitle(
                          context,
                          AppRoutes.passiveNodeDashboardScreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Common widget
  Widget _buildScreenTitle(
    BuildContext context, {
    required String screenTitle,
    Function? onTapScreenTitle,
  }) {
    return GestureDetector(
      onTap: () {
        onTapScreenTitle?.call();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.h),
        decoration: BoxDecoration(color: Color(0XFFFFFFFF)),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  screenTitle,
                  textAlign: TextAlign.center,
                  style: TextStyleHelper.instance.title20RegularRoboto.copyWith(
                    color: Color(0XFF000000),
                  ),
                ),
                Icon(Icons.arrow_forward, color: Color(0XFF343330)),
              ],
            ),
            SizedBox(height: 10.h),
            Divider(height: 1.h, thickness: 1.h, color: Color(0XFFD2D2D2)),
          ],
        ),
      ),
    );
  }

  /// Common click event
  void onTapScreenTitle(BuildContext context, String routeName) {
    NavigatorService.pushNamed(routeName);
  }

  /// Common click event for bottomsheet
  void onTapBottomSheetTitle(BuildContext context, Widget className) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return className;
      },
      isScrollControlled: true,
      backgroundColor: appTheme.transparentCustom,
    );
  }

  /// Common click event for dialog
  void onTapDialogTitle(BuildContext context, Widget className) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: className,
          backgroundColor: appTheme.transparentCustom,
          insetPadding: EdgeInsets.zero,
        );
      },
    );
  }
}
