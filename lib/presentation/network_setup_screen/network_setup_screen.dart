import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/connectivity_status_bar.dart';
import '../../widgets/connectivity_status_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_image_view.dart';
import 'package:vanguard_crisis_response/core/services/permission_manager.dart';
import 'package:vanguard_crisis_response/core/blocs/mesh_networking/mesh_networking_bloc.dart';
import 'package:vanguard_crisis_response/core/services/nearby_service.dart';

class NetworkSetupScreen extends StatefulWidget {
  const NetworkSetupScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return NetworkSetupScreen();
  }

  @override
  _NetworkSetupScreenState createState() => _NetworkSetupScreenState();
}

class _NetworkSetupScreenState extends State<NetworkSetupScreen> {
  final PermissionManager _permissionManager = PermissionManager();
  bool _permissionsGranted = false;
  String? _deniedExplanation;
  bool _permanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _permissionManager.onExplanationNeeded = (explanation) {
      if (mounted) setState(() => _deniedExplanation = explanation);
    };
    _permissionManager.onPermanentlyDenied = () {
      if (mounted) setState(() => _permanentlyDenied = true);
    };
  }

  @override
  void dispose() {
    _permissionManager.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final granted = await _permissionManager.checkAllPermissions();
    if (mounted) {
      setState(() {
        _permissionsGranted = granted;
      });
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _deniedExplanation = null;
      _permanentlyDenied = false;
    });
    final granted = await _permissionManager.requestPermissions();
    if (mounted) {
      setState(() {
        _permissionsGranted = granted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ConnectivityStatusService();
    return Scaffold(
      backgroundColor: appTheme.gray_900,
      body: BlocBuilder<MeshNetworkingBloc, MeshNetworkingState>(
        builder: (context, meshState) {
          return ListenableBuilder(
            listenable: service,
            builder: (context, _) {
              return ConnectivitySpinnerOverlay(
                visible: meshState.isStarting,
                message: 'Starting mesh networking...',
                child: Column(
                  children: [
                    CustomAppBar(
                      title: 'Network Setup',
                      leadingIcon: ImageConstant.imgArrowLeftGray100,
                      backgroundColor: appTheme.gray_900,
                      onLeadingPressed: () => NavigatorService.goBack(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: 24.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 20.h, left: 16.h, right: 16.h),
                              child: Text('Initialize Mesh Node', style: TextStyleHelper.instance.headline24BoldPublicSans, textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 12.h, left: 24.h, right: 24.h),
                              child: Text('Enable critical hardware to join the local crisis network.', textAlign: TextAlign.center, style: TextStyleHelper.instance.title16RegularPublicSans.copyWith(height: 1.6)),
                            ),
                            _buildPermissionSection(),
                            _buildMeshStateSection(meshState),
                            Padding(
                              padding: EdgeInsets.only(top: 24.h, left: 16.h, right: 16.h),
                              child: _buildActivateButton(context, meshState),
                            ),
                            if (meshState.connectionState != ConnectionState.disconnected)
                              Padding(
                                padding: EdgeInsets.only(top: 16.h, left: 16.h, right: 16.h),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => NavigatorService.pushNamedAndRemoveUntil(AppRoutes.emergencySOSDashboardScreen),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: appTheme.gray_800,
                                      padding: EdgeInsets.symmetric(vertical: 16.h),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                    ),
                                    child: Text('Proceed to Dashboard', style: TextStyleHelper.instance.title16BoldPublicSans.copyWith(color: appTheme.gray_100)),
                                  ),
                                ),
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

  Widget _buildPermissionSection() {
    return Padding(
      padding: EdgeInsets.all(16.h),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.h),
            decoration: BoxDecoration(
              color: _permissionsGranted ? appTheme.color0CEC5B : appTheme.color0CFFFF,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _permissionsGranted ? appTheme.color33EC5B : appTheme.colorFF52D1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Permissions Status', style: TextStyleHelper.instance.title16BoldPublicSans.copyWith(color: appTheme.gray_100)),
                SizedBox(height: 8.h),
                Text('Location, Bluetooth, and Nearby Devices access are required.', style: TextStyleHelper.instance.body14RegularPublicSans),
                SizedBox(height: 16.h),
                if (!_permissionsGranted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _requestPermissions,
                      style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorFF52D1),
                      child: Text('Grant Permissions', style: TextStyleHelper.instance.body14BoldPublicSans.copyWith(color: appTheme.gray_900)),
                    ),
                  )
                else
                  Text('All Permissions Granted ✓', style: TextStyleHelper.instance.title16BoldPublicSans.copyWith(color: appTheme.color33EC5B)),
                if (_deniedExplanation != null)
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: Text(_deniedExplanation!, style: TextStyleHelper.instance.body12RegularPublicSans.copyWith(color: appTheme.deep_orange_600)),
                  ),
                if (_permanentlyDenied)
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _permissionManager.openAppSettings(),
                        style: ElevatedButton.styleFrom(backgroundColor: appTheme.gray_900),
                        child: Text('Open Settings', style: TextStyleHelper.instance.body14BoldPublicSans.copyWith(color: appTheme.gray_100)),
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

  Widget _buildMeshStateSection(MeshNetworkingState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Container(
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(color: appTheme.gray_800, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Connection State:', style: TextStyleHelper.instance.body14RegularPublicSans.copyWith(color: appTheme.gray_400)),
                Text(state.connectionState.displayName, style: TextStyleHelper.instance.title16BoldPublicSans.copyWith(color: appTheme.gray_100)),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Connected Endpoints:', style: TextStyleHelper.instance.body14RegularPublicSans.copyWith(color: appTheme.gray_400)),
                Text('${state.connectedEndpointsCount}', style: TextStyleHelper.instance.title16BoldPublicSans.copyWith(color: appTheme.color33EC5B)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivateButton(BuildContext context, MeshNetworkingState state) {
    final bool isActive = state.connectionState != ConnectionState.disconnected;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _permissionsGranted ? () {
          if (isActive) {
            context.read<MeshNetworkingBloc>().add(StopMeshNetworkingEvent());
          } else {
            context.read<MeshNetworkingBloc>().add(StartMeshNetworkingEvent(userName: 'Vanguard_Node'));
          }
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? appTheme.deep_orange_600 : appTheme.color33EC5B,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        child: Text(
          isActive ? 'Stop Mesh Node' : 'Activate Mesh Node',
          style: TextStyleHelper.instance.title16BoldPublicSans.copyWith(color: appTheme.gray_100),
        ),
      ),
    );
  }
}
