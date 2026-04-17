import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:modern_learner_production/core/constants/api_constants.dart';
import 'package:modern_learner_production/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:modern_learner_production/features/home/presentation/bloc/achievement_bloc.dart';
import 'package:modern_learner_production/features/home/service/lesson_refresh_notifier.dart';
import 'package:modern_learner_production/features/profile/domain/repositories/profile_repository.dart';
import 'package:modern_learner_production/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:modern_learner_production/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:modern_learner_production/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:modern_learner_production/features/profile/service/data/profile_remote_data_source.dart';
import 'package:modern_learner_production/features/profile/service/data/profile_remote_data_source_impl.dart';
import 'package:modern_learner_production/features/profile/service/data/profile_repository_impl.dart';
import 'package:modern_learner_production/features/new_lesson/data/repositories/lesson_repository_impl.dart';
import 'package:modern_learner_production/features/new_lesson/domain/repositories/lesson_repository.dart';
import 'package:modern_learner_production/features/new_lesson/domain/usecases/create_lesson.dart';
import 'package:modern_learner_production/features/new_lesson/domain/usecases/delete_lesson.dart';
import 'package:modern_learner_production/features/new_lesson/domain/usecases/get_lesson.dart';
import 'package:modern_learner_production/features/new_lesson/domain/usecases/get_lessons.dart';
import 'package:modern_learner_production/features/new_lesson/domain/usecases/update_lesson.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/lesson_detail/service/voice_lesson_generation_service.dart';
import 'package:modern_learner_production/features/lesson_detail/service/voice_lesson_supabase_service.dart';
import 'package:modern_learner_production/features/progress/service/chapter_content_service.dart';
import 'package:modern_learner_production/features/progress/service/lesson_content_service.dart';
import 'package:modern_learner_production/features/progress/service/progress_navigation_state.dart';
import 'package:modern_learner_production/features/progress/service/roadmap_generation_service.dart';
import 'package:modern_learner_production/features/progress/service/user_courses_service.dart';
import 'package:modern_learner_production/features/progress/service/user_progress_service.dart';
import 'package:modern_learner_production/features/progress/data/repositories/progress_repository_impl.dart';
import 'package:modern_learner_production/features/progress/domain/repositories/progress_repository.dart';
import 'package:modern_learner_production/core/network/network_info.dart';
import 'package:modern_learner_production/core/di/injection.config.dart';
import 'package:modern_learner_production/features/explore/data/datasources/learning_subject_local_datasource.dart';
import 'package:modern_learner_production/features/explore/data/repositories/learning_subject_repository_impl.dart';
import 'package:modern_learner_production/features/explore/domain/repositories/learning_subject_repository.dart';
import 'package:modern_learner_production/features/explore/domain/usecases/get_all_learning_subjects.dart';
import 'package:modern_learner_production/features/explore/domain/usecases/get_subjects_by_category.dart';
import 'package:modern_learner_production/features/explore/domain/usecases/search_learning_subjects.dart';
import 'package:modern_learner_production/features/explore/presentation/bloc/learning_subjects_bloc.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  getIt.init();

  // ── Core ──────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<InternetConnection>(() => InternetConnection());
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));

  // ── Auth ──────────────────────────────────────────────────────────────────
  // Eager singleton — constructed immediately so it is always available before
  // App.build() runs, regardless of Dart's lazy-initialisation caching.
  getIt.registerSingleton<AuthBloc>(AuthBloc());

  // ── Profile ───────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton(() => GetProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateProfileUseCase(getIt()));
  getIt.registerFactory(() => ProfileBloc(getIt(), getIt()));

  // ── Progress services ─────────────────────────────────────────────────────
  getIt.registerSingleton<UserProgressService>(
    UserProgressService(supabase: getIt<SupabaseClient>()),
  );
  getIt.registerSingleton<UserCoursesService>(
    UserCoursesService(supabase: getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton(() => LessonRefreshNotifier());

  // ── Progress ──────────────────────────────────────────────────────────────
  getIt.registerSingletonAsync<SharedPreferences>(
    () => SharedPreferences.getInstance(),
  );
  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
      ),
    ),
  );
  getIt.registerSingletonAsync<ChapterContentService>(
    () async => ChapterContentService(
      dio: getIt<Dio>(),
      prefs: await getIt.getAsync<SharedPreferences>(),
    ),
    dependsOn: [SharedPreferences],
  );
  getIt.registerSingletonAsync<LessonContentService>(
    () async => LessonContentService(
      dio: getIt<Dio>(),
      prefs: await getIt.getAsync<SharedPreferences>(),
    ),
    dependsOn: [SharedPreferences],
  );
  getIt.registerSingletonAsync<RoadmapGenerationService>(
    () async => RoadmapGenerationService(
      dio: getIt<Dio>(),
      prefs: await getIt.getAsync<SharedPreferences>(),
    ),
    dependsOn: [SharedPreferences],
  );
  getIt.registerSingletonAsync<ProgressRepository>(
    () async => ProgressRepositoryImpl(
      supabase: getIt<SupabaseClient>(),
      roadmapService: await getIt.getAsync<RoadmapGenerationService>(),
      chapterContentService: await getIt.getAsync<ChapterContentService>(),
      lessonContentService: await getIt.getAsync<LessonContentService>(),
      userProgressService: getIt<UserProgressService>(),
    ),
    dependsOn: [
      RoadmapGenerationService,
      ChapterContentService,
      LessonContentService,
    ],
  );
  getIt.registerLazySingleton(() => ProgressNavigationState());

  // Wire UserCoursesService into the ExploreCoursesService singleton.
  ExploreCoursesService.instance.injectRemote(getIt<UserCoursesService>());

  // ── Achievement ───────────────────────────────────────────────────────────
  // Registered AFTER ProgressRepository so dependsOn resolves correctly.
  // Singleton (not factory) so the stream subscription persists app-wide.
  getIt.registerSingletonAsync<AchievementBloc>(
    () async => AchievementBloc(
      progressRepository: await getIt.getAsync<ProgressRepository>(),
    ),
    dependsOn: [ProgressRepository],
  );

  // ── Voice Lesson ──────────────────────────────────────────────────────────
  getIt.registerSingleton<VoiceLessonSupabaseService>(
    VoiceLessonSupabaseService(supabase: getIt<SupabaseClient>()),
  );
  getIt.registerSingletonAsync<VoiceLessonGenerationService>(
    () async => VoiceLessonGenerationService(
      dio: getIt<Dio>(),
      prefs: await getIt.getAsync<SharedPreferences>(),
    ),
    dependsOn: [SharedPreferences],
  );

  // ── New Lesson ────────────────────────────────────────────────────────────
  getIt.registerSingletonAsync<LessonRepository>(
    () async => LessonRepositoryImpl(
      getIt<SupabaseClient>(),
      getIt<RoadmapGenerationService>(),
      await getIt.getAsync<VoiceLessonGenerationService>(),
    ),
    dependsOn: [RoadmapGenerationService, VoiceLessonGenerationService],
  );
  getIt.registerSingletonAsync(
    () async => CreateLesson(await getIt.getAsync<LessonRepository>()),
    dependsOn: [LessonRepository],
  );
  getIt.registerSingletonAsync(
    () async => GetLessons(await getIt.getAsync<LessonRepository>()),
    dependsOn: [LessonRepository],
  );
  getIt.registerSingletonAsync(
    () async => GetLesson(await getIt.getAsync<LessonRepository>()),
    dependsOn: [LessonRepository],
  );
  getIt.registerSingletonAsync(
    () async => UpdateLesson(await getIt.getAsync<LessonRepository>()),
    dependsOn: [LessonRepository],
  );
  getIt.registerSingletonAsync(
    () async => DeleteLesson(await getIt.getAsync<LessonRepository>()),
    dependsOn: [LessonRepository],
  );

  // ── Learning Subjects (Explore) ───────────────────────────────────────────
  getIt.registerLazySingleton<LearningSubjectLocalDatasource>(
    () => LearningSubjectLocalDatasourceImpl(),
  );
  getIt.registerLazySingleton<LearningSubjectRepository>(
    () => LearningSubjectRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetAllLearningSubjects(getIt()));
  getIt.registerLazySingleton(() => GetSubjectsByCategory(getIt()));
  getIt.registerLazySingleton(() => SearchLearningSubjects(getIt()));
  getIt.registerFactory(
    () => LearningSubjectsBloc(
      getAllSubjects: getIt(),
      getByCategory: getIt(),
      searchSubjects: getIt(),
    ),
  );
}
