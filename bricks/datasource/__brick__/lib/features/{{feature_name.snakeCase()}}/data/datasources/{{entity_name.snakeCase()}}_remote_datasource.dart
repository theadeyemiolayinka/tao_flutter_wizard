import 'package:dio/dio.dart';

import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/data/models/{{entity_name.snakeCase()}}_model.dart';

{{#crud_datasource}}
abstract interface class I{{entity_name.pascalCase()}}RemoteDataSource {
  Future<{{entity_name.pascalCase()}}Model> get{{entity_name.pascalCase()}}(String id);
  Future<List<{{entity_name.pascalCase()}}Model>> getAll{{entity_name.pascalCase()}}s();
  Future<{{entity_name.pascalCase()}}Model> create{{entity_name.pascalCase()}}({{entity_name.pascalCase()}}Model model);
  Future<{{entity_name.pascalCase()}}Model> update{{entity_name.pascalCase()}}({{entity_name.pascalCase()}}Model model);
  Future<void> delete{{entity_name.pascalCase()}}(String id);
}

class {{entity_name.pascalCase()}}RemoteDataSource implements I{{entity_name.pascalCase()}}RemoteDataSource {
  const {{entity_name.pascalCase()}}RemoteDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  static const _basePath = '/{{entity_name.paramCase()}}s';

  @override
  Future<{{entity_name.pascalCase()}}Model> get{{entity_name.pascalCase()}}(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('$_basePath/$id');
    return {{entity_name.pascalCase()}}Model.fromJson(response.data!);
  }

  @override
  Future<List<{{entity_name.pascalCase()}}Model>> getAll{{entity_name.pascalCase()}}s() async {
    final response = await _dio.get<List<dynamic>>(_basePath);
    return (response.data!)
        .cast<Map<String, dynamic>>()
        .map({{entity_name.pascalCase()}}Model.fromJson)
        .toList();
  }

  @override
  Future<{{entity_name.pascalCase()}}Model> create{{entity_name.pascalCase()}}(
    {{entity_name.pascalCase()}}Model model,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _basePath,
      data: model.toJson(),
    );
    return {{entity_name.pascalCase()}}Model.fromJson(response.data!);
  }

  @override
  Future<{{entity_name.pascalCase()}}Model> update{{entity_name.pascalCase()}}(
    {{entity_name.pascalCase()}}Model model,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '$_basePath/${model.id}',
      data: model.toJson(),
    );
    return {{entity_name.pascalCase()}}Model.fromJson(response.data!);
  }

  @override
  Future<void> delete{{entity_name.pascalCase()}}(String id) async {
    await _dio.delete<void>('$_basePath/$id');
  }
}
{{/crud_datasource}}
{{^crud_datasource}}
abstract interface class I{{entity_name.pascalCase()}}RemoteDataSource {
  {{#methods}}
  {{return_type}} {{method_name}}({{#params}}{{param_type}} {{param_name}}{{^-last}}, {{/-last}}{{/params}});
  {{/methods}}
}

class {{entity_name.pascalCase()}}RemoteDataSource implements I{{entity_name.pascalCase()}}RemoteDataSource {
  const {{entity_name.pascalCase()}}RemoteDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  {{#methods}}
  @override
  {{return_type}} {{method_name}}({{#params}}{{param_type}} {{param_name}}{{^-last}}, {{/-last}}{{/params}}) async {
    // TODO: implement {{method_name}}
    throw UnimplementedError();
  }

  {{/methods}}
}
{{/crud_datasource}}
