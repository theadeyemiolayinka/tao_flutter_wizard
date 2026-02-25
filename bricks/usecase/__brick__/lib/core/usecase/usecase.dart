import 'package:fpdart/fpdart.dart';

import '../error/failure.dart';

abstract interface class UseCase<Type, Params> {
  TaskEither<Failure, Type> call(Params params);
}

class NoParams {
  const NoParams();
}
