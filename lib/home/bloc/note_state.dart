part of 'note_bloc.dart';

@immutable
sealed class NoteState {
  const NoteState();
}

final class NoteInitial extends NoteState {
  const NoteInitial();
}

final class NoteLoading extends NoteState {
  const NoteLoading();
}

final class NoteLoaded extends NoteState {
  const NoteLoaded(this.notes);

  final List<NoteModel> notes;
}

final class NoteError extends NoteState {
  const NoteError(this.message);

  final String message;
}
