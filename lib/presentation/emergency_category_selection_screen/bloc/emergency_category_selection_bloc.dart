import 'package:flutter/material.dart';
import '../models/emergency_category_selection_model.dart';
import '../../../core/app_export.dart';

part 'emergency_category_selection_event.dart';
part 'emergency_category_selection_state.dart';

class EmergencyCategorySelectionBloc
    extends
        Bloc<EmergencyCategorySelectionEvent, EmergencyCategorySelectionState> {
  EmergencyCategorySelectionBloc(EmergencyCategorySelectionState initialState)
    : super(initialState) {
    on<EmergencyCategorySelectionInitialEvent>(_onInitialize);
    on<CategorySelectedEvent>(_onCategorySelected);
    on<ConfirmAndBroadcastEvent>(_onConfirmAndBroadcast);
  }

  _onInitialize(
    EmergencyCategorySelectionInitialEvent event,
    Emitter<EmergencyCategorySelectionState> emit,
  ) async {
    emit(
      state.copyWith(
        situationDetailsController: TextEditingController(),
        selectedCategory: null,
        isSubmitSuccess: false,
      ),
    );
  }

  _onCategorySelected(
    CategorySelectedEvent event,
    Emitter<EmergencyCategorySelectionState> emit,
  ) async {
    emit(state.copyWith(selectedCategory: event.category));
  }

  _onConfirmAndBroadcast(
    ConfirmAndBroadcastEvent event,
    Emitter<EmergencyCategorySelectionState> emit,
  ) async {
    if (state.selectedCategory != null) {
      // Save emergency details
      String situationDetails = state.situationDetailsController?.text ?? '';

      // Update model with selected emergency information
      emit(
        state.copyWith(
          emergencyCategorySelectionModel: state.emergencyCategorySelectionModel
              ?.copyWith(
                selectedCategory: state.selectedCategory,
                situationDetails: situationDetails,
              ),
          isSubmitSuccess: true,
        ),
      );
    }
  }
}
