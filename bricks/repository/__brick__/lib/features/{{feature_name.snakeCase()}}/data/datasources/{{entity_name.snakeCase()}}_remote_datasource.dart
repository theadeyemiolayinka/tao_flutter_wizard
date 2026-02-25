import 'package:dio/dio.dart';

import '../../data/models/{{entity_name.snakeCase()}}_model.dart';

abstract interface class {{entity_name.pascalCase()}}RemoteDataSource {
  {{#methods}}
  Future<{{returnType}}{{#isEntity}}Model{{/isEntity}}> {{signature}};
  {{/methods}}
}

class {{entity_name.pascalCase()}}RemoteDataSourceImpl implements {{entity_name.pascalCase()}}RemoteDataSource {
  const {{entity_name.pascalCase()}}RemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  {{#methods}}
  @override
  Future<{{returnType}}{{#isEntity}}Model{{/isEntity}}> {{signature}} async {
    // TODO: implement {{methodName}}
    throw UnimplementedError();
  }

  {{/methods}}
}
