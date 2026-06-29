import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:modern_learner_production/study/model/note_model.dart';
import 'package:modern_learner_production/study/service/note_service.dart';

part 'note_event.dart';
part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc({required HomeNoteRepository repository})
    : _repository = repository,
      super(const NoteInitial()) {
    on<FetchHomeNotes>(_onFetch);
    on<RefreshHomeNotes>(_onRefresh);
    on<DeleteHomeNote>(_onDelete);
  }

  final HomeNoteRepository _repository;
  String? _currentUserId;

  String? get currentUserId => _currentUserId;

  Future<void> _onFetch(FetchHomeNotes event, Emitter<NoteState> emit) async {
    emit(const NoteLoading());
    await _load(event.userId, emit);
  }

  Future<void> _onRefresh(
    RefreshHomeNotes event,
    Emitter<NoteState> emit,
  ) async {
    await _load(event.userId, emit);
  }

  Future<void> _onDelete(DeleteHomeNote event, Emitter<NoteState> emit) async {
    final current = state;
    if (current is! NoteLoaded) return;

    final previousNotes = current.notes;
    emit(
      NoteLoaded(
        previousNotes
            .where((note) => note.id != event.noteId)
            .toList(growable: false),
      ),
    );

    try {
      await _repository.deleteNote(event.noteId);
    } catch (error) {
      emit(NoteLoaded(previousNotes));
      emit(NoteError('Failed to delete note: $error'));
    }
  }

  Future<void> _load(String userId, Emitter<NoteState> emit) async {
    try {
      _currentUserId = userId;
      final notes = await _repository.fetchNotes(userId);
      emit(NoteLoaded(List.unmodifiable(notes)));
    } catch (error) {
      emit(NoteError('Failed to load notes: $error'));
    }
  }
}

abstract interface class HomeNoteRepository {
  Future<List<NoteModel>> fetchNotes(String userId);

  Future<void> deleteNote(String noteId);
}

final class SupabaseHomeNoteRepository implements HomeNoteRepository {
  const SupabaseHomeNoteRepository(this._service);

  final NoteService _service;

  @override
  Future<List<NoteModel>> fetchNotes(String userId) =>
      _service.fetchNotes(userId);

  @override
  Future<void> deleteNote(String noteId) => _service.deleteNote(noteId);
}
