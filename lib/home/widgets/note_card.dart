import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/home/model/home_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note});

  final NoteItem note;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final accent = Color(note.cardColor);
    final meta = _fileMeta(note.fileType);

    return Container(
      decoration: BoxDecoration(
        color: EduColors.surface,
        borderRadius: EduRadius.borderXl,
        boxShadow: EduColors.shadowCard,
      ),
      padding: const EdgeInsets.all(EduSpacing.s4),
      child: Row(
        children: [
          // ── File type icon block ─────────────────────────────────────
          Container(
            width: 52,
            height: 60,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.25),
              borderRadius: EduRadius.borderMd,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(meta.icon, size: 28, color: meta.iconColor),
                Positioned(
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: meta.iconColor,
                      borderRadius: EduRadius.borderPill,
                    ),
                    child: Text(
                      meta.ext,
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: EduColors.textInverse,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: EduSpacing.s3),

          // ── File info ────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: tt.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Pill(label: note.subject, color: accent),
                    const SizedBox(width: 6),
                    Text(note.fileSize, style: tt.labelMedium),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: EduSpacing.s2),

          // ── Uploaded date + menu ─────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(note.uploadedAt, style: tt.labelMedium),
              const SizedBox(height: 4),
              Icon(Icons.more_horiz_rounded,
                  size: 18, color: EduColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Subject pill ──────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.30),
        borderRadius: EduRadius.borderPill,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: EduColors.textPrimary,
        ),
      ),
    );
  }
}

// ── File type metadata ────────────────────────────────────────────────────────

class _FileMeta {
  const _FileMeta({
    required this.icon,
    required this.iconColor,
    required this.ext,
  });
  final IconData icon;
  final Color iconColor;
  final String ext;
}

_FileMeta _fileMeta(NoteFileType type) {
  switch (type) {
    case NoteFileType.pdf:
      return const _FileMeta(
        icon: Icons.picture_as_pdf_rounded,
        iconColor: Color(0xFFDC2626),
        ext: 'PDF',
      );
    case NoteFileType.image:
      return const _FileMeta(
        icon: Icons.image_rounded,
        iconColor: Color(0xFF0EA5E9),
        ext: 'IMG',
      );
    case NoteFileType.doc:
      return const _FileMeta(
        icon: Icons.article_rounded,
        iconColor: Color(0xFF2563EB),
        ext: 'DOC',
      );
    case NoteFileType.other:
      return const _FileMeta(
        icon: Icons.insert_drive_file_rounded,
        iconColor: Color(0xFF6B7280),
        ext: 'FILE',
      );
  }
}
