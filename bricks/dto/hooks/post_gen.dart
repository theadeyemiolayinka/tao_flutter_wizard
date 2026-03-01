import 'package:mason/mason.dart';

/// pubspec.yaml dependency hint (append manually or via add_dependency script):
///
/// dependencies:
///   freezed_annotation: ^2.4.4
///   json_annotation: ^4.9.0
///
/// dev_dependencies:
///   build_runner: ^2.4.13
///   freezed: ^2.5.7
///   json_serializable: ^6.8.0
void run(HookContext context) {
  // No additional post-gen needed for DTO hook
}
