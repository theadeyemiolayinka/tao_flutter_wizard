{{#config}}
import 'package:{{package_name}}/core/config/env_config.dart';

abstract final class AppConfig {
  static String get baseUrl => Env.baseUrl;
  static String get appEnv => Env.appEnv;
  static bool get isProduction => Env.appEnv == 'production';
  static bool get isDevelopment => Env.appEnv == 'development';
  static bool get isStaging => Env.appEnv == 'staging';
}
{{/config}}
