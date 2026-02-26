{{#network}}
import 'package:dio/dio.dart';

import 'package:{{package_name}}/core/network/constants/api_constants.dart';
import 'package:{{package_name}}/core/network/interceptors/logging_interceptor.dart';
import 'package:{{package_name}}/core/network/interceptors/token_interceptor.dart';

class DioClient {
  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    )..interceptors.addAll([
        LoggingInterceptor(),
        TokenInterceptor(),
      ]);
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
{{/network}}
