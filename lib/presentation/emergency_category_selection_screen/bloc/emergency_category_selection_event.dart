part of 'emergency_category_selection_bloc.dart';

abstract class EmergencyCategorySelectionEvent extends Equatable {
  EmergencyCategorySelectionEvent();

  @override
  List<Object?> get props => [];
}

class EmergencyCategorySelectionInitialEvent
    extends EmergencyCategorySelectionEvent {}

class CategorySelectedEvent extends EmergencyCategorySelectionEvent {
  final String category;

  CategorySelectedEvent({required this.category});

  @override
  List<Object?> get props => [category];
}

class ConfirmAndBroadcastEvent extends EmergencyCategorySelectionEvent {}
