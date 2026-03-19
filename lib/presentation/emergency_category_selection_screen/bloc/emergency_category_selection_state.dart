part of 'emergency_category_selection_bloc.dart';

class EmergencyCategorySelectionState extends Equatable {
  final TextEditingController? situationDetailsController;
  final String? selectedCategory;
  final bool? isSubmitSuccess;
  final EmergencyCategorySelectionModel? emergencyCategorySelectionModel;

  EmergencyCategorySelectionState({
    this.situationDetailsController,
    this.selectedCategory,
    this.isSubmitSuccess,
    this.emergencyCategorySelectionModel,
  });

  @override
  List<Object?> get props => [
    situationDetailsController,
    selectedCategory,
    isSubmitSuccess,
    emergencyCategorySelectionModel,
  ];

  EmergencyCategorySelectionState copyWith({
    TextEditingController? situationDetailsController,
    String? selectedCategory,
    bool? isSubmitSuccess,
    EmergencyCategorySelectionModel? emergencyCategorySelectionModel,
  }) {
    return EmergencyCategorySelectionState(
      situationDetailsController:
          situationDetailsController ?? this.situationDetailsController,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isSubmitSuccess: isSubmitSuccess ?? this.isSubmitSuccess,
      emergencyCategorySelectionModel:
          emergencyCategorySelectionModel ??
          this.emergencyCategorySelectionModel,
    );
  }
}
