part of 'note_bloc.dart';

@immutable
sealed class NoteEvent {
  const NoteEvent();
}

final class FetchHomeNotes extends NoteEvent {
  const FetchHomeNotes(this.userId);

  final String userId;
}

final class RefreshHomeNotes extends NoteEvent {
  const RefreshHomeNotes(this.userId);

  final String userId;
}

final class DeleteHomeNote extends NoteEvent {
  const DeleteHomeNote(this.noteId);

  final String noteId;
}
