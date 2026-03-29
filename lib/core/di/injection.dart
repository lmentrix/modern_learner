import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../features/progress/data/repositories/progress_repository_impl.dart';
import '../../features/progress/domain/repositories/progress_repository.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  getIt.init();
  // Register progress repository
  getIt.registerLazySingleton<ProgressRepository>(
    () => ProgressRepositoryImpl(),
  );
}
