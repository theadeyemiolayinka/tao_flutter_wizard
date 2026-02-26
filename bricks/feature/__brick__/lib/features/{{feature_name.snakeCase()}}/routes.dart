import 'package:go_router/go_router.dart';

import 'package:{{package_name}}/core/routes/app_routes.dart';
import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/presentation/pages/{{feature_name.snakeCase()}}_page.dart';

/// Feature routes for {{feature_name.pascalCase()}}.
/// Auto-patched by the [route] brick via hook.
final List<RouteBase> {{feature_name.camelCase()}}Routes = [
  GoRoute(
    path: AppRoutes.{{feature_name.constantCase()}}__INDEX.path,
    name: AppRoutes.{{feature_name.constantCase()}}__INDEX.routeName,
    builder: (context, state) => const {{feature_name.pascalCase()}}Page(),
  ),
  // mason:routes
];
