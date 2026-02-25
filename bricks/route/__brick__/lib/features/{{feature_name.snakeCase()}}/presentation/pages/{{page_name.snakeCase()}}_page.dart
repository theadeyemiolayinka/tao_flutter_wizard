import 'package:flutter/material.dart';

class {{page_name.pascalCase()}}Page extends StatelessWidget {
  const {{page_name.pascalCase()}}Page({super.key});

  static const routeName = '{{page_name.paramCase()}}';

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
