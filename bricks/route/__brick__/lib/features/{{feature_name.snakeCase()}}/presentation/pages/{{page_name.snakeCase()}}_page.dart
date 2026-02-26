import 'package:flutter/material.dart';

import 'package:{{package_name}}/core/routes/app_routes.dart';

class {{page_name.pascalCase()}}Page extends StatelessWidget {
  const {{page_name.pascalCase()}}Page({super.key});

  static const routeName = AppRoutes.{{feature_name.constantCase()}}__{{page_name.constantCase()}};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{{page_name.titleCase()}}'),
      ),
      body: const Center(
        child: Text('{{page_name.titleCase()}} Page'),
      ),
    );
  }
}
