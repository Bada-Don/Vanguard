package com.vanguard.app

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import android.content.Context

class MainActivity: FlutterFragmentActivity() {
    private val NEARBY_CHANNEL = "com.vanguard.crisis/nearby"
    private val CONNECTION_EVENT_CHANNEL = "com.vanguard.crisis/connection_events"
    private val PAYLOAD_EVENT_CHANNEL = "com.vanguard.crisis/payload_events"
    
    private lateinit var nearbyHandler: NearbyConnectionsHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize Nearby Connections handler
        nearbyHandler = NearbyConnectionsHandler(this)
        
        // Set up method channel for Nearby operations
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NEARBY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startAdvertising" -> {
                    val userName = call.argument<String>("userName") ?: "VanguardDevice"
                    nearbyHandler.startAdvertising(userName, result)
                }
                "startDiscovery" -> {
                    nearbyHandler.startDiscovery(result)
                }
                "stopAdvertising" -> {
                    nearbyHandler.stopAdvertising(result)
                }
                "stopDiscovery" -> {
                    nearbyHandler.stopDiscovery(result)
                }
                "sendPayload" -> {
                    val payload = call.argument<ByteArray>("payload")
                    if (payload != null) {
                        nearbyHandler.sendPayload(payload, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Payload is null", null)
                    }
                }
                "getConnectedEndpointsCount" -> {
                    nearbyHandler.getConnectedEndpointsCount(result)
                }
                "getConnectedEndpoints" -> {
                    nearbyHandler.getConnectedEndpoints(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Set up event channel for connection events
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CONNECTION_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    nearbyHandler.setConnectionEventSink(events)
                }

                override fun onCancel(arguments: Any?) {
                    nearbyHandler.setConnectionEventSink(null)
                }
            }
        )
        
        // Set up event channel for payload events
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, PAYLOAD_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    nearbyHandler.setPayloadEventSink(events)
                }

                override fun onCancel(arguments: Any?) {
                    nearbyHandler.setPayloadEventSink(null)
                }
            }
        )

        val BACKGROUND_CHANNEL = "com.vanguard.crisis/background_service"
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BACKGROUND_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    val serviceIntent = Intent(this, VanguardBackgroundService::class.java)
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                        startForegroundService(serviceIntent)
                    } else {
                        startService(serviceIntent)
                    }
                    result.success(true)
                }
                "stopService" -> {
                    val serviceIntent = Intent(this, VanguardBackgroundService::class.java)
                    stopService(serviceIntent)
                    result.success(true)
                }
                "requestBatteryExemption" -> {
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                        val pkgName = packageName
                        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                        if (!pm.isIgnoringBatteryOptimizations(pkgName)) {
                            val batIntent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                            batIntent.data = Uri.parse("package:$pkgName")
                            startActivity(batIntent)
                            result.success(true)
                        } else {
                            result.success(true)
                        }
                    } else {
                        result.success(true)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        nearbyHandler.cleanup()
    }
}

