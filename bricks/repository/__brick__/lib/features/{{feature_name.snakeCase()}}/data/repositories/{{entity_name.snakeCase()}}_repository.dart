import 'package:fpdart/fpdart.dart';

import 'package:{{package_name}}/core/error/failure.dart';
import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/domain/entities/{{entity_name.snakeCase()}}.dart';
import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/domain/repositories/i_{{entity_name.snakeCase()}}_repository.dart';
import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/data/datasources/{{entity_name.snakeCase()}}_remote_datasource.dart';

class {{entity_name.pascalCase()}}Repository implements I{{entity_name.pascalCase()}}Repository {
  const {{entity_name.pascalCase()}}Repository({
    required I{{entity_name.pascalCase()}}RemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final I{{entity_name.pascalCase()}}RemoteDataSource _remoteDataSource;

  {{#methods}}
  @override
  Future<Either<Failure, {{returnType}}>> {{signature}} async {
    try {
      // TODO: implement {{methodName}}
      throw UnimplementedError();
    } on Exception catch (e) {
      return Left(Failure.server(message: e.toString()));
    }
  }
  {{/methods}}
}
