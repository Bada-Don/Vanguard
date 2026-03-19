# Product Overview

Vanguard Crisis Response is a Flutter-based mobile application designed for emergency communication and crisis management. The app enables mesh network connectivity for SOS broadcasting and emergency response coordination in scenarios where traditional network infrastructure may be unavailable.

## Core Features

- Mesh network setup and management using Nearby Devices API (Bluetooth, WiFi Direct)
- Emergency SOS dashboard with category selection
- Real-time connectivity status monitoring (mesh, GPS, transmission)
- Passive node dashboard for relay functionality
- Multi-hop relay capabilities for extended network coverage
- Configuration settings for network parameters

## Target Platform

Cross-platform mobile application (Android/iOS) with portrait-only orientation.

## MVP System Flow (Nearby Devices API)

### Phase 1: Trigger and Payload Generation
User triggers SOS → App collects GPS coordinates, timestamp, emergency type → Data is serialized (JSON/protobuf), compressed, and encrypted (AES).

Payload structure:
```json
{
  "id": "unique_message_id",
  "lat": 30.7333,
  "lng": 76.7794,
  "ts": 1710000000,
  "type": 2,
  "hop": 0
}
```

### Phase 2: Local Broadcasting (Nearby Connections)
Uses `P2P_CLUSTER` strategy:
1. Start Advertising: Device announces itself
2. Start Discovery: Device scans for others
3. Auto-connect: Accept all connections (emergency mesh)
4. Send Payload: Transmit to all connected endpoints (mimics broadcast)

Note: Nearby doesn't support true broadcast - sends to all connected endpoints in a loop.

### Phase 3: Relay & Mesh Routing
- Receive payload via `onPayloadReceived`
- Decrypt and parse JSON
- Check if already seen (duplicate prevention using `Set<String> processedMessageIds`)
- If no internet: increment hop count, check limit (`hop < MAX_HOPS`), rebroadcast to all connected devices
- Connected cluster relay network (not blind broadcast)

### Phase 4: Uplink and Resolution
When any device gets internet:
1. Stop Nearby operations (`stopAdvertising()`, `stopDiscovery()`)
2. Upload payload to backend via REST API
3. Server deduplication using `message_id` and `timestamp`
4. Dashboard update with real-time alerts and map visualization

## Critical Constraints

### Permissions Required
- Bluetooth
- Location
- Nearby Devices (Android 12+)

### Range Limits
- Typical range: 10-50 meters (depends on Bluetooth/WiFi)

### Background Limitations
- Android may kill discovery or limit scanning frequency
- Not true automatic mesh networking - app must manage multi-hop relay
