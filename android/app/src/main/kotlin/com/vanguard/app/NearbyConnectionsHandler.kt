package com.vanguard.app

import android.content.Context
import android.util.Log
import com.google.android.gms.nearby.Nearby
import com.google.android.gms.nearby.connection.*
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Handler for Google Nearby Connections API
 * Manages P2P_CLUSTER mesh networking for emergency communication
 */
class NearbyConnectionsHandler(private val context: Context) {
    
    companion object {
        private const val TAG = "NearbyConnections"
        private const val SERVICE_ID = "com.vanguard.crisis"
        private val STRATEGY = Strategy.P2P_CLUSTER
    }

    private val connectionsClient: ConnectionsClient = Nearby.getConnectionsClient(context)
    private val connectedEndpoints = mutableSetOf<String>()
    
    private var connectionEventSink: EventChannel.EventSink? = null
    private var payloadEventSink: EventChannel.EventSink? = null

    /**
     * Connection lifecycle callback
     * Handles connection initiation, result, and disconnection
     */
    private val connectionLifecycleCallback = object : ConnectionLifecycleCallback() {
        override fun onConnectionInitiated(endpointId: String, connectionInfo: ConnectionInfo) {
            Log.d(TAG, "Connection initiated with $endpointId: ${connectionInfo.endpointName}")
            
            // Auto-accept all connections for emergency mesh
            connectionsClient.acceptConnection(endpointId, payloadCallback)
            
            Log.i(TAG, "Auto-accepted connection from $endpointId")
        }

        override fun onConnectionResult(endpointId: String, result: ConnectionResolution) {
            when (result.status.statusCode) {
                ConnectionsStatusCodes.STATUS_OK -> {
                    Log.i(TAG, "Connected to $endpointId")
                    connectedEndpoints.add(endpointId)
                    
                    // Notify Flutter
                    connectionEventSink?.success(mapOf(
                        "type" to "endpointConnected",
                        "endpointId" to endpointId
                    ))
                    
                    // Update state to connected
                    connectionEventSink?.success(mapOf(
                        "type" to "stateChanged",
                        "state" to "connected"
                    ))
                }
                ConnectionsStatusCodes.STATUS_CONNECTION_REJECTED -> {
                    Log.w(TAG, "Connection rejected by $endpointId")
                }
                ConnectionsStatusCodes.STATUS_ERROR -> {
                    Log.e(TAG, "Connection error with $endpointId")
                }
                else -> {
                    Log.w(TAG, "Unknown connection result: ${result.status.statusCode}")
                }
            }
        }

        override fun onDisconnected(endpointId: String) {
            Log.i(TAG, "Disconnected from $endpointId")
            connectedEndpoints.remove(endpointId)
            
            // Notify Flutter
            connectionEventSink?.success(mapOf(
                "type" to "endpointDisconnected",
                "endpointId" to endpointId
            ))
            
            // Update state if no endpoints remain
            if (connectedEndpoints.isEmpty()) {
                connectionEventSink?.success(mapOf(
                    "type" to "stateChanged",
                    "state" to "advertising"
                ))
            }
        }
    }

    /**
     * Endpoint discovery callback
     * Handles discovery of nearby devices
     */
    private val endpointDiscoveryCallback = object : EndpointDiscoveryCallback() {
        override fun onEndpointFound(endpointId: String, info: DiscoveredEndpointInfo) {
            Log.d(TAG, "Endpoint found: $endpointId (${info.endpointName})")
            
            // Auto-connect to all discovered endpoints for emergency mesh
            connectionsClient.requestConnection(
                "VanguardDevice", // Local device name
                endpointId,
                connectionLifecycleCallback
            ).addOnSuccessListener {
                Log.d(TAG, "Connection requested to $endpointId")
            }.addOnFailureListener { exception ->
                Log.e(TAG, "Failed to request connection to $endpointId", exception)
            }
        }

        override fun onEndpointLost(endpointId: String) {
            Log.d(TAG, "Endpoint lost: $endpointId")
        }
    }

    /**
     * Payload callback
     * Handles incoming payload data
     */
    private val payloadCallback = object : PayloadCallback() {
        override fun onPayloadReceived(endpointId: String, payload: Payload) {
            if (payload.type == Payload.Type.BYTES) {
                val bytes = payload.asBytes()
                Log.d(TAG, "Payload received from $endpointId: ${bytes?.size ?: 0} bytes")
                
                // Notify Flutter
                payloadEventSink?.success(mapOf(
                    "payload" to bytes,
                    "endpointId" to endpointId
                ))
            }
        }

        override fun onPayloadTransferUpdate(endpointId: String, update: PayloadTransferUpdate) {
            // Log transfer progress if needed
            if (update.status == PayloadTransferUpdate.Status.SUCCESS) {
                Log.d(TAG, "Payload transfer successful to $endpointId")
            } else if (update.status == PayloadTransferUpdate.Status.FAILURE) {
                Log.e(TAG, "Payload transfer failed to $endpointId")
            }
        }
    }

    /**
     * Start advertising this device
     */
    fun startAdvertising(userName: String, result: MethodChannel.Result) {
        Log.i(TAG, "Starting advertising as $userName")
        
        val advertisingOptions = AdvertisingOptions.Builder()
            .setStrategy(STRATEGY)
            .build()

        connectionsClient.startAdvertising(
            userName,
            SERVICE_ID,
            connectionLifecycleCallback,
            advertisingOptions
        ).addOnSuccessListener {
            Log.i(TAG, "Advertising started successfully")
            
            // Notify Flutter
            connectionEventSink?.success(mapOf(
                "type" to "stateChanged",
                "state" to "advertising"
            ))
            
            result.success(true)
        }.addOnFailureListener { exception ->
            Log.e(TAG, "Failed to start advertising", exception)
            result.success(false)
        }
    }

    /**
     * Start discovering nearby devices
     */
    fun startDiscovery(result: MethodChannel.Result) {
        Log.i(TAG, "Starting discovery")
        
        val discoveryOptions = DiscoveryOptions.Builder()
            .setStrategy(STRATEGY)
            .build()

        connectionsClient.startDiscovery(
            SERVICE_ID,
            endpointDiscoveryCallback,
            discoveryOptions
        ).addOnSuccessListener {
            Log.i(TAG, "Discovery started successfully")
            
            // Notify Flutter
            connectionEventSink?.success(mapOf(
                "type" to "stateChanged",
                "state" to "discovering"
            ))
            
            result.success(true)
        }.addOnFailureListener { exception ->
            Log.e(TAG, "Failed to start discovery", exception)
            result.success(false)
        }
    }

    /**
     * Stop advertising
     */
    fun stopAdvertising(result: MethodChannel.Result) {
        Log.i(TAG, "Stopping advertising")
        connectionsClient.stopAdvertising()
        result.success(true)
    }

    /**
     * Stop discovery
     */
    fun stopDiscovery(result: MethodChannel.Result) {
        Log.i(TAG, "Stopping discovery")
        connectionsClient.stopDiscovery()
        result.success(true)
    }

    /**
     * Send payload to all connected endpoints
     */
    fun sendPayload(payload: ByteArray, result: MethodChannel.Result) {
        if (connectedEndpoints.isEmpty()) {
            Log.w(TAG, "No endpoints connected, cannot send payload")
            result.success(0)
            return
        }

        Log.d(TAG, "Sending payload to ${connectedEndpoints.size} endpoints (${payload.size} bytes)")
        
        val bytesPayload = Payload.fromBytes(payload)
        var sentCount = 0

        for (endpointId in connectedEndpoints) {
            connectionsClient.sendPayload(endpointId, bytesPayload)
                .addOnSuccessListener {
                    sentCount++
                    Log.d(TAG, "Payload sent to $endpointId")
                }
                .addOnFailureListener { exception ->
                    Log.e(TAG, "Failed to send payload to $endpointId", exception)
                }
        }

        result.success(sentCount)
    }

    /**
     * Get connected endpoints count
     */
    fun getConnectedEndpointsCount(result: MethodChannel.Result) {
        result.success(connectedEndpoints.size)
    }

    /**
     * Get connected endpoints list
     */
    fun getConnectedEndpoints(result: MethodChannel.Result) {
        result.success(connectedEndpoints.toList())
    }

    /**
     * Set connection event sink for Flutter communication
     */
    fun setConnectionEventSink(eventSink: EventChannel.EventSink?) {
        this.connectionEventSink = eventSink
    }

    /**
     * Set payload event sink for Flutter communication
     */
    fun setPayloadEventSink(eventSink: EventChannel.EventSink?) {
        this.payloadEventSink = eventSink
    }

    /**
     * Disconnect all endpoints and stop all operations
     */
    fun cleanup() {
        Log.i(TAG, "Cleaning up Nearby Connections")
        connectionsClient.stopAdvertising()
        connectionsClient.stopDiscovery()
        connectionsClient.stopAllEndpoints()
        connectedEndpoints.clear()
    }
}
