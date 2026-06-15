import 'package:flutter/material.dart';
import 'package:modern_learner_production/profile/section/learning_activity_section.dart';
import 'package:modern_learner_production/profile/section/profile_header_section.dart';
import 'package:modern_learner_production/profile/section/settings_section.dart';
import 'package:modern_learner_production/theme/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  static const _sectionCount = 3;
  static const _staggerMs = 130;
  static const _durationMs = 400;

  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;
  final List<bool> _started = List.filled(_sectionCount, false);

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
      _sectionCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: _durationMs),
      ),
    );
    _fades = _ctrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _slides = _ctrls
        .map((c) => Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();
    _launch();
  }

  void _launch() {
    for (var i = 0; i < _sectionCount; i++) {
      Future.delayed(Duration(milliseconds: _staggerMs * i), () {
        if (!mounted) return;
        setState(() => _started[i] = true);
        _ctrls[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    super.dispose();
  }

  Widget _wrap(int i, Widget child) => FadeTransition(
        opacity: _fades[i],
        child: SlideTransition(position: _slides[i], child: child),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EduColors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  EduSpacing.s6, EduSpacing.s4, EduSpacing.s6, 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Profile',
                        style: Theme.of(context).textTheme.displaySmall),
                    Row(
                      children: [
                        _IconBtn(icon: Icons.notifications_none_rounded, onTap: () {}),
                        const SizedBox(width: EduSpacing.s2),
                        _IconBtn(icon: Icons.edit_outlined, onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: EduSpacing.s6)),

          SliverToBoxAdapter(
            child: _wrap(0, ProfileHeaderSection(animate: _started[0])),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: EduSpacing.s8)),

          SliverToBoxAdapter(
            child: _wrap(1, LearningActivitySection(animate: _started[1])),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: EduSpacing.s8)),

          SliverToBoxAdapter(
            child: _wrap(2, SettingsSection(animate: _started[2])),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: EduColors.surface,
            shape: BoxShape.circle,
            boxShadow: EduColors.shadowCard,
          ),
          child: Icon(icon, color: EduColors.textPrimary, size: 20),
        ),
      );
}
