part of 'note_bloc.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();
}

class NoteAdded extends NoteEvent {
  final notes;

  NoteAdded(this.notes);

  @override
  List<Object> get props => [notes];
  
}
