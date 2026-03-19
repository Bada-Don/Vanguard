# Technology Stack

## Framework & Language

- Flutter SDK: ^3.29.2
- Dart SDK: ^3.9.0
- Platform: Cross-platform (Android/iOS)

## Key Dependencies

### State Management & Core
- `flutter_bloc` (^8.1.6): State management using BLoC pattern
- `equatable` (^2.0.5): Value equality for state objects

### Mesh Networking (✅ Implemented)
- `geolocator` (^13.0.2): GPS coordinate collection with high accuracy
- `permission_handler` (^11.3.1): Runtime permission management
- `uuid` (^4.5.1): UUID v4 generation for message IDs
- `encrypt` (^5.0.3): AES-256-CBC encryption/decryption
- `flutter_secure_storage` (^9.2.2): Secure key storage (Android Keystore/iOS Keychain)
- `logger` (^2.4.0): Structured logging with levels

### Connectivity & Storage
- `connectivity_plus` (^6.1.0): Network connectivity monitoring
- `shared_preferences` (^2.3.3): Local data persistence (message queue)
- `http` (^1.2.2): HTTP client for backend API

### UI & Assets
- `flutter_svg` (^2.0.12): SVG asset rendering
- `cached_network_image` (^3.4.1): Image caching
- `gradient_borders` (^1.0.2): UI styling
- `universal_html` (^2.2.4): Web compatibility

### Testing (✅ Implemented)
- `mockito` (^5.4.4): Mocking framework for unit tests
- `build_runner` (^2.4.13): Code generation for mocks

## Mesh Networking Implementation (✅ Phase 1-5 Complete)

### Phase 1: Core Infrastructure (✅ Complete)
**Implemented Services:**
- `EmergencyPayload` model: Complete data structure with JSON serialization
- `ConnectionInfo` model: Endpoint tracking and metadata
- `MeshNetworkConfig` model: Configurable parameters (maxHops: 3-5, queueSize: 50-200)
- Environment configuration: `EnvConfig` for API endpoints
- Platform channels: `PlatformChannelHandler` for native communication

**Android Configuration:**
- Permissions: Bluetooth, Location, Nearby Devices (Android 12+), Foreground Service
- Manifest configured with all required permissions

**iOS Configuration:**
- Permissions: MultipeerConnectivity, Bluetooth, Location
- Info.plist configured (iOS implementation pending)

### Phase 2: Encryption & Security (✅ Complete)
**Implemented Service:** `EncryptionLayer`
- AES-256-CBC encryption/decryption
- GZIP compression (50-90% size reduction)
- Secure key storage (Android Keystore/iOS Keychain via flutter_secure_storage)
- Cryptographically secure IV generation
- Key rotation support
- Result type pattern for error handling
- **Test Coverage:** 20 unit tests, all passing

### Phase 3: Payload Generation (✅ Complete)
**Implemented Service:** `PayloadGenerator`
- GPS coordinate collection with high accuracy mode
- Retry logic: 3 attempts with 2-second delays
- 50m accuracy threshold, 100m fallback
- UUID v4 generation for unique message IDs
- Unix epoch timestamp with millisecond precision
- Support for 6 emergency types (Medical, Fire, Crime, Natural Disaster, Accident, Other)
- Comprehensive error handling
- **Test Coverage:** 23 unit tests, all passing

### Phase 4: Platform-Specific Nearby Service (✅ Complete - Android)
**Implemented Services:**
- **Android:** `NearbyConnectionsHandler` (Kotlin) - Google Nearby Connections API
  - P2P_CLUSTER strategy implementation
  - Auto-accept connections, auto-connect to discovered endpoints
  - Connection lifecycle management
  - Payload handling with event channels
  - Integrated with MainActivity
- **iOS:** Template provided (requires physical devices for testing)
- **Dart Interface:** `NearbyService` - Unified cross-platform abstraction
  - Connection state management (disconnected, advertising, discovering, connected)
  - Platform channel integration
  - Endpoint tracking
  - Payload queue for offline scenarios
  - Event streams for state changes and payload reception
  - **Test Coverage:** 26 unit tests, all passing

### Phase 5: Relay & Message Management (✅ Complete)
**Implemented Services:**

1. **`RelayManager`** - Core relay processing
   - Complete relay pipeline: decrypt → validate → duplicate check → hop check → relay
   - Duplicate prevention using `Set<String> processedMessageIds`
   - Hop count management with configurable max hops
   - Re-encryption and relay to all connected endpoints
   - Message queue integration for uplink
   - Comprehensive statistics tracking (processed, relayed, duplicate, dropped)
   - Event streams for monitoring
   - **Test Coverage:** 32 unit tests

2. **`MessageQueue`** - Persistent message storage
   - FIFO queue with configurable size (50-200)
   - Persistent storage using SharedPreferences
   - Automatic overflow handling (removes oldest)
   - Duplicate prevention
   - Query operations (by type, time range)
   - Statistics and utilization tracking
   - **Test Coverage:** 30 unit tests, all passing

3. **`PayloadValidator`** - Comprehensive validation
   - UUID v4 format validation for message IDs
   - Coordinate validation (lat: -90 to 90, lng: -180 to 180)
   - Timestamp validation (positive, within last 24 hours)
   - Emergency type validation (1-6)
   - Hop count validation (non-negative)
   - Detailed error messages
   - **Test Coverage:** 70 unit tests, all passing

**Total Phase 1-5 Test Coverage:** 201 unit tests, >90% code coverage

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

### Relay Logic (✅ Implemented in Phase 5)
**Implementation Details:**
- Duplicate prevention: `Set<String> processedMessageIds` in RelayManager
- Hop count management: Increment and check `hop < MAX_HOPS` (configurable 3-5)
- Offline relay: Rebroadcast to all connected devices via NearbyService
- Message validation: PayloadValidator ensures data integrity
- Message queue: Persistent FIFO queue (50-200 messages) for uplink
- Statistics tracking: Processed, relayed, duplicate, dropped messages
- Event streams: Real-time monitoring of relay operations

**Relay Pipeline:**
```dart
// Implemented in RelayManager.processReceivedPayload()
1. Receive encrypted payload from NearbyService
2. Decrypt using EncryptionLayer
3. Parse JSON to EmergencyPayload
4. Validate using PayloadValidator
5. Check duplicate (processedMessageIds.contains(id))
6. Check hop count (hop < maxHops)
7. Increment hop count
8. Re-encrypt updated payload
9. Send to all connected endpoints
10. Add to MessageQueue for uplink
```

### Encryption & Serialization (✅ Implemented in Phase 2)
**Implementation Details:**
- Encryption: AES-256-CBC with secure IV generation
- Compression: GZIP (50-90% size reduction)
- Key storage: flutter_secure_storage (Android Keystore/iOS Keychain)
- Serialization: JSON with EmergencyPayload model
- Error handling: Result type pattern for safe operations

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


## Testing Strategy (✅ Implemented)

### Unit Testing
- **Framework:** flutter_test with mockito for mocking
- **Coverage Target:** >90% for all services
- **Mock Strategy:**
  - `MockNearbyService`: Mocked for RelayManager tests
  - `MockFlutterSecureStorage`: Mocked for EncryptionLayer tests
  - Real implementations used where possible for integration-like tests

### Test Organization
```
test/
├── core/
│   ├── models/          # Model tests (EmergencyPayload, ConnectionInfo, MeshNetworkConfig)
│   └── services/        # Service tests (all Phase 2-5 services)
│       ├── encryption_layer_test.dart (20 tests)
│       ├── payload_generator_test.dart (23 tests)
│       ├── nearby_service_test.dart (26 tests)
│       ├── payload_validator_test.dart (70 tests)
│       ├── message_queue_test.dart (30 tests)
│       └── relay_manager_test.dart (32 tests)
```

### Test Patterns Used
1. **Arrange-Act-Assert:** Standard test structure
2. **Property-based testing:** Validation rules tested with multiple inputs
3. **Round-trip testing:** Encryption/decryption, serialization/deserialization
4. **Edge case testing:** Boundary values, error conditions
5. **Integration-like testing:** Real services with mocked dependencies

### Mock Generation
```bash
# Generate mocks for testing
dart run build_runner build --delete-conflicting-outputs
```

## Implementation Status

### ✅ Completed Phases (1-5)
- **Phase 1:** Core Infrastructure Setup
- **Phase 2:** Encryption and Security Layer
- **Phase 3:** Location and Payload Generation
- **Phase 4:** Platform-Specific Nearby Service (Android complete, iOS template)
- **Phase 5:** Relay and Message Management

### 🔄 Next Phases (6+)
- **Phase 6:** Connectivity and Uplink (ConnectivityMonitor, ApiClient, Uplink Orchestration)
- **Phase 7:** Permissions and Platform Integration
- **Phase 8:** BLoC State Management Integration
- **Phase 9:** UI Integration and Enhancement
- **Phase 10+:** Backend, Dashboard, Testing, Deployment

### Known Limitations
1. **iOS Implementation:** Requires physical iOS devices for MultipeerConnectivity testing
2. **Processed Message Set:** Grows unbounded - consider periodic cleanup in production
3. **Background Operations:** Android may restrict discovery/scanning frequency
4. **Testing:** Requires physical devices for end-to-end mesh networking tests

### Device Testing Requirements
- **Minimum:** 2 physical Android devices (Android 8+)
- **Recommended:** 3+ devices for multi-hop relay testing
- **Android 12+:** Required for Nearby Devices permission
- **Range:** 10-50 meters typical (Bluetooth/WiFi Direct)
