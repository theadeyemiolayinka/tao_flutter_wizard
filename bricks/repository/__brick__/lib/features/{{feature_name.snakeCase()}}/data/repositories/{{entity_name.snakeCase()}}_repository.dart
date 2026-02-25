import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/{{entity_name.snakeCase()}}.dart';
import '../../domain/repositories/i_{{entity_name.snakeCase()}}_repository.dart';
import '../datasources/{{entity_name.snakeCase()}}_remote_datasource.dart';

class {{entity_name.pascalCase()}}Repository implements I{{entity_name.pascalCase()}}Repository {
  const {{entity_name.pascalCase()}}Repository({
    required {{entity_name.pascalCase()}}RemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final {{entity_name.pascalCase()}}RemoteDataSource _remoteDataSource;

  {{#methods}}
  @override
  Future<Either<Failure, {{returnType}}>> {{signature}} async {
    try {
      // TODO: implement {{methodName}}
      throw UnimplementedError();
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  {{/methods}}
}
