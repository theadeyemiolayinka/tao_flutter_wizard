import 'package:get_it/get_it.dart';

import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/injection.dart';

export 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/routes.dart';

void setup{{feature_name.pascalCase()}}Feature(GetIt getIt) {
  register{{feature_name.pascalCase()}}Dependencies(getIt);
}
