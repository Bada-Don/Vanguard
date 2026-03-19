import 'dart:async';
import '../models/passive_node_dashboard_model.dart';
import '../../../core/app_export.dart';
import 'package:vanguard_crisis_response/core/services/relay_manager.dart';
import 'package:vanguard_crisis_response/core/services/message_queue.dart';
import 'package:vanguard_crisis_response/core/services/nearby_service.dart';

part 'passive_node_dashboard_event.dart';
part 'passive_node_dashboard_state.dart';

class PassiveNodeDashboardBloc
    extends Bloc<PassiveNodeDashboardEvent, PassiveNodeDashboardState> {
  final RelayManager? relayManager;
  final MessageQueue? messageQueue;
  final NearbyService? nearbyService;
  Timer? _refreshTimer;

  PassiveNodeDashboardBloc(
    PassiveNodeDashboardState initialState, {
    this.relayManager,
    this.messageQueue,
    this.nearbyService,
  }) : super(initialState) {
    on<PassiveNodeDashboardInitialEvent>(_onInitialize);
    on<ToggleSuspendNodeEvent>(_onToggleSuspendNode);
    on<RefreshRelayStatsEvent>(_onRefreshRelayStats);
  }

  _onInitialize(
    PassiveNodeDashboardInitialEvent event,
    Emitter<PassiveNodeDashboardState> emit,
  ) async {
    emit(state.copyWith(passiveNodeDashboardModel: PassiveNodeDashboardModel()));
    // Start periodic refresh of relay stats
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!isClosed) add(RefreshRelayStatsEvent());
    });
    add(RefreshRelayStatsEvent());
  }

  _onRefreshRelayStats(
    RefreshRelayStatsEvent event,
    Emitter<PassiveNodeDashboardState> emit,
  ) async {
    final stats = relayManager?.statistics;
    final queuedCount = messageQueue?.size ?? 0;
    final endpoints = nearbyService?.connectedEndpointsCount ?? 0;

    String? relayTs;
    if (stats?.lastRelayTimestamp != null) {
      final dt = DateTime.fromMillisecondsSinceEpoch(stats!.lastRelayTimestamp! * 1000);
      relayTs = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    }

    String? uplinkTs;
    if (stats?.lastUplinkTimestamp != null) {
      final dt = DateTime.fromMillisecondsSinceEpoch(stats!.lastUplinkTimestamp! * 1000);
      uplinkTs = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    }

    emit(state.copyWith(
      processedMessagesCount: stats?.messagesProcessed ?? state.processedMessagesCount,
      queuedMessagesCount: queuedCount,
      lastRelayTimestamp: relayTs ?? state.lastRelayTimestamp,
      lastUplinkTimestamp: uplinkTs ?? state.lastUplinkTimestamp,
      connectedEndpointsCount: endpoints,
    ));
  }

  _onToggleSuspendNode(
    ToggleSuspendNodeEvent event,
    Emitter<PassiveNodeDashboardState> emit,
  ) async {
    emit(
      state.copyWith(
        passiveNodeDashboardModel: state.passiveNodeDashboardModel?.copyWith(
          isSuspendNodeEnabled: event.value,
        ),
        isRelayModeEnabled: !event.value,
      ),
    );
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
