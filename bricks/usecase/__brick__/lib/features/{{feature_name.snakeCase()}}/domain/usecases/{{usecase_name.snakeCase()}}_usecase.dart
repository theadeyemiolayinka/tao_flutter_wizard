import 'package:fpdart/fpdart.dart';

import 'package:{{package_name}}/core/error/failure.dart';
import 'package:{{package_name}}/core/usecase/usecase.dart';
import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/domain/entities/{{entity_name.snakeCase()}}.dart';
import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/domain/repositories/i_{{entity_name.snakeCase()}}_repository.dart';

{{#params}}
class {{usecase_name.pascalCase()}}Params {
  const {{usecase_name.pascalCase()}}Params({
    {{{params}}}
  });

  {{{params}}}
}
{{/params}}
{{^params}}
typedef {{usecase_name.pascalCase()}}Params = NoParams;
{{/params}}

class {{usecase_name.pascalCase()}}UseCase
    implements UseCase<{{entity_name.pascalCase()}}, {{usecase_name.pascalCase()}}Params> {
  const {{usecase_name.pascalCase()}}UseCase({
    required I{{entity_name.pascalCase()}}Repository repository,
  }) : _repository = repository;

  final I{{entity_name.pascalCase()}}Repository _repository;

  @override
  TaskEither<Failure, {{entity_name.pascalCase()}}> call({{usecase_name.pascalCase()}}Params params) =>
      TaskEither.tryCatch(
        () => _repository
            // TODO: Call the repository method with params
            .run()
            .then(
              (either) => either.fold(
                (failure) => throw Exception(failure.message),
                (result) => result,
              ),
            ),
        (error, stackTrace) => Failure.server(message: error.toString()),
      );
}
