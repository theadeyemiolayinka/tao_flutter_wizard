{{#app_router}}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:{{package_name}}/core/routes/app_routes.dart';

final appRouter = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: [
    // TODO: Add feature routes below, e.g.:
    // ...authRoutes,
    // ...homeRoutes,
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Route not found: ${state.uri}')),
  ),
);
{{/app_router}}
