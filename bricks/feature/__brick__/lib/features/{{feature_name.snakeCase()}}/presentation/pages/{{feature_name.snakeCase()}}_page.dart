import 'package:flutter/material.dart';

class {{feature_name.pascalCase()}}Page extends StatelessWidget {
  const {{feature_name.pascalCase()}}Page({super.key});

  static const routeName = '/{{feature_name.paramCase()}}';

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
