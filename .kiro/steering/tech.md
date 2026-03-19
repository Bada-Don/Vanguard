# Technology Stack

## Framework & Language

- Flutter SDK: ^3.29.2
- Dart SDK: ^3.9.0
- Platform: Cross-platform (Android/iOS)

## Key Dependencies

- `flutter_bloc` (^8.1.6): State management using BLoC pattern
- `equatable` (^2.0.5): Value equality for state objects
- `connectivity_plus` (^6.1.0): Network connectivity monitoring
- `flutter_svg` (^2.0.12): SVG asset rendering
- `cached_network_image` (^3.4.1): Image caching
- `shared_preferences` (^2.3.3): Local data persistence
- `gradient_borders` (^1.0.2): UI styling
- `universal_html` (^2.2.4): Web compatibility

## Mesh Networking Implementation

### Nearby Devices API (P2P_CLUSTER Strategy)
- Advertising: Device announces itself to nearby devices
- Discovery: Device scans for other advertising devices
- Connection: Secure channel establishment (auto-accept for emergency mesh)
- Payload Transfer: Send encrypted data to all connected endpoints

### Key Operations
```dart
// Start Advertising
Nearby.getConnectionsClient(context).startAdvertising(
  userName,
  SERVICE_ID,
  connectionLifecycleCallback,
  AdvertisingOptions.Builder()
    .setStrategy(Strategy.P2P_CLUSTER)
    .build()
)

// Start Discovery
startDiscovery(SERVICE_ID, endpointDiscoveryCallback, options)

// Send Payload
connectionsClient.sendPayload(
  endpointId,
  Payload.fromBytes(encryptedData)
)
```

### Relay Logic
- Duplicate prevention: Maintain `Set<String> processedMessageIds`
- Hop count management: Increment and check `hop < MAX_HOPS`
- Offline relay: Rebroadcast to all connected devices when no internet
- Uplink trigger: Stop Nearby operations and upload when internet available

### Encryption & Serialization
- Encryption: AES recommended for payload security
- Serialization: JSON or protobuf preferred
- Compression: Optional but recommended for bandwidth efficiency

## Build System

### Common Commands

```bash
# Install dependencies
flutter pub get

# Run the app (development)
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Build for production
flutter build apk --release    # Android
flutter build ios --release    # iOS
```

## Configuration

- Environment variables: `env.json` (API keys for Supabase, OpenAI, Gemini, Anthropic, Perplexity)
- Analysis options: `analysis_options.yaml` (uses `package:flutter_lints/flutter.yaml`)

## Design System

- Figma design reference: 390x907 viewport
- Responsive sizing using custom `SizeUtils` with `.h` and `.fSize` extensions
- Portrait-only orientation (locked in main.dart)
- Text scaling locked to 1.0 (non-scalable)
