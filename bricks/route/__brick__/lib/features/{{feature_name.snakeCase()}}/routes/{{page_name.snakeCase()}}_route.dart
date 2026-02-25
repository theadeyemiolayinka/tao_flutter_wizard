import 'package:go_router/go_router.dart';

import '../pages/{{page_name.snakeCase()}}_page.dart';

GoRoute get {{page_name.camelCase()}}Route => GoRoute(
      path: '{{route_path}}',
      name: {{page_name.pascalCase()}}Page.routeName,
      builder: (context, state) {
        {{#route_params}}
        {{{route_params}}}
        {{/route_params}}
        return {{#route_params}}{{page_name.pascalCase()}}Page(/* pass params */){{/route_params}}{{^route_params}}const {{page_name.pascalCase()}}Page(){{/route_params}};
      },
    );
