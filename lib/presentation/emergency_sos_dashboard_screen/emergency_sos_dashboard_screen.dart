import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import './bloc/emergency_sos_dashboard_bloc.dart';
import './emergency_sos_dashboard_initial_page.dart';
import './models/emergency_sos_dashboard_model.dart';

class EmergencySOSDashboardScreen extends StatefulWidget {
  EmergencySOSDashboardScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return BlocProvider<EmergencySOSDashboardBloc>(
      create: (context) => EmergencySOSDashboardBloc(
        EmergencySOSDashboardState(
          emergencySOSDashboardModelObj: EmergencySOSDashboardModel(),
        ),
      )..add(EmergencySOSDashboardInitialEvent()),
      child: EmergencySOSDashboardScreen(),
    );
  }

  @override
  State<EmergencySOSDashboardScreen> createState() =>
      _EmergencySOSDashboardScreenState();
}

class _EmergencySOSDashboardScreenState
    extends State<EmergencySOSDashboardScreen> {
  int _selectedIndex = 0;

  void _onTabChanged(int index) {
    switch (index) {
      case 0:
        setState(() => _selectedIndex = 0);
        break;
      case 1:
        NavigatorService.pushNamed(AppRoutes.networkSetupScreen);
        break;
      case 2:
        NavigatorService.pushNamed(AppRoutes.passiveNodeDashboardScreen);
        break;
      case 3:
        NavigatorService.pushNamed(AppRoutes.emergencyCategorySelectionScreen);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: EmergencySOSDashboardInitialPage.builder(context),
        bottomNavigationBar: SizedBox(
          width: double.maxFinite,
          child: _buildBottomNavigation(context),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return CustomBottomBar(
      bottomBarItemList: [
        CustomBottomBarItem(
          icon: ImageConstant.imgNavHomeBlueGray300,
          activeIcon: ImageConstant.imgNavHome,
          title: 'Home',
          routeName: AppRoutes.emergencySOSDashboardScreenInitialPage,
        ),
        CustomBottomBarItem(
          icon: ImageConstant.imgNavNetworkBlueGray500,
          activeIcon: ImageConstant.imgNavNetwork,
          title: 'Network',
          routeName: AppRoutes.networkSetupScreen,
        ),
        CustomBottomBarItem(
          icon: ImageConstant.imgNavPeers,
          activeIcon: ImageConstant.imgNavPeers,
          title: 'Peers',
          routeName: AppRoutes.passiveNodeDashboardScreen,
        ),
        CustomBottomBarItem(
          icon: ImageConstant.imgNavAlerts,
          activeIcon: ImageConstant.imgNavAlerts,
          title: 'Alerts',
          routeName: AppRoutes.emergencyCategorySelectionScreen,
        ),
      ],
      selectedIndex: _selectedIndex,
      onChanged: _onTabChanged,
      backgroundColor: appTheme.gray_900_03,
      borderColor: appTheme.blue_gray_900,
      activeColor: appTheme.deep_orange_600,
      inactiveColor: appTheme.blue_gray_500,
    );
  }
}
