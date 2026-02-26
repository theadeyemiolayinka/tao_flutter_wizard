import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
{{#hydrated}}
import 'package:hydrated_bloc/hydrated_bloc.dart';
{{/hydrated}}

part '{{bloc_name.snakeCase()}}_bloc.freezed.dart';
{{#hydrated}}
part '{{bloc_name.snakeCase()}}_bloc.g.dart';
{{/hydrated}}
part '{{bloc_name.snakeCase()}}_event.dart';
part '{{bloc_name.snakeCase()}}_state.dart';


{{#hydrated}}
class {{bloc_name.pascalCase()}}Bloc
    extends HydratedBloc<{{bloc_name.pascalCase()}}Event, {{bloc_name.pascalCase()}}State> {
{{/hydrated}}
{{^hydrated}}
class {{bloc_name.pascalCase()}}Bloc
    extends Bloc<{{bloc_name.pascalCase()}}Event, {{bloc_name.pascalCase()}}State> {
{{/hydrated}}
  {{bloc_name.pascalCase()}}Bloc() : super(const {{bloc_name.pascalCase()}}State.initial()) {
    {{#events}}
    on<{{bloc_name.pascalCase()}}{{.}}Event>(
      _on{{.}},
      transformer: sequential(),
    );
    {{/events}}
  }

  {{#events}}
  Future<void> _on{{.}}(
    {{bloc_name.pascalCase()}}{{.}}Event event,
    Emitter<{{bloc_name.pascalCase()}}State> emit,
  ) async {
    // TODO: implement _on{{.}}
  }

  {{/events}}
{{#hydrated}}
  @override
  {{bloc_name.pascalCase()}}State? fromJson(Map<String, dynamic> json) {
    try {
      return {{bloc_name.pascalCase()}}State.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson({{bloc_name.pascalCase()}}State state) {
    try {
      return state.toJson();
    } catch (_) {
      return null;
    }
  }
{{/hydrated}}
}
