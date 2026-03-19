import '../models/passive_node_dashboard_model.dart';
import '../../../core/app_export.dart';

part 'passive_node_dashboard_event.dart';
part 'passive_node_dashboard_state.dart';

class PassiveNodeDashboardBloc
    extends Bloc<PassiveNodeDashboardEvent, PassiveNodeDashboardState> {
  PassiveNodeDashboardBloc(PassiveNodeDashboardState initialState)
    : super(initialState) {
    on<PassiveNodeDashboardInitialEvent>(_onInitialize);
    on<ToggleSuspendNodeEvent>(_onToggleSuspendNode);
  }

  _onInitialize(
    PassiveNodeDashboardInitialEvent event,
    Emitter<PassiveNodeDashboardState> emit,
  ) async {
    emit(
      state.copyWith(passiveNodeDashboardModel: PassiveNodeDashboardModel()),
    );
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
      ),
    );
  }
}
