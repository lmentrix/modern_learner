import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/usecases/complete_node.dart' as domain;
import '../../domain/usecases/get_skill_tree.dart';
import '../../domain/usecases/get_user_progress.dart';
import '../bloc/progress_bloc.dart';
import '../bloc/progress_event.dart';
import '../bloc/progress_state.dart';
import '../widgets/celebration_overlay.dart';
import '../widgets/lesson_path_widget.dart';
import '../widgets/progress_stats_header.dart';
import '../widgets/skill_node_detail_sheet.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  late ProgressBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ProgressBloc(
      getSkillTree: GetSkillTree(getIt()),
      getUserProgress: GetUserProgress(getIt()),
      completeNode: domain.CompleteNode(getIt()),
    );
    _bloc.add(LoadProgress());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Container(
        color: AppColors.surface,
        child: BlocBuilder<ProgressBloc, ProgressState>(
          builder: (context, state) {
            if (state.status == ProgressStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (state.status == ProgressStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load progress',
                      style: GoogleFonts.inter(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _bloc.add(LoadProgress()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state.skillTree == null || state.userProgress == null) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                ProgressStatsHeader(progress: state.userProgress!),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.outlineVariant.withValues(alpha: 0.25),
                ),
                Expanded(
                  child: LessonPathWidget(
                    skillTree: state.skillTree!,
                    selectedNodeId: state.selectedNodeId,
                    onNodeTap: (nodeId) {
                      _bloc.add(SelectNode(nodeId));
                      _showNodeDetail(nodeId, state);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showNodeDetail(String nodeId, ProgressState state) {
    final node = state.skillTree!.nodes.firstWhere((n) => n.id == nodeId);
    final isCompleted = state.userProgress!.completedNodes.containsKey(nodeId);
    final isInProgress = state.userProgress!.nodeProgress.containsKey(nodeId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SkillNodeDetailSheet(
          node: node,
          canClaim: isCompleted && !isInProgress,
          onStart: () {
            Navigator.pop(context);
            _bloc.add(StartNode(nodeId));
            // Navigate to lesson or start interaction
            _showLessonCompleteCelebration();
          },
          onClaim: () {
            Navigator.pop(context);
            _bloc.add(CompleteNodeEvent(nodeId));
            _showLessonCompleteCelebration();
          },
        );
      },
    );
  }

  void _showLessonCompleteCelebration() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return CelebrationOverlay(
          xpGained: 100,
          gemsGained: 12,
          onComplete: () => Navigator.pop(context),
        );
      },
    );
  }
}
