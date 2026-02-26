import 'package:fpdart/fpdart.dart';

import 'package:{{package_name}}/core/error/failure.dart';
import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/domain/entities/{{entity_name.snakeCase()}}.dart';

abstract interface class I{{entity_name.pascalCase()}}Repository {
  {{#methods}}
  Future<Either<Failure, {{returnType}}>> {{signature}};
  {{/methods}}
}
