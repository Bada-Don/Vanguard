# Design Document: Production Mesh Emergency System

## Overview

The Production Mesh Emergency System transforms the Vanguard Crisis Response Flutter application into a fully functional emergency communication platform. The system enables peer-to-peer mesh networking using the Nearby Devices API (Android) and MultipeerConnectivity (iOS) to propagate emergency messages through connected devices when traditional network infrastructure is unavailable or compromised.

The architecture follows a distributed relay model where devices automatically discover nearby peers, establish encrypted connections, and relay emergency messages with intelligent hop-count limiting and duplicate prevention. When any device in the mesh gains internet connectivity, it acts as an uplink node to transmit accumulated messages to a centralized backend for emergency services coordination.

### Key Design Goals

- Resilient emergency communication without infrastructure dependency
- Automatic peer discovery and connection management
- Secure end-to-end encrypted message transmission
- Intelligent multi-hop relay with duplicate prevention
- Seamless uplink to backend when connectivity is available
- Real-time dashboard for emergency services coordination
- Cross-platform support (Android/iOS) with unified interface

## Architecture

### System Components

The system consists of three primary subsystems:

1. **Mobile Application Layer** (Flutter)
   - Nearby Service: Manages P2P connections and payload transmission
   - Payload Generator: Creates emergency message payloads
   - Encryption Layer: Handles AES-256 encryption/decryption
   - Relay Manager: Orchestrates message relay logic and duplicate prevention
   - Connectivity Monitor: Tracks internet availability for uplink triggering
   - Permission Manager: Handles runtime permission requests
   - Background Service: Maintains mesh operations when app is backgrounded

2. **Backend API Layer** (REST API)
   - Message Ingestion Endpoint: Receives emergency messages via HTTPS
   - Message Deduplicator: Prevents duplicate message storage
   - Authentication Service: Validates API keys
   - Real-time Event Emitter: Pushes updates to dashboard via WebSocket

3. **Dashboard Layer** (Web Application)
   - Map Visualization: Displays incidents geographically
   - Real-time Updates: Receives new incidents via WebSocket
   - Incident Management: Allows operators to update incident status
   - Filtering and Search: Enables operators to focus on specific incidents

### Architecture Patterns

**Mobile Application:**
- BLoC pattern for state management (flutter_bloc)
- Service-oriented architecture with dependency injection
- Platform channels for native API access (Android Nearby Connections, iOS MultipeerConnectivity)
- Repository pattern for data persistence (shared_preferences)
- Observer pattern for connectivity monitoring

**Backend API:**
- RESTful API design with resource-oriented endpoints
- Middleware chain for authentication, validation, rate limiting
- Event-driven architecture for real-time updates
- Database indexing strategy for efficient deduplication queries

**Communication Flow:**

```
[User Triggers SOS]
       ↓
[Payload Generator] → [Encryption Layer] → [Nearby Service]
       ↓                                           ↓
[GPS + Timestamp]                        [Broadcast to Endpoints]
       ↓                                           ↓
[Message ID + Type]                      [Connected Device 1...N]
                                                   ↓
                                         [Relay Manager receives]
                                                   ↓
                                         [Duplicate Check]
                                                   ↓
                                         [Hop Count < MAX_HOPS?]
                                                   ↓
                                    [No Internet: Relay to peers]
                                    [Internet: Upload to Backend]
                                                   ↓
                                         [Backend API]
                                                   ↓
                                         [Deduplication]
                                                   ↓
                                         [Database Storage]
                                                   ↓
                                         [WebSocket Event]
                                                   ↓
                                         [Dashboard Update]
```

### Deployment Architecture

**Mobile Application:**
- Flutter app compiled to native Android APK and iOS IPA
- Distributed via Google Play Store and Apple App Store
- Configuration via environment-specific build flavors (dev, staging, production)

**Backend API:**
- Containerized deployment using Docker
- Horizontal scaling with load balancer
- PostgreSQL database with replication for high availability
- Redis for WebSocket session management and rate limiting
- HTTPS termination at load balancer with TLS 1.3

**Dashboard:**
- Static web application served via CDN
- WebSocket connection to backend API for real-time updates
- Responsive design for desktop and tablet access

## Components and Interfaces

### Mobile Application Components

#### Nearby Service

**Responsibilities:**
- Start/stop advertising with SERVICE_ID using P2P_CLUSTER strategy
- Start/stop discovery of nearby devices
- Manage connection lifecycle (accept, maintain, disconnect)
- Transmit encrypted payloads to all connected endpoints
- Track connected endpoints list
- Queue payloads when no endpoints are connected

**Interface:**
```dart
class NearbyService {
  // Start advertising and discovery
  Future<void> startMeshNetworking(String userName);
  
  // Stop all operations
  Future<void> stopMeshNetworking();
  
  // Send payload to all connected endpoints
  Future<int> sendPayload(Uint8List encryptedPayload);
  
  // Get current connection state
  Stream<ConnectionState> get connectionStateStream;
  
  // Get connected endpoints count
  int get connectedEndpointsCount;
  
  // Get list of connected endpoint IDs
  List<String> get connectedEndpoints;
}

enum ConnectionState {
  disconnected,
  advertising,
  discovering,
  connected
}
```

**Platform-Specific Implementation:**
- Android: Uses Nearby Connections API via platform channel
- iOS: Uses MultipeerConnectivity framework via platform channel
- Unified Dart interface abstracts platform differences

#### Payload Generator

**Responsibilities:**
- Collect GPS coordinates with high accuracy
- Generate unique Message_ID using UUID v4
- Record timestamp in Unix epoch format
- Include emergency type identifier
- Initialize hop count to zero
- Serialize payload to JSON format
- Validate GPS accuracy and retry if needed

**Interface:**
```dart
class PayloadGenerator {
  // Generate emergency payload
  Future<Result<EmergencyPayload, PayloadError>> generatePayload({
    required EmergencyType emergencyType,
  });
  
  // Validate GPS accuracy
  Future<bool> isGpsAccurate();
}

class EmergencyPayload {
  final String id;           // UUID v4
  final double lat;          // -90 to 90
  final double lng;          // -180 to 180
  final int ts;              // Unix epoch
  final int type;            // 1-6
  final int hop;             // 0 initially
  final double? accuracy;    // GPS accuracy in meters
  
  String toJson();
  factory EmergencyPayload.fromJson(String json);
}

enum EmergencyType {
  medical(1),
  fire(2),
  crime(3),
  naturalDisaster(4),
  accident(5),
  other(6);
  
  final int value;
  const EmergencyType(this.value);
}

enum PayloadError {
  gpsUnavailable,
  gpsInaccurate,
  permissionDenied,
  timeout
}
```

#### Encryption Layer

**Responsibilities:**
- Encrypt JSON payloads using AES-256-CBC
- Decrypt received payloads
- Compress payloads before encryption
- Decompress payloads after decryption
- Manage encryption key securely (Android Keystore / iOS Keychain)
- Generate cryptographically secure initialization vectors

**Interface:**
```dart
class EncryptionLayer {
  // Encrypt and compress payload
  Future<Uint8List> encrypt(String jsonPayload);
  
  // Decrypt and decompress payload
  Future<Result<String, EncryptionError>> decrypt(Uint8List encryptedData);
  
  // Initialize encryption key from secure storage
  Future<void> initializeKey();
}

enum EncryptionError {
  decryptionFailed,
  invalidData,
  keyNotFound,
  decompressionFailed
}
```

#### Relay Manager

**Responsibilities:**
- Receive and decrypt incoming payloads
- Parse and validate JSON structure
- Check for duplicate messages using Message_ID
- Maintain Processed_Messages_Set in memory
- Extract and validate hop count
- Increment hop count for relay
- Re-encrypt and trigger transmission for relay
- Queue messages for uplink when internet is available
- Trigger uplink process when connectivity is detected
- Persist message queue to local storage

**Interface:**
```dart
class RelayManager {
  // Process received payload
  Future<void> processReceivedPayload(Uint8List encryptedPayload);
  
  // Trigger uplink for queued messages
  Future<void> triggerUplink();
  
  // Get queued messages count
  int get queuedMessagesCount;
  
  // Get processed messages count
  int get processedMessagesCount;
  
  // Clear processed messages set (for testing)
  void clearProcessedMessages();
  
  // Load persisted queue on startup
  Future<void> loadPersistedQueue();
}

class MessageQueue {
  final int maxSize;
  final List<EmergencyPayload> _queue;
  
  void enqueue(EmergencyPayload payload);
  EmergencyPayload? dequeue();
  bool get isFull;
  int get size;
  
  Future<void> persist();
  Future<void> load();
}
```

#### Connectivity Monitor

**Responsibilities:**
- Monitor internet connectivity status continuously
- Emit connectivity state change events
- Distinguish between WiFi, cellular, and no connectivity
- Check connectivity at app startup
- Notify Relay Manager of connectivity changes

**Interface:**
```dart
class ConnectivityMonitor {
  // Get connectivity state stream
  Stream<ConnectivityStatus> get connectivityStream;
  
  // Check current connectivity
  Future<ConnectivityStatus> checkConnectivity();
  
  // Start monitoring
  void startMonitoring();
  
  // Stop monitoring
  void stopMonitoring();
}

enum ConnectivityStatus {
  none,
  wifi,
  cellular,
  ethernet
}
```

#### Permission Manager

**Responsibilities:**
- Check permission status for Bluetooth, Location, Nearby Devices
- Request permissions from user
- Handle permission denial with explanation dialogs
- Provide navigation to app settings for permanently denied permissions
- Re-check permissions when app returns from background
- Handle platform-specific permission differences (Android 12+ Nearby Devices)

**Interface:**
```dart
class PermissionManager {
  // Check all required permissions
  Future<PermissionStatus> checkAllPermissions();
  
  // Request missing permissions
  Future<PermissionStatus> requestPermissions();
  
  // Open app settings
  Future<void> openAppSettings();
  
  // Check if permissions are granted
  bool get arePermissionsGranted;
}

enum PermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted
}
```

#### Background Service

**Responsibilities:**
- Register foreground service on Android with persistent notification
- Use iOS background modes for location and Bluetooth
- Maintain Nearby Service operations while app is backgrounded
- Handle system-initiated termination gracefully
- Request exemption from battery optimization
- Reduce scan frequency in low battery mode
- Stop operations when app is terminated by user

**Interface:**
```dart
class BackgroundService {
  // Start background service
  Future<void> start();
  
  // Stop background service
  Future<void> stop();
  
  // Check if service is running
  bool get isRunning;
  
  // Handle low battery mode
  void onLowBatteryMode(bool enabled);
}
```

### Backend API Components

#### Message Ingestion Endpoint

**Responsibilities:**
- Expose POST /api/v1/emergency/sos endpoint
- Validate request body structure and field values
- Authenticate requests using API key
- Rate limit requests (100 per minute per IP)
- Pass validated messages to Message Deduplicator
- Return appropriate HTTP status codes

**Interface:**
```typescript
// POST /api/v1/emergency/sos
interface EmergencySosRequest {
  id: string;        // UUID
  lat: number;       // -90 to 90
  lng: number;       // -180 to 180
  ts: number;        // Unix epoch
  type: number;      // 1-6
  hop: number;       // >= 0
  accuracy?: number; // GPS accuracy in meters
}

interface EmergencySosResponse {
  success: boolean;
  messageId: string;
  message: string;
}

// Middleware chain
app.post('/api/v1/emergency/sos',
  authenticationMiddleware,
  rateLimitMiddleware,
  validationMiddleware,
  emergencySosHandler
);
```

#### Message Deduplicator

**Responsibilities:**
- Check for existing message by Message_ID
- Check for spatial-temporal duplicates (same location + time within 60s)
- Return existing message if duplicate found
- Store new message if no duplicates found
- Use database indexes for efficient lookups

**Interface:**
```typescript
class MessageDeduplicator {
  async processMessage(payload: EmergencySosRequest): Promise<EmergencyMessage> {
    // Check by message ID
    const existingById = await this.findByMessageId(payload.id);
    if (existingById) return existingById;
    
    // Check by location and time
    const existingByLocation = await this.findByLocationAndTime(
      payload.lat,
      payload.lng,
      payload.ts
    );
    if (existingByLocation) return existingByLocation;
    
    // Store new message
    return await this.storeMessage(payload);
  }
}
```

#### Authentication Service

**Responsibilities:**
- Validate API keys from Authorization header
- Query database for authorized keys
- Log authentication attempts
- Support multiple API keys for different clients
- Support API key rotation
- Rate limit failed authentication attempts

**Interface:**
```typescript
class AuthenticationService {
  async validateApiKey(apiKey: string, clientIp: string): Promise<boolean>;
  async logAuthAttempt(apiKey: string, clientIp: string, success: boolean): Promise<void>;
  async rotateApiKey(oldKey: string, newKey: string): Promise<void>;
}
```

#### Real-time Event Emitter

**Responsibilities:**
- Maintain WebSocket connections to dashboard clients
- Emit events when new messages are stored
- Handle client disconnections and reconnections
- Broadcast incident status updates to all connected clients

**Interface:**
```typescript
class RealtimeEventEmitter {
  emitNewIncident(incident: EmergencyMessage): void;
  emitStatusUpdate(incidentId: string, status: IncidentStatus): void;
  getConnectedClientsCount(): number;
}

interface IncidentEvent {
  type: 'new_incident' | 'status_update';
  data: EmergencyMessage | StatusUpdate;
  timestamp: number;
}
```

### Dashboard Components

#### Map Visualization

**Responsibilities:**
- Render map using mapping library (Mapbox/Google Maps/OpenStreetMap)
- Display incident markers at GPS coordinates
- Color-code markers by emergency type
- Show popup with incident details on marker click
- Support zoom, pan, and clustering
- Filter markers by type, status, and time range

**Interface:**
```typescript
class MapVisualization {
  renderIncidents(incidents: EmergencyMessage[]): void;
  filterByType(types: EmergencyType[]): void;
  filterByStatus(statuses: IncidentStatus[]): void;
  filterByTimeRange(start: Date, end: Date): void;
  focusOnIncident(incidentId: string): void;
}
```

#### Real-time Updates Handler

**Responsibilities:**
- Establish WebSocket connection to backend
- Handle incoming incident events
- Display notifications for new incidents
- Update map visualization with new markers
- Reconnect automatically on disconnection
- Display connection status indicator

**Interface:**
```typescript
class RealtimeUpdatesHandler {
  connect(url: string, authToken: string): void;
  disconnect(): void;
  onNewIncident(callback: (incident: EmergencyMessage) => void): void;
  onStatusUpdate(callback: (update: StatusUpdate) => void): void;
  getConnectionStatus(): ConnectionStatus;
}
```

#### Incident Management

**Responsibilities:**
- Display incident details
- Provide status change buttons (acknowledged, resolved, false_alarm)
- Update database via API when status changes
- Display operator username and timestamp for status changes
- Require operator authentication
- Log status changes for audit

**Interface:**
```typescript
class IncidentManagement {
  async updateStatus(
    incidentId: string,
    newStatus: IncidentStatus,
    operatorId: string
  ): Promise<void>;
  
  async getIncidentHistory(incidentId: string): Promise<StatusChange[]>;
}

interface StatusChange {
  status: IncidentStatus;
  operatorId: string;
  operatorName: string;
  timestamp: Date;
}
```

## Data Models

### Mobile Application Data Models

#### EmergencyPayload
```dart
class EmergencyPayload extends Equatable {
  final String id;           // UUID v4 format
  final double lat;          // Latitude: -90 to 90
  final double lng;          // Longitude: -180 to 180
  final int ts;              // Unix epoch timestamp
  final int type;            // Emergency type: 1-6
  final int hop;             // Hop count: >= 0
  final double? accuracy;    // GPS accuracy in meters (optional)
  
  const EmergencyPayload({
    required this.id,
    required this.lat,
    required this.lng,
    required this.ts,
    required this.type,
    required this.hop,
    this.accuracy,
  });
  
  // JSON serialization
  Map<String, dynamic> toJson() => {
    'id': id,
    'lat': lat,
    'lng': lng,
    'ts': ts,
    'type': type,
    'hop': hop,
    if (accuracy != null) 'accuracy': accuracy,
  };
  
  factory EmergencyPayload.fromJson(Map<String, dynamic> json) =>
    EmergencyPayload(
      id: json['id'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      ts: json['ts'] as int,
      type: json['type'] as int,
      hop: json['hop'] as int,
      accuracy: json['accuracy'] != null 
        ? (json['accuracy'] as num).toDouble() 
        : null,
    );
  
  // Create copy with updated hop count
  EmergencyPayload incrementHop() => EmergencyPayload(
    id: id,
    lat: lat,
    lng: lng,
    ts: ts,
    type: type,
    hop: hop + 1,
    accuracy: accuracy,
  );
  
  @override
  List<Object?> get props => [id, lat, lng, ts, type, hop, accuracy];
}
```

#### ConnectionInfo
```dart
class ConnectionInfo extends Equatable {
  final String endpointId;
  final String endpointName;
  final DateTime connectedAt;
  final ConnectionStatus status;
  
  const ConnectionInfo({
    required this.endpointId,
    required this.endpointName,
    required this.connectedAt,
    required this.status,
  });
  
  @override
  List<Object> get props => [endpointId, endpointName, connectedAt, status];
}

enum ConnectionStatus {
  connecting,
  connected,
  disconnected,
  failed
}
```

#### MeshNetworkConfig
```dart
class MeshNetworkConfig extends Equatable {
  final int maxHops;              // 3-5
  final int messageQueueSize;     // 50-200
  final int uplinkRetryAttempts;  // 1-5
  final int connectionTimeout;    // 10-60 seconds
  
  const MeshNetworkConfig({
    this.maxHops = 3,
    this.messageQueueSize = 100,
    this.uplinkRetryAttempts = 3,
    this.connectionTimeout = 30,
  });
  
  // Validation
  bool get isValid =>
    maxHops >= 3 && maxHops <= 5 &&
    messageQueueSize >= 50 && messageQueueSize <= 200 &&
    uplinkRetryAttempts >= 1 && uplinkRetryAttempts <= 5 &&
    connectionTimeout >= 10 && connectionTimeout <= 60;
  
  // Persistence
  Map<String, dynamic> toJson() => {
    'maxHops': maxHops,
    'messageQueueSize': messageQueueSize,
    'uplinkRetryAttempts': uplinkRetryAttempts,
    'connectionTimeout': connectionTimeout,
  };
  
  factory MeshNetworkConfig.fromJson(Map<String, dynamic> json) =>
    MeshNetworkConfig(
      maxHops: json['maxHops'] as int,
      messageQueueSize: json['messageQueueSize'] as int,
      uplinkRetryAttempts: json['uplinkRetryAttempts'] as int,
      connectionTimeout: json['connectionTimeout'] as int,
    );
  
  // Default configuration
  static const MeshNetworkConfig defaultConfig = MeshNetworkConfig();
  
  @override
  List<Object> get props => [
    maxHops,
    messageQueueSize,
    uplinkRetryAttempts,
    connectionTimeout,
  ];
}
```

### Backend Data Models

#### Database Schema: emergency_messages

```sql
CREATE TABLE emergency_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID NOT NULL UNIQUE,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  timestamp BIGINT NOT NULL,
  emergency_type INTEGER NOT NULL CHECK (emergency_type BETWEEN 1 AND 6),
  hop_count INTEGER NOT NULL CHECK (hop_count >= 0),
  gps_accuracy DECIMAL(10, 2),
  received_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(20) NOT NULL DEFAULT 'pending' 
    CHECK (status IN ('pending', 'acknowledged', 'resolved', 'false_alarm')),
  
  -- Indexes for efficient queries
  CONSTRAINT valid_latitude CHECK (latitude BETWEEN -90 AND 90),
  CONSTRAINT valid_longitude CHECK (longitude BETWEEN -180 AND 180)
);

-- Index for message ID uniqueness and lookup
CREATE UNIQUE INDEX idx_message_id ON emergency_messages(message_id);

-- Composite index for spatial-temporal deduplication
CREATE INDEX idx_location_time ON emergency_messages(latitude, longitude, timestamp);

-- Index for time-based queries
CREATE INDEX idx_received_at ON emergency_messages(received_at DESC);

-- Index for status filtering
CREATE INDEX idx_status ON emergency_messages(status);

-- Index for emergency type filtering
CREATE INDEX idx_emergency_type ON emergency_messages(emergency_type);
```

#### TypeScript Interface: EmergencyMessage

```typescript
interface EmergencyMessage {
  id: string;              // Database UUID
  messageId: string;       // Message UUID from payload
  latitude: number;        // -90 to 90
  longitude: number;       // -180 to 180
  timestamp: number;       // Unix epoch
  emergencyType: number;   // 1-6
  hopCount: number;        // >= 0
  gpsAccuracy?: number;    // Meters
  receivedAt: Date;        // Server timestamp
  status: IncidentStatus;  // Current status
}

enum IncidentStatus {
  PENDING = 'pending',
  ACKNOWLEDGED = 'acknowledged',
  RESOLVED = 'resolved',
  FALSE_ALARM = 'false_alarm'
}

// Emergency type mapping
const EMERGENCY_TYPES = {
  1: 'Medical',
  2: 'Fire',
  3: 'Crime',
  4: 'Natural Disaster',
  5: 'Accident',
  6: 'Other'
} as const;
```

#### Database Schema: api_keys

```sql
CREATE TABLE api_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key_hash VARCHAR(64) NOT NULL UNIQUE,  -- SHA-256 hash
  client_name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP,
  is_active BOOLEAN NOT NULL DEFAULT true,
  last_used_at TIMESTAMP,
  
  -- Index for key lookup
  CREATE INDEX idx_key_hash ON api_keys(key_hash) WHERE is_active = true
);
```

#### Database Schema: auth_attempts

```sql
CREATE TABLE auth_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_ip VARCHAR(45) NOT NULL,  -- IPv6 compatible
  api_key_hash VARCHAR(64),
  success BOOLEAN NOT NULL,
  attempted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Index for rate limiting queries
  CREATE INDEX idx_client_ip_time ON auth_attempts(client_ip, attempted_at DESC)
);
```

#### Database Schema: status_changes

```sql
CREATE TABLE status_changes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID NOT NULL REFERENCES emergency_messages(id),
  old_status VARCHAR(20) NOT NULL,
  new_status VARCHAR(20) NOT NULL,
  operator_id UUID NOT NULL,
  operator_name VARCHAR(255) NOT NULL,
  changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  notes TEXT,
  
  -- Index for incident history queries
  CREATE INDEX idx_message_status_changes ON status_changes(message_id, changed_at DESC)
);
```

### Configuration Data Models

#### Environment Configuration

```json
{
  "development": {
    "apiBaseUrl": "http://localhost:3000/api/v1",
    "wsUrl": "ws://localhost:3000",
    "apiKey": "dev_key_12345",
    "serviceId": "com.vanguard.crisis.dev",
    "logLevel": "DEBUG"
  },
  "staging": {
    "apiBaseUrl": "https://staging-api.vanguard-crisis.com/api/v1",
    "wsUrl": "wss://staging-api.vanguard-crisis.com",
    "apiKey": "staging_key_67890",
    "serviceId": "com.vanguard.crisis.staging",
    "logLevel": "INFO"
  },
  "production": {
    "apiBaseUrl": "https://api.vanguard-crisis.com/api/v1",
    "wsUrl": "wss://api.vanguard-crisis.com",
    "apiKey": "${PROD_API_KEY}",
    "serviceId": "com.vanguard.crisis",
    "logLevel": "WARNING"
  }
}
```

