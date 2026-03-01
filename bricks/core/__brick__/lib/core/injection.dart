import 'package:get_it/get_it.dart';

void registerCoreDependencies(GetIt getIt) {
  // mason:core-network
  // Network client and interceptors are registered here by the core brick.
  // getIt.registerSingleton<DioClient>(DioClient());

  // mason:core-connectivity
  // getIt.registerSingleton<ConnectivityService>(ConnectivityService());

  // mason:core-blocs
  // getIt.registerSingleton<AppBloc>(
  //   AppBloc(connectivityService: getIt()),
  // );

  // mason:core-misc
}
