{{#config}}
import 'package:envied/envied.dart';

part 'env_config.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract final class Env {
  @EnviedField(varName: 'BASE_URL', defaultValue: '{{base_url}}')
  static final String baseUrl = _Env.baseUrl;

  @EnviedField(varName: 'APP_ENV', defaultValue: 'development')
  static final String appEnv = _Env.appEnv;
}
{{/config}}
