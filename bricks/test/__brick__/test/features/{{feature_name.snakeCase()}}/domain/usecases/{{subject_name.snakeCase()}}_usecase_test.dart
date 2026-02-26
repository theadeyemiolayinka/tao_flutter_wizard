import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:{{package_name}}/core/error/failure.dart';
import 'package:{{package_name}}/core/usecase/usecase.dart';
import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/domain/entities/{{subject_name.snakeCase()}}.dart';
import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/domain/repositories/i_{{subject_name.snakeCase()}}_repository.dart';
import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/domain/usecases/{{usecase_name_snake}}_usecase.dart';

class _MockI{{subject_name.pascalCase()}}Repository extends Mock
    implements I{{subject_name.pascalCase()}}Repository {}

void main() {
  late _MockI{{subject_name.pascalCase()}}Repository mockRepository;
  late {{subject_name.pascalCase()}}UseCase usecase;

  setUp(() {
    mockRepository = _MockI{{subject_name.pascalCase()}}Repository();
    usecase = {{subject_name.pascalCase()}}UseCase(repository: mockRepository);
  });

  group('{{subject_name.pascalCase()}}UseCase', () {
    const tParams = {{subject_name.pascalCase()}}Params(id: 'test-id');
    final t{{subject_name.pascalCase()}} = {{subject_name.pascalCase()}}(
      // TODO: populate required fields
      id: 'test-id',
    );

    test('returns Right({{subject_name.pascalCase()}}) from repository on success', () async {
      when(() => mockRepository.get{{subject_name.pascalCase()}}(any()))
          .thenAnswer((_) async => right(t{{subject_name.pascalCase()}}));

      final result = await usecase(tParams).run();

      expect(result, isA<Right<Failure, {{subject_name.pascalCase()}}>>());
      verify(() => mockRepository.get{{subject_name.pascalCase()}}(tParams.id)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns Left(Failure) from repository on failure', () async {
      const tFailure = Failure.server(message: 'Something went wrong');

      when(() => mockRepository.get{{subject_name.pascalCase()}}(any()))
          .thenAnswer((_) async => left(tFailure));

      final result = await usecase(tParams).run();

      expect(result, equals(left(tFailure)));
    });
  });
}
