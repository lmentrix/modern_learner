import 'package:flutter/foundation.dart';

/// Shared state service for progress navigation between features.
/// Used to pass chapter/lesson selection from Home page to Progress page.
class ProgressNavigationState extends ChangeNotifier {
  String? _selectedChapterId;
  String? _selectedLessonId;

  String? get selectedChapterId => _selectedChapterId;
  String? get selectedLessonId => _selectedLessonId;

  bool get hasSelection => _selectedChapterId != null;

  /// Set the chapter to navigate to when Progress page loads
  void navigateToChapter(String chapterId, {String? lessonId}) {
    _selectedChapterId = chapterId;
    _selectedLessonId = lessonId;
    notifyListeners();
  }

  /// Clear the selection after navigation is complete
  void clearSelection() {
    _selectedChapterId = null;
    _selectedLessonId = null;
    notifyListeners();
  }
}
