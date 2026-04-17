import 'package:flutter/foundation.dart';

class LessonRefreshNotifier extends ChangeNotifier {
  void notifyLessonsChanged() => notifyListeners();
}
