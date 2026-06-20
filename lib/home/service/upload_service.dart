import 'package:modern_learner_production/home/model/upload_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadService {
  UploadService(this._client);

  final SupabaseClient _client;

  static const _table = 'uploaded_files';

  // ── Fetch ──────────────────────────────────────────────────────────────────

  Future<List<UploadedFileModel>> fetchFiles(String userId) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('uploaded_at', ascending: false);

    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(UploadedFileModel.fromJson)
        .toList();
  }

  Future<UploadedFileModel?> fetchFile(String fileId) async {
    final row = await _client
        .from(_table)
        .select()
        .eq('id', fileId)
        .maybeSingle();

    if (row == null) return null;
    return UploadedFileModel.fromJson(row);
  }

  // ── Create ─────────────────────────────────────────────────────────────────

  Future<UploadedFileModel> createFile({
    required String userId,
    required String title,
    required String subject,
    required UploadFileType fileType,
    required String fileSize,
    String? storagePath,
    String content = '',
    int cardColor = 0,
  }) async {
    final row = await _client
        .from(_table)
        .insert({
          'user_id': userId,
          'title': title,
          'subject': subject,
          'file_type': fileType.value,
          'file_size': fileSize,
          'storage_path': storagePath,
          'content': content,
          'card_color': cardColor,
        })
        .select()
        .single();

    return UploadedFileModel.fromJson(row);
  }

  // ── Update ─────────────────────────────────────────────────────────────────

  Future<UploadedFileModel> updateFile(
    String fileId,
    Map<String, dynamic> fields,
  ) async {
    final row = await _client
        .from(_table)
        .update(fields)
        .eq('id', fileId)
        .select()
        .single();

    return UploadedFileModel.fromJson(row);
  }

  Future<UploadedFileModel> updateContent(String fileId, String content) =>
      updateFile(fileId, {'content': content});

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> deleteFile(String fileId) async {
    await _client.from(_table).delete().eq('id', fileId);
  }
}
