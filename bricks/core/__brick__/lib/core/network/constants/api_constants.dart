{{#network}}
import 'package:{{package_name}}/core/config/env_config.dart';

final class ApiConstants {
  ApiConstants._();

  static final baseUrl = Env.baseUrl;
  static const connectTimeoutMs = 30000;
  static const receiveTimeoutMs = 30000;
}
{{/network}}
