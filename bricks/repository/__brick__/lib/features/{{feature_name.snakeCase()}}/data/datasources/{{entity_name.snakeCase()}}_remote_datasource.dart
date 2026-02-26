import 'package:dio/dio.dart';

import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/data/models/{{entity_name.snakeCase()}}_model.dart';

abstract interface class I{{entity_name.pascalCase()}}RemoteDataSource {
  {{#methods}}
  Future<{{returnType}}{{#isEntity}}Model{{/isEntity}}> {{signature}};
  {{/methods}}
}

class {{entity_name.pascalCase()}}RemoteDataSource implements I{{entity_name.pascalCase()}}RemoteDataSource {
  const {{entity_name.pascalCase()}}RemoteDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  {{#methods}}
  @override
  Future<{{returnType}}{{#isEntity}}Model{{/isEntity}}> {{signature}} async {
    // TODO: implement {{methodName}}
    throw UnimplementedError();
  }
  {{/methods}}
}
