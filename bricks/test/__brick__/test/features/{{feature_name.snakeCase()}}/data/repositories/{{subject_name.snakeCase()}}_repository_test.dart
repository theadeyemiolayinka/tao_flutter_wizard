import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:{{package_name}}/core/error/failure.dart';
import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/data/datasources/{{subject_name.snakeCase()}}_remote_datasource.dart';
import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/data/repositories/{{subject_name.snakeCase()}}_repository.dart';
import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/domain/entities/{{subject_name.snakeCase()}}.dart';

class _MockI{{subject_name.pascalCase()}}RemoteDataSource extends Mock
    implements I{{subject_name.pascalCase()}}RemoteDataSource {}

void main() {
  late _MockI{{subject_name.pascalCase()}}RemoteDataSource mockDataSource;
  late {{subject_name.pascalCase()}}Repository repository;

  setUp(() {
    mockDataSource = _MockI{{subject_name.pascalCase()}}RemoteDataSource();
    repository = {{subject_name.pascalCase()}}Repository(
      remoteDataSource: mockDataSource,
    );
  });

  group('{{subject_name.pascalCase()}}Repository', () {
    group('get{{subject_name.pascalCase()}}', () {
      const tId = 'test-id';
      final t{{subject_name.pascalCase()}} = {{subject_name.pascalCase()}}(
        // TODO: populate required fields
        id: tId,
      );

      test('returns Right({{subject_name.pascalCase()}}) on success', () async {
        when(() => mockDataSource.get{{subject_name.pascalCase()}}(tId))
            .thenAnswer((_) async => t{{subject_name.pascalCase()}});

        final result = await repository.get{{subject_name.pascalCase()}}(tId);

        expect(result, isA<Right<Failure, {{subject_name.pascalCase()}}>>());
        verify(() => mockDataSource.get{{subject_name.pascalCase()}}(tId)).called(1);
        verifyNoMoreInteractions(mockDataSource);
      });

      test('returns Left(ServerFailure) on exception', () async {
        when(() => mockDataSource.get{{subject_name.pascalCase()}}(tId))
            .thenThrow(Exception('network error'));

        final result = await repository.get{{subject_name.pascalCase()}}(tId);

        expect(result, isA<Left<Failure, {{subject_name.pascalCase()}}>>());
        final failure = (result as Left).value as ServerFailure;
        expect(failure.message, contains('network error'));
      });
    });
  });
}
