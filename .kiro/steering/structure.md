# Project Structure

## Directory Organization

```
lib/
├── core/                      # Core utilities and shared services
│   ├── config/                # ✅ Configuration (EnvConfig)
│   ├── models/                # ✅ Data models (EmergencyPayload, ConnectionInfo, MeshNetworkConfig)
│   ├── platform/              # ✅ Platform channels (PlatformChannelHandler)
│   ├── services/              # ✅ Core services (Phase 2-5 implementations)
│   │   ├── encryption_layer.dart        # ✅ AES-256-CBC encryption
│   │   ├── payload_generator.dart       # ✅ GPS & payload generation
│   │   ├── nearby_service.dart          # ✅ Unified Nearby API interface
│   │   ├── relay_manager.dart           # ✅ Relay processing pipeline
│   │   ├── message_queue.dart           # ✅ Persistent FIFO queue
│   │   └── payload_validator.dart       # ✅ Comprehensive validation
│   ├── utils/                 # Utility classes (navigation, sizing, images)
│   └── app_export.dart        # Central export file for common imports
├── presentation/              # UI screens (feature-based organization)
│   └── {screen_name}_screen/
│       ├── bloc/              # BLoC state management (bloc, event, state)
│       ├── models/            # Screen-specific models
│       └── {screen_name}_screen.dart
├── routes/                    # Application routing configuration
├── theme/                     # Theme and styling configuration
├── widgets/                   # Reusable UI components
└── main.dart                  # Application entry point

android/
├── app/
│   └── src/main/kotlin/com/vanguard/app/
│       ├── NearbyConnectionsHandler.kt  # ✅ Android Nearby Connections implementation
│       └── MainActivity.kt              # ✅ Platform channel integration

test/
├── core/
│   ├── models/                # ✅ Model tests (42 tests)
│   └── services/              # ✅ Service tests (201 tests)
│       ├── encryption_layer_test.dart
│       ├── payload_generator_test.dart
│       ├── nearby_service_test.dart
│       ├── payload_validator_test.dart
│       ├── message_queue_test.dart
│       └── relay_manager_test.dart
```

## Architecture Patterns

### State Management
- BLoC pattern (flutter_bloc) for all screens
- Each screen has its own bloc directory with:
  - `{screen}_bloc.dart`: Business logic
  - `{screen}_event.dart`: User actions/events
  - `{screen}_state.dart`: UI state with Equatable

### Screen Structure
- Feature-based organization under `presentation/`
- Each screen is self-contained with its own bloc and models
- Static `builder` method for route registration

### Routing
- Centralized in `lib/routes/app_routes.dart`
- Static route constants with snake_case naming
- Route map using `WidgetBuilder` pattern
- Navigator service for programmatic navigation

### Imports
- Use `lib/core/app_export.dart` for common imports (BLoC, Equatable, routing, theme, utils)
- Relative imports for local files within the same feature

### Widgets
- Reusable components in `lib/widgets/`
- Custom prefix for all widgets (CustomButton, CustomImageView, etc.)
- Comprehensive documentation comments with JSDoc-style annotations

## Naming Conventions

- Files: snake_case (e.g., `network_setup_screen.dart`)
- Classes: PascalCase (e.g., `NetworkSetupScreen`)
- Routes: camelCase constants (e.g., `networkSetupScreen`)
- BLoC events: PascalCase with Event suffix (e.g., `ToggleBluetoothEvent`)
- BLoC states: PascalCase with State suffix (e.g., `NetworkSetupState`)

## Asset Management

### Critical Rules (from pubspec.yaml)
- Only use existing asset directories: `assets/` and `assets/images/`
- DO NOT add new asset directories (no `assets/svg/`, `assets/icons/`, etc.)
- Only use existing local fonts from `assets/fonts/` (Public Sans family)
- DO NOT add new local fonts

## Responsive Design

- Use `.h` extension for all dimensions (width, height, padding, margin)
- Use `.fSize` extension for font sizes
- Reference design: 390x907 viewport from Figma
- Sizing handled by `SizeUtils` class

## Critical Configuration

- Portrait-only orientation (locked in `main.dart`)
- Text scaling disabled (locked to 1.0)
- Material Design enabled
- Localization: English only (`en`)

## Mesh Networking Architecture (✅ Phase 1-5 Implemented)

### Implemented Services (Phase 2-5)

#### Phase 2: EncryptionLayer
**Location:** `lib/core/services/encryption_layer.dart`
- AES-256-CBC encryption/decryption
- GZIP compression before encryption
- Secure key storage (flutter_secure_storage)
- Cryptographically secure IV generation
- Result type pattern for error handling
- Key rotation support

#### Phase 3: PayloadGenerator
**Location:** `lib/core/services/payload_generator.dart`
- GPS coordinate collection (high accuracy mode)
- Retry logic: 3 attempts with 2-second delays
- UUID v4 generation for message IDs
- Unix epoch timestamp generation
- Support for 6 emergency types
- Comprehensive error handling

#### Phase 4: NearbyService
**Location:** `lib/core/services/nearby_service.dart`
- Unified cross-platform interface
- Connection state management
- Platform channel integration
- Endpoint tracking
- Payload queue for offline scenarios
- Event streams for state changes and payload reception

**Android Implementation:** `android/app/src/main/kotlin/com/vanguard/app/NearbyConnectionsHandler.kt`
- Google Nearby Connections API (P2P_CLUSTER)
- Auto-accept connections
- Auto-connect to discovered endpoints
- Connection lifecycle management
- Payload handling with event channels

#### Phase 5: RelayManager
**Location:** `lib/core/services/relay_manager.dart`
- Complete relay processing pipeline
- Duplicate prevention (`Set<String> processedMessageIds`)
- Hop count management (configurable max hops)
- Integration with EncryptionLayer, PayloadValidator, NearbyService, MessageQueue
- Statistics tracking and event streams

#### Phase 5: MessageQueue
**Location:** `lib/core/services/message_queue.dart`
- FIFO queue with configurable size (50-200)
- Persistent storage (SharedPreferences)
- Automatic overflow handling
- Query operations (by type, time range)
- Statistics and utilization tracking

#### Phase 5: PayloadValidator
**Location:** `lib/core/services/payload_validator.dart`
- UUID v4 format validation
- Coordinate validation (lat/lng ranges)
- Timestamp validation (within 24 hours)
- Emergency type validation (1-6)
- Hop count validation (non-negative)
- Detailed error messages

### Nearby Devices Integration
- Service-based architecture for advertising and discovery
- Connection lifecycle management with callbacks
- Payload handling with encryption/decryption layer
- Duplicate message prevention using message ID tracking

### Data Flow Pattern
1. Trigger → Payload Generation (GPS, timestamp, emergency type)
2. Advertising/Discovery → Connection establishment
3. Payload transmission → All connected endpoints
4. Reception → Decrypt, validate, relay (if offline)
5. Uplink → Backend upload when internet available

### State Management for Mesh
- Connection state: Track connected endpoints
- Message state: Track processed message IDs (`Set<String>`)
- Hop state: Track and increment hop count
- Network state: Monitor internet availability for uplink trigger

### Permissions & Platform Constraints
- Required permissions: Bluetooth, Location, Nearby Devices (Android 12+)
- Range limitation: 10-50 meters typical
- Background limitations: Android may restrict discovery/scanning
- Not automatic mesh: App must actively manage multi-hop relay
