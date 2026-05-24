import 'package:flutter/widgets.dart';

import 'package:modern_learner_production/features/profile/service/learning_activity_service.dart';

class LearningActivityScope extends StatefulWidget {
  const LearningActivityScope({super.key, required this.child});

  final Widget child;

  @override
  State<LearningActivityScope> createState() => _LearningActivityScopeState();
}

class _LearningActivityScopeState extends State<LearningActivityScope> {
  final _service = LearningActivityService.instance;

  @override
  void initState() {
    super.initState();
    _service.beginLearningSession();
  }

  @override
  void dispose() {
    _service.endLearningSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _service.markInteraction(),
      onPointerMove: (_) => _service.markInteraction(),
      onPointerSignal: (_) => _service.markInteraction(),
      child: widget.child,
    );
  }
}
