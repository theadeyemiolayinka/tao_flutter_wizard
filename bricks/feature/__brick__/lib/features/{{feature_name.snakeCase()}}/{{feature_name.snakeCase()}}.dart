import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '{{feature_name.snakeCase()}}/injection.dart';

export '{{feature_name.snakeCase()}}/routes.dart';

final _getIt = GetIt.instance;

void setup{{feature_name.pascalCase()}}Feature() {
  register{{feature_name.pascalCase()}}Dependencies(_getIt);
}
