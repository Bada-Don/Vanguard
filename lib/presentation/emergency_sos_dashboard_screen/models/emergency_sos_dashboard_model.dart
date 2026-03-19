import '../../../core/app_export.dart';

/// This class is used in the [emergency_sos_dashboard_screen] screen.

// ignore_for_file: must_be_immutable
class EmergencySOSDashboardModel extends Equatable {
  EmergencySOSDashboardModel({
    this.vanguardLogo,
    this.settingsIcon,
    this.connectivityIcon,
    this.meshNodesIcon,
    this.sosIcon,
    this.mapPreview,
    this.sectorIcon,
    this.id,
  }) {
    vanguardLogo = vanguardLogo ?? ImageConstant.imgOverlay;
    settingsIcon = settingsIcon ?? ImageConstant.imgButton;
    connectivityIcon = connectivityIcon ?? ImageConstant.imgIconCyanA400;
    meshNodesIcon = meshNodesIcon ?? ImageConstant.imgIconDeepOrange60012x14;
    sosIcon = sosIcon ?? ImageConstant.imgIconWhiteA70068x44;
    mapPreview = mapPreview ?? ImageConstant.imgMapViewShowing;
    sectorIcon = sectorIcon ?? ImageConstant.imgIconCyanA40020x16;
    id = id ?? "";
  }

  String? vanguardLogo;
  String? settingsIcon;
  String? connectivityIcon;
  String? meshNodesIcon;
  String? sosIcon;
  String? mapPreview;
  String? sectorIcon;
  String? id;

  EmergencySOSDashboardModel copyWith({
    String? vanguardLogo,
    String? settingsIcon,
    String? connectivityIcon,
    String? meshNodesIcon,
    String? sosIcon,
    String? mapPreview,
    String? sectorIcon,
    String? id,
  }) {
    return EmergencySOSDashboardModel(
      vanguardLogo: vanguardLogo ?? this.vanguardLogo,
      settingsIcon: settingsIcon ?? this.settingsIcon,
      connectivityIcon: connectivityIcon ?? this.connectivityIcon,
      meshNodesIcon: meshNodesIcon ?? this.meshNodesIcon,
      sosIcon: sosIcon ?? this.sosIcon,
      mapPreview: mapPreview ?? this.mapPreview,
      sectorIcon: sectorIcon ?? this.sectorIcon,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
    vanguardLogo,
    settingsIcon,
    connectivityIcon,
    meshNodesIcon,
    sosIcon,
    mapPreview,
    sectorIcon,
    id,
  ];
}
