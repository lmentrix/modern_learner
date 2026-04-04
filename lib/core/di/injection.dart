import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:modern_learner_production/core/constants/api_constants.dart';
import 'package:modern_learner_production/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:modern_learner_production/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:modern_learner_production/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:modern_learner_production/features/auth/domain/repositories/auth_repository.dart';
import 'package:modern_learner_production/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:modern_learner_production/features/auth/domain/usecases/login_usecase.dart';
import 'package:modern_learner_production/features/auth/domain/usecases/logout_usecase.dart';
import 'package:modern_learner_production/features/auth/domain/usecases/register_usecase.dart';
import 'package:modern_learner_production/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:modern_learner_production/features/home/presentation/bloc/achievement_bloc.dart';
import 'package:modern_learner_production/features/profile/domain/repositories/profile_repository.dart';
import 'package:modern_learner_production/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:modern_learner_production/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:modern_learner_production/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:modern_learner_production/features/profile/service/data/profile_remote_data_source.dart';
import 'package:modern_learner_production/features/profile/service/data/profile_remote_data_source_impl.dart';
import 'package:modern_learner_production/features/profile/service/data/profile_repository_impl.dart';
import 'package:modern_learner_production/features/progress/service/progress_navigation_state.dart';
import 'package:modern_learner_production/features/progress/service/lesson_content_service.dart';
import 'package:modern_learner_production/features/progress/service/roadmap_generation_service.dart';
import 'package:modern_learner_production/features/progress/data/repositories/progress_repository_impl.dart';
import 'package:modern_learner_production/features/progress/domain/repositories/progress_repository.dart';
import 'package:modern_learner_production/core/network/network_info.dart';
import 'package:modern_learner_production/core/di/injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  getIt.init();

  // ── Core ──────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<InternetConnection>(
    () => InternetConnection(),
  );
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt()),
  );

  // ── Auth ──────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCurrentUserUseCase(getIt()));
  getIt.registerFactory(() => AuthBloc(getIt(), getIt(), getIt(), getIt()));

  // ── Achievement ───────────────────────────────────────────────────────────
  getIt.registerFactory(() => AchievementBloc());

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

  // ── Progress ──────────────────────────────────────────────────────────────
  getIt.registerSingletonAsync<SharedPreferences>(
    () => SharedPreferences.getInstance(),
  );
  getIt.registerLazySingleton<Dio>(() => Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
      )));
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
    ),
    dependsOn: [RoadmapGenerationService],
  );
  getIt.registerLazySingleton(() => ProgressNavigationState());
}
