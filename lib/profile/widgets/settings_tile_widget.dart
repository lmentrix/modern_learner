import 'package:flutter/material.dart';
import 'package:modern_learner_production/profile/model/profile_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

class SettingsTileWidget extends StatefulWidget {
  const SettingsTileWidget({super.key, required this.tile, this.onTap});

  final SettingsTile tile;
  final VoidCallback? onTap;

  @override
  State<SettingsTileWidget> createState() => _SettingsTileWidgetState();
}

class _SettingsTileWidgetState extends State<SettingsTileWidget> {
  late bool _toggled;

  @override
  void initState() {
    super.initState();
    _toggled = widget.tile.toggleValue;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final tile = widget.tile;
    final color = tile.isDestructive ? const Color(0xFFDC2626) : EduColors.textPrimary;

    return GestureDetector(
      onTap: tile.hasToggle
          ? () => setState(() => _toggled = !_toggled)
          : widget.onTap ?? () {},
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: EduSpacing.s5, vertical: EduSpacing.s3),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tile.isDestructive
                    ? const Color(0xFFDC2626).withValues(alpha: 0.08)
                    : EduColors.bg,
                borderRadius: EduRadius.borderMd,
              ),
              child: Icon(
                IconData(tile.icon, fontFamily: 'MaterialIcons'),
                size: 18,
                color: color,
              ),
            ),
            const SizedBox(width: EduSpacing.s3),

            // Label
            Expanded(
              child: Text(
                tile.label,
                style: tt.bodyLarge?.copyWith(
                  color: color,
                  fontWeight: tile.isDestructive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),

            // Trailing
            if (tile.hasToggle)
              Switch(
                value: _toggled,
                onChanged: (v) => setState(() => _toggled = v),
                activeColor: EduColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
            else if (tile.value != null)
              Text(tile.value!, style: tt.bodyMedium?.copyWith(color: EduColors.primary))
            else if (!tile.isDestructive)
              const Icon(Icons.chevron_right_rounded,
                  color: EduColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
