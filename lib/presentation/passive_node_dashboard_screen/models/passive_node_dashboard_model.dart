import '../../../core/app_export.dart';

/// This class is used in the [PassiveNodeDashboardScreen] screen.

// ignore_for_file: must_be_immutable
class PassiveNodeDashboardModel extends Equatable {
  PassiveNodeDashboardModel({
    this.relayedPayloads,
    this.payloadGrowth,
    this.uptime,
    this.stability,
    this.energyImpact,
    this.activeNodes,
    this.isSuspendNodeEnabled,
  }) {
    relayedPayloads = relayedPayloads ?? "1,284";
    payloadGrowth = payloadGrowth ?? "+12.4%";
    uptime = uptime ?? "18h 42m";
    stability = stability ?? "99.9% stable";
    energyImpact = energyImpact ?? "24%";
    activeNodes = activeNodes ?? "14 Active Peer Nodes Connected";
    isSuspendNodeEnabled = isSuspendNodeEnabled ?? false;
  }

  String? relayedPayloads;
  String? payloadGrowth;
  String? uptime;
  String? stability;
  String? energyImpact;
  String? activeNodes;
  bool? isSuspendNodeEnabled;

  PassiveNodeDashboardModel copyWith({
    String? relayedPayloads,
    String? payloadGrowth,
    String? uptime,
    String? stability,
    String? energyImpact,
    String? activeNodes,
    bool? isSuspendNodeEnabled,
  }) {
    return PassiveNodeDashboardModel(
      relayedPayloads: relayedPayloads ?? this.relayedPayloads,
      payloadGrowth: payloadGrowth ?? this.payloadGrowth,
      uptime: uptime ?? this.uptime,
      stability: stability ?? this.stability,
      energyImpact: energyImpact ?? this.energyImpact,
      activeNodes: activeNodes ?? this.activeNodes,
      isSuspendNodeEnabled: isSuspendNodeEnabled ?? this.isSuspendNodeEnabled,
    );
  }

  @override
  List<Object?> get props => [
    relayedPayloads,
    payloadGrowth,
    uptime,
    stability,
    energyImpact,
    activeNodes,
    isSuspendNodeEnabled,
  ];
}
