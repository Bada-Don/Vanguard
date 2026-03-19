import 'package:flutter/material.dart';
import '../presentation/emergency_category_selection_screen/emergency_category_selection_screen.dart';
import '../presentation/emergency_sos_dashboard_screen/emergency_sos_dashboard_screen.dart';
import '../presentation/configuration_settings_screen/configuration_settings_screen.dart';
import '../presentation/network_setup_screen/network_setup_screen.dart';
import '../presentation/sos_broadcasting_screen/sos_broadcasting_screen.dart';
import '../presentation/passive_node_dashboard_screen/passive_node_dashboard_screen.dart';

import '../presentation/app_navigation_screen/app_navigation_screen.dart';

class AppRoutes {
  static const String emergencyCategorySelectionScreen =
      '/emergency_category_selection_screen';
  static const String emergencySOSDashboardScreen =
      '/emergency_s_o_s_dashboard_screen';
  static const String emergencySOSDashboardScreenInitialPage =
      '/emergency_s_o_s_dashboard_screen_initial_page';
  static const String configurationSettingsScreen =
      '/configuration_settings_screen';
  static const String networkSetupScreen = '/network_setup_screen';
  static const String sOSBroadcastingScreen = '/s_o_s_broadcasting_screen';
  static const String passiveNodeDashboardScreen =
      '/passive_node_dashboard_screen';

  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute = '/';

  static Map<String, WidgetBuilder> get routes => {
    emergencyCategorySelectionScreen: EmergencyCategorySelectionScreen.builder,
    emergencySOSDashboardScreen: EmergencySOSDashboardScreen.builder,
    configurationSettingsScreen: ConfigurationSettingsScreen.builder,
    networkSetupScreen: NetworkSetupScreen.builder,
    sOSBroadcastingScreen: SOSBroadcastingScreen.builder,
    passiveNodeDashboardScreen: PassiveNodeDashboardScreen.builder,
    appNavigationScreen: AppNavigationScreen.builder,
    initialRoute: NetworkSetupScreen.builder,
  };
}
