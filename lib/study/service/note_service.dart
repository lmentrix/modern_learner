import 'package:modern_learner_production/study/model/note_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NoteService {
  NoteService(this._client);

  final SupabaseClient _client;

  static const _table = 'notes';

  // ── Fetch ──────────────────────────────────────────────────────────────────

  Future<List<NoteModel>> fetchNotes(String userId) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(NoteModel.fromJson)
        .toList();
  }

  Future<NoteModel?> fetchNote(String noteId) async {
    final row = await _client
        .from(_table)
        .select()
        .eq('id', noteId)
        .maybeSingle();

    if (row == null) return null;
    return NoteModel.fromJson(row);
  }

  // ── Create ─────────────────────────────────────────────────────────────────

  Future<NoteModel> createNote({
    required String userId,
    required String title,
    required String subject,
    required String preview,
    required String body,
    int tagColor = 0,
    int readMinutes = 0,
    List<MarkedRangeModel> markedRanges = const [],
  }) async {
    final row = await _client
        .from(_table)
        .insert({
          'user_id': userId,
          'title': title,
          'subject': subject,
          'preview': preview,
          'body': body,
          'tag_color': tagColor,
          'read_minutes': readMinutes,
          'marked_ranges':
              markedRanges.map((r) => r.toJson()).toList(),
        })
        .select()
        .single();

    return NoteModel.fromJson(row);
  }

  // ── Update ─────────────────────────────────────────────────────────────────

  Future<NoteModel> updateNote(
    String noteId,
    Map<String, dynamic> fields,
  ) async {
    final row = await _client
        .from(_table)
        .update(fields)
        .eq('id', noteId)
        .select()
        .single();

    return NoteModel.fromJson(row);
  }

  Future<NoteModel> updateMarkedRanges(
    String noteId,
    List<MarkedRangeModel> ranges,
  ) =>
      updateNote(noteId, {
        'marked_ranges': ranges.map((r) => r.toJson()).toList(),
      });

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> deleteNote(String noteId) async {
    await _client.from(_table).delete().eq('id', noteId);
  }
}
