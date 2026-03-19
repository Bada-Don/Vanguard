import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class BackgroundService {
  final Logger _logger;
  static const MethodChannel _channel = MethodChannel('com.vanguard.crisis/background_service');

  BackgroundService({Logger? logger}) : _logger = logger ?? Logger();

  Future<bool> startBackgroundService() async {
    try {
      _logger.i('Starting background service');
      final result = await _channel.invokeMethod<bool>('startService');
      return result ?? false;
    } on PlatformException catch (e) {
      _logger.e('Failed to start background service: ${e.message}');
      return false;
    }
  }

  Future<bool> stopBackgroundService() async {
    try {
      _logger.i('Stopping background service');
      final result = await _channel.invokeMethod<bool>('stopService');
      return result ?? false;
    } on PlatformException catch (e) {
      _logger.e('Failed to stop background service: ${e.message}');
      return false;
    }
  }

  Future<bool> requestBatteryExemption() async {
    try {
      _logger.i('Requesting battery optimization exemption');
      // For iOS this would return a false/not implemented or we can just ignore
      final result = await _channel.invokeMethod<bool>('requestBatteryExemption');
      return result ?? false;
    } on PlatformException catch (e) {
      _logger.e('Failed to request battery exemption: ${e.message}');
      return false;
    } catch (e) {
      // In case invokeMethod drops an unimplemented error for iOS
      _logger.i('Battery exemption request is not implemented for this platform');
      return false;
    }
  }
}
