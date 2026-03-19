import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';

/// This class is used in the [emergency_category_selection_screen] screen.

// ignore_for_file: must_be_immutable
class EmergencyCategorySelectionModel extends Equatable {
  EmergencyCategorySelectionModel({
    this.selectedCategory,
    this.situationDetails,
    this.isGpsActive,
    this.stepNumber,
    this.totalSteps,
    this.id,
  }) {
    selectedCategory = selectedCategory ?? '';
    situationDetails = situationDetails ?? '';
    isGpsActive = isGpsActive ?? true;
    stepNumber = stepNumber ?? 2;
    totalSteps = totalSteps ?? 3;
    id = id ?? '';
  }

  String? selectedCategory;
  String? situationDetails;
  bool? isGpsActive;
  int? stepNumber;
  int? totalSteps;
  String? id;

  EmergencyCategorySelectionModel copyWith({
    String? selectedCategory,
    String? situationDetails,
    bool? isGpsActive,
    int? stepNumber,
    int? totalSteps,
    String? id,
  }) {
    return EmergencyCategorySelectionModel(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      situationDetails: situationDetails ?? this.situationDetails,
      isGpsActive: isGpsActive ?? this.isGpsActive,
      stepNumber: stepNumber ?? this.stepNumber,
      totalSteps: totalSteps ?? this.totalSteps,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
    selectedCategory,
    situationDetails,
    isGpsActive,
    stepNumber,
    totalSteps,
    id,
  ];
}
