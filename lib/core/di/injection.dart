import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:modern_learner_production/core/di/injection.config.dart';
import 'package:modern_learner_production/core/network/network_info.dart';
import 'package:modern_learner_production/core/state/progress_navigation_state.dart';
import 'package:modern_learner_production/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:modern_learner_production/features/explore/data/datasources/learning_subject_local_datasource.dart';
import 'package:modern_learner_production/features/explore/data/repositories/learning_subject_repository_impl.dart';
import 'package:modern_learner_production/features/explore/domain/repositories/learning_subject_repository.dart';
import 'package:modern_learner_production/features/explore/domain/usecases/get_all_learning_subjects.dart';
import 'package:modern_learner_production/features/explore/domain/usecases/get_subjects_by_category.dart';
import 'package:modern_learner_production/features/explore/domain/usecases/search_learning_subjects.dart';
import 'package:modern_learner_production/features/explore/view/bloc/learning_subjects_bloc.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/explore/service/user_courses_service.dart';
import 'package:modern_learner_production/features/profile/view/bloc/profile_bloc.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  await getIt.init();

  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<InternetConnection>(() => InternetConnection());
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));

  getIt.registerSingleton<AuthBloc>(AuthBloc());
  getIt.registerFactory(() => ProfileBloc());

  getIt.registerSingleton<UserCoursesService>(
    UserCoursesService(supabase: getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton(() => ProgressNavigationState());

  ExploreCoursesService.instance.injectRemote(getIt<UserCoursesService>());

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
