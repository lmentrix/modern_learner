import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:modern_learner_production/features/progress/data/models/user_progress_model.dart';
import 'package:modern_learner_production/features/progress/domain/entities/user_progress.dart';

/// Handles Supabase persistence for the `user_progress` table.
///
/// All methods are safe to call when the user is unauthenticated — they return
/// `null` / no-op in that case and never throw to the caller.
class UserProgressService {
  const UserProgressService({required this.supabase});

  final SupabaseClient supabase;

  String? get _uid => supabase.auth.currentUser?.id;

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Returns the persisted [UserProgress] for the current user, or `null`
  /// if no row exists yet or the user is not authenticated.
  Future<UserProgress?> fetchProgress() async {
    final uid = _uid;
    if (uid == null) return null;
    try {
      final row = await supabase
          .from('user_progress')
          .select()
          .eq('user_id', uid)
          .maybeSingle();
      if (row == null) return null;
      return UserProgressModel.fromRow(row).toEntity();
    } catch (_) {
      return null;
    }
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  /// Upserts [progress] to the database (conflict key: `user_id`).
  ///
  /// Fire-and-forget: awaiting is optional. Errors are silently swallowed so
  /// they never interrupt the in-memory update flow.
  Future<void> saveProgress(UserProgress progress) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await supabase.from('user_progress').upsert(
        UserProgressModel.fromEntity(progress).toRow(uid),
        onConflict: 'user_id',
      );
    } catch (_) {}
  }
}
