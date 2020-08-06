part of 'note_bloc.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();
}

class NoteAdded extends NoteEvent {
  final notes;

  NoteAdded(this.notes) : assert(notes != null);

  @override
  List<Object> get props => [notes];
  
}
