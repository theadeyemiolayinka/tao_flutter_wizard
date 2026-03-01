import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/application/services/{{service_name.snakeCase()}}_service.dart';

/// Concrete implementation of [{{service_name.pascalCase()}}Service].
///
/// Injected as a lazy singleton via GetIt (done automatically by the
/// [service] brick hook).
class {{service_name.pascalCase()}}ServiceImpl implements {{service_name.pascalCase()}}Service {
  // TODO: inject dependencies via constructor if needed
  // TODO: implement service methods
}
