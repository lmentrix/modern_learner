import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modern_learner_production/features/explore/domain/usecases/get_all_learning_subjects.dart';
import 'package:modern_learner_production/features/explore/domain/usecases/get_subjects_by_category.dart';
import 'package:modern_learner_production/features/explore/domain/usecases/search_learning_subjects.dart';
import 'package:modern_learner_production/features/explore/presentation/bloc/learning_subjects_event.dart';
import 'package:modern_learner_production/features/explore/presentation/bloc/learning_subjects_state.dart';

class LearningSubjectsBloc
    extends Bloc<LearningSubjectsEvent, LearningSubjectsState> {
  LearningSubjectsBloc({
    required GetAllLearningSubjects getAllSubjects,
    required GetSubjectsByCategory getByCategory,
    required SearchLearningSubjects searchSubjects,
  })  : _getAllSubjects = getAllSubjects,
        _getByCategory = getByCategory,
        _searchSubjects = searchSubjects,
        super(const LearningSubjectsInitial()) {
    on<LoadLearningSubjects>(_onLoad);
    on<FilterByCategory>(_onFilter);
    on<SearchSubjectsEvent>(_onSearch);
  }

  final GetAllLearningSubjects _getAllSubjects;
  final GetSubjectsByCategory _getByCategory;
  final SearchLearningSubjects _searchSubjects;

  Future<void> _onLoad(
    LoadLearningSubjects event,
    Emitter<LearningSubjectsState> emit,
  ) async {
    emit(const LearningSubjectsLoading());
    try {
      final subjects = await _getAllSubjects();
      emit(
        LearningSubjectsLoaded(allSubjects: subjects, displayed: subjects),
      );
    } catch (e) {
      emit(LearningSubjectsError(e.toString()));
    }
  }

  Future<void> _onFilter(
    FilterByCategory event,
    Emitter<LearningSubjectsState> emit,
  ) async {
    final current = state;
    try {
      final filtered = event.category == null
          ? await _getAllSubjects()
          : await _getByCategory(event.category!);
      emit(
        LearningSubjectsLoaded(
          allSubjects: current is LearningSubjectsLoaded
              ? current.allSubjects
              : filtered,
          displayed: filtered,
          activeCategory: event.category,
        ),
      );
    } catch (e) {
      emit(LearningSubjectsError(e.toString()));
    }
  }

  Future<void> _onSearch(
    SearchSubjectsEvent event,
    Emitter<LearningSubjectsState> emit,
  ) async {
    final current = state;
    try {
      final results = await _searchSubjects(event.query);
      emit(
        LearningSubjectsLoaded(
          allSubjects: current is LearningSubjectsLoaded
              ? current.allSubjects
              : results,
          displayed: results,
          activeCategory: current is LearningSubjectsLoaded
              ? current.activeCategory
              : null,
        ),
      );
    } catch (e) {
      emit(LearningSubjectsError(e.toString()));
    }
  }
}
