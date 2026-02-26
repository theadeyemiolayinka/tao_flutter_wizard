import 'package:get_it/get_it.dart';

import 'injection.dart';

export 'routes.dart';

void setup{{feature_name.pascalCase()}}Feature(GetIt getIt) {
  register{{feature_name.pascalCase()}}Dependencies(getIt);
}
