part of 'note_bloc.dart';

abstract class NoteState extends Equatable {
  const NoteState();
  @override
  List<Object> get props => [];
}

class NoteAbsent extends NoteState {}

class NotePresent extends NoteState {
  final notes;
  NotePresent(this.notes) : assert(notes != null);
  @override
  List<Object> get props => [notes];
}
