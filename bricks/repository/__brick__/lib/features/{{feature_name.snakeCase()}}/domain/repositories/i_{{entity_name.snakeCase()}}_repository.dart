import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/{{entity_name.snakeCase()}}.dart';

abstract interface class I{{entity_name.pascalCase()}}Repository {
  {{#methods}}
  Future<Either<Failure, {{returnType}}>> {{signature}};
  {{/methods}}
}
