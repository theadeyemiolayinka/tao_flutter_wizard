import 'package:flutter/material.dart';

import 'package:{{package_name}}/core/routes/app_routes.dart';

class {{feature_name.pascalCase()}}Page extends StatelessWidget {
  const {{feature_name.pascalCase()}}Page({super.key});

  static const routeName = AppRoutes.{{feature_name.constantCase()}}__INDEX;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{{feature_name.titleCase()}}'),
      ),
      body: const Center(
        child: Text('{{feature_name.titleCase()}} Page'),
      ),
    );
  }
}
