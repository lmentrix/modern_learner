import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:modern_learner_production/core/di/injection.config.dart';
import 'package:modern_learner_production/core/network/network_info.dart';
import 'package:modern_learner_production/core/profile/local_profile_service.dart';
import 'package:modern_learner_production/core/state/progress_navigation_state.dart';
import 'package:modern_learner_production/features/auth/model/auth_user_model.dart';
import 'package:modern_learner_production/features/auth/service/auth_service.dart';
import 'package:modern_learner_production/features/explore/data/datasources/learning_subject_local_datasource.dart';
import 'package:modern_learner_production/features/explore/data/repositories/learning_subject_repository_impl.dart';
import 'package:modern_learner_production/features/explore/domain/repositories/learning_subject_repository.dart';
import 'package:modern_learner_production/features/explore/domain/usecases/get_all_learning_subjects.dart';
import 'package:modern_learner_production/features/explore/domain/usecases/get_subjects_by_category.dart';
import 'package:modern_learner_production/features/explore/domain/usecases/search_learning_subjects.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/explore/service/user_courses_service.dart';
import 'package:modern_learner_production/features/explore/view/bloc/learning_subjects_bloc.dart';
import 'package:modern_learner_production/features/profile/service/profile_service.dart';
import 'package:modern_learner_production/features/profile/view/bloc/profile_bloc.dart';
import 'package:modern_learner_production/features/progress/bloc/xp_bloc.dart';
import 'package:modern_learner_production/features/progress/service/course_xp_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  await getIt.init();

  final sharedPreferences = await SharedPreferences.getInstance();

  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerLazySingleton<InternetConnection>(() => InternetConnection());
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));
  getIt.registerLazySingleton<ProfileService>(() => ProfileService());

  final currentUser = AuthService.instance.currentUser;
  final userId = currentUser?.id ?? '';
  final supabaseName = currentUser?.displayName ?? '';
  final supabaseEmail = currentUser?.email ?? '';

  CourseXpService.instance.inject(sharedPreferences, userId: userId);
  getIt.registerFactoryParam<XpBloc, String, void>(
    (courseKey, _) => XpBloc(courseKey: courseKey),
  );
  getIt.registerFactory(() => ProfileBloc(getIt()));

  final localProfileService = LocalProfileService(
    sharedPreferences: sharedPreferences,
    profileService: getIt<ProfileService>(),
    supabaseName: supabaseName,
    supabaseEmail: supabaseEmail,
  );
  getIt.registerSingleton<LocalProfileService>(localProfileService);

  final userCoursesService = UserCoursesService(
    sharedPreferences: sharedPreferences,
    userId: userId,
  );
  getIt.registerSingleton<UserCoursesService>(userCoursesService);
  getIt.registerLazySingleton(() => ProgressNavigationState());

  ExploreCoursesService.instance.injectRemote(getIt<UserCoursesService>());
  await ExploreCoursesService.instance.loadCourses();

  // Re-initialize user-scoped storage whenever the auth user changes.
  AuthService.instance.authStateChanges.listen((authState) async {
    final user = authState.session?.user;
    final newUserId = user?.id ?? '';
    final newName = user == null
        ? ''
        : (AuthUserModel.fromSupabase(user).displayName ?? '');
    final newEmail = user?.email ?? '';

    getIt<LocalProfileService>().seedFromSupabase(
      name: newName,
      email: newEmail,
    );
    CourseXpService.instance.inject(sharedPreferences, userId: newUserId);
    final newUserCoursesService = UserCoursesService(
      sharedPreferences: sharedPreferences,
      userId: newUserId,
    );
    ExploreCoursesService.instance.injectRemote(newUserCoursesService);
    await ExploreCoursesService.instance.loadCourses();
  });

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
