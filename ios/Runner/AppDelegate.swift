import UIKit
import Flutter
import CoreLocation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  var locationManager: CLLocationManager?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let backgroundChannel = FlutterMethodChannel(name: "com.vanguard.crisis/background_service", binaryMessenger: controller.binaryMessenger)
    
    locationManager = CLLocationManager()
    
    backgroundChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "startService" {
        self.locationManager?.requestAlwaysAuthorization()
        self.locationManager?.allowsBackgroundLocationUpdates = true
        self.locationManager?.pausesLocationUpdatesAutomatically = false
        self.locationManager?.startUpdatingLocation()
        result(true)
      } else if call.method == "stopService" {
        self.locationManager?.allowsBackgroundLocationUpdates = false
        self.locationManager?.stopUpdatingLocation()
        result(true)
      } else if call.method == "requestBatteryExemption" {
        // Battery exemption is an Android concept; return true
        result(true)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
