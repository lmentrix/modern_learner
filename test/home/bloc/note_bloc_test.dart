import 'package:flutter_test/flutter_test.dart';
import 'package:modern_learner_production/home/bloc/note_bloc.dart';
import 'package:modern_learner_production/study/model/note_model.dart';

void main() {
  group('NoteBloc', () {
    test('fetches notes into NoteLoaded state', () async {
      final repository = _FakeNoteRepository(notes: [_guideNote]);
      final bloc = NoteBloc(repository: repository);

      bloc.add(const FetchHomeNotes('user-1'));
      final loaded = await bloc.stream.firstWhere(
        (state) => state is NoteLoaded,
      );

      expect((loaded as NoteLoaded).notes, [_guideNote]);
      expect(bloc.currentUserId, 'user-1');
      await bloc.close();
    });

    test('optimistically removes a deleted note', () async {
      final repository = _FakeNoteRepository(notes: [_guideNote]);
      final bloc = NoteBloc(repository: repository);
      bloc.add(const FetchHomeNotes('user-1'));
      await bloc.stream.firstWhere((state) => state is NoteLoaded);

      bloc.add(const DeleteHomeNote('note-1'));
      final loaded = await bloc.stream.firstWhere(
        (state) => state is NoteLoaded && state.notes.isEmpty,
      );

      expect((loaded as NoteLoaded).notes, isEmpty);
      expect(repository.deletedIds, ['note-1']);
      await bloc.close();
    });

    test('emits NoteError when fetching fails', () async {
      final bloc = NoteBloc(
        repository: _FakeNoteRepository(fetchError: Exception('offline')),
      );

      bloc.add(const FetchHomeNotes('user-1'));
      final error = await bloc.stream.firstWhere((state) => state is NoteError);

      expect((error as NoteError).message, contains('offline'));
      await bloc.close();
    });
  });
}

final _guideNote = NoteModel(
  id: 'note-1',
  userId: 'user-1',
  title: 'Welcome to Modern Learner',
  subject: 'Getting Started',
  preview: 'A quick guide',
  body: 'Guide body',
  tagColor: 0xFFE9D5FF,
  readMinutes: 2,
  markedRanges: const [],
  createdAt: DateTime(2026, 6, 22),
  updatedAt: DateTime(2026, 6, 22),
);

final class _FakeNoteRepository implements HomeNoteRepository {
  _FakeNoteRepository({this.notes = const [], this.fetchError});

  final List<NoteModel> notes;
  final Object? fetchError;
  final List<String> deletedIds = [];

  @override
  Future<void> deleteNote(String noteId) async {
    deletedIds.add(noteId);
  }

  @override
  Future<List<NoteModel>> fetchNotes(String userId) async {
    if (fetchError != null) throw fetchError!;
    return notes;
  }
}
