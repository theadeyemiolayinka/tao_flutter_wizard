import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/domain/repositories/i_{{subject_name.snakeCase()}}_repository.dart';
import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/presentation/bloc/{{subject_name.snakeCase()}}_bloc.dart';

class _Mock{{subject_name.pascalCase()}}Repository extends Mock
    implements I{{subject_name.pascalCase()}}Repository {}

void main() {
  late _Mock{{subject_name.pascalCase()}}Repository mock{{subject_name.pascalCase()}}Repository;
  late {{subject_name.pascalCase()}}Bloc bloc;

  setUp(() {
    mock{{subject_name.pascalCase()}}Repository = _Mock{{subject_name.pascalCase()}}Repository();
    bloc = {{subject_name.pascalCase()}}Bloc();
  });

  tearDown(() {
    bloc.close();
  });

  group('{{subject_name.pascalCase()}}Bloc', () {
    test('initial state is {{subject_name.pascalCase()}}State.initial()', () {
      expect(bloc.state, equals(const {{subject_name.pascalCase()}}State.initial()));
    });

    blocTest<{{subject_name.pascalCase()}}Bloc, {{subject_name.pascalCase()}}State>(
      'emits [loading, loaded] when LoadEvent is added and succeeds',
      build: () => bloc,
      act: (b) => b.add(const {{subject_name.pascalCase()}}Event.load()),
      expect: () => const <{{subject_name.pascalCase()}}State>[
        {{subject_name.pascalCase()}}State.loading(),
        // TODO: Add expected loaded state with mock data
      ],
    );

    blocTest<{{subject_name.pascalCase()}}Bloc, {{subject_name.pascalCase()}}State>(
      'emits [loading, error] when LoadEvent is added and fails',
      build: () => bloc,
      act: (b) => b.add(const {{subject_name.pascalCase()}}Event.load()),
      expect: () => const <{{subject_name.pascalCase()}}State>[
        {{subject_name.pascalCase()}}State.loading(),
        // TODO: Add expected error state
      ],
    );
  });
}
