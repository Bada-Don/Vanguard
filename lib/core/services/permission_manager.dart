import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:permission_handler/permission_handler.dart';

class PermissionManager with WidgetsBindingObserver {
  final Logger _logger;
  bool _arePermissionsGranted = false;
  
  final StreamController<bool> _permissionStateController = StreamController<bool>.broadcast();

  // Callbacks for UI
  void Function(String message)? onExplanationNeeded;
  void Function()? onPermanentlyDenied;

  PermissionManager({Logger? logger}) : _logger = logger ?? Logger() {
    WidgetsBinding.instance.addObserver(this);
  }

  Stream<bool> get permissionStateStream => _permissionStateController.stream;
  bool get arePermissionsGranted => _arePermissionsGranted;

  Future<void> initialize() async {
    await checkAllPermissions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _logger.i('App resumed, re-checking permissions');
      checkAllPermissions();
    }
  }

  Future<bool> checkAllPermissions() async {
    _logger.d('Checking all required permissions');
    
    List<Permission> requiredPermissions = _getRequiredPermissions();
    
    bool allGranted = true;
    for (var permission in requiredPermissions) {
      if (!await permission.isGranted) {
        allGranted = false;
        break;
      }
    }
    
    if (_arePermissionsGranted != allGranted) {
      _arePermissionsGranted = allGranted;
      _permissionStateController.add(_arePermissionsGranted);
    }
    
    return _arePermissionsGranted;
  }

  Future<bool> requestPermissions() async {
    _logger.i('Requesting required permissions');
    List<Permission> requiredPermissions = _getRequiredPermissions();
    
    Map<Permission, PermissionStatus> statuses = await requiredPermissions.request();
    
    bool allGranted = true;
    bool anyPermanentlyDenied = false;
    List<String> deniedExplanations = [];

    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        allGranted = false;
        if (status.isPermanentlyDenied) {
          anyPermanentlyDenied = true;
        } else {
          deniedExplanations.add(_getExplanationFor(permission));
        }
      }
    });

    _arePermissionsGranted = allGranted;
    _permissionStateController.add(_arePermissionsGranted);

    if (allGranted) {
      _logger.i('All permissions granted successfully');
      return true;
    }

    if (anyPermanentlyDenied) {
      _logger.w('Some permissions are permanently denied');
      onPermanentlyDenied?.call();
    } else if (deniedExplanations.isNotEmpty) {
      _logger.w('Some permissions were denied');
      onExplanationNeeded?.call(deniedExplanations.join('\n'));
    }

    return false;
  }

  Future<bool> openAppSettings() async {
    _logger.i('Opening app settings for permissions');
    return await ph.openAppSettings();
  }

  List<Permission> _getRequiredPermissions() {
    List<Permission> permissions = [
      Permission.location,
    ];

    if (Platform.isAndroid) {
      permissions.add(Permission.bluetooth);
      permissions.add(Permission.bluetoothConnect);
      permissions.add(Permission.bluetoothScan);
      permissions.add(Permission.bluetoothAdvertise);
      permissions.add(Permission.nearbyWifiDevices); // Android 13+
    } else if (Platform.isIOS) {
      permissions.add(Permission.bluetooth);
    }
    return permissions;
  }

  String _getExplanationFor(Permission permission) {
    if (permission == Permission.location) {
      return 'Location is required to geotag emergency broadcasts establishing your whereabouts.';
    } else if (permission.toString().contains('bluetooth') || permission == Permission.nearbyWifiDevices) {
      return 'Bluetooth and Nearby Devices permissions are essential for the mesh network to communicate with nearby devices independently of internet availability.';
    }
    return 'This permission is required for the application to function correctly.';
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _permissionStateController.close();
  }
}
