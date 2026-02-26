{{#use_cases}}
import 'package:fpdart/fpdart.dart';

import 'package:{{package_name}}/core/error/failure.dart';

abstract interface class UseCase<Type, Params> {
  TaskEither<Failure, Type> call(Params params);
}

class NoParams {
  const NoParams();
}
{{/use_cases}}
