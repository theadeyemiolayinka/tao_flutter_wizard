/// Abstract interface for [{{service_name.pascalCase()}}Service].
///
/// Define the contract/public API here.
/// The concrete implementation lives in [{{service_name.pascalCase()}}ServiceImpl].
///
/// Register in the feature's injection.dart (done automatically by the
/// [service] brick hook):
/// ```dart
/// getIt.registerLazySingleton<{{service_name.pascalCase()}}Service>(
///   () => {{service_name.pascalCase()}}ServiceImpl(),
/// );
/// ```
abstract interface class {{service_name.pascalCase()}}Service {
  // TODO: define service methods here
}
