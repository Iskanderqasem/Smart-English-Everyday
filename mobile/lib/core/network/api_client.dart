import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;
  final _tokenProvider = _TokenProvider();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        sendTimeout: const Duration(milliseconds: AppConstants.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_tokenProvider, _dio),
      _ErrorInterceptor(),
      if (kDebugMode) _LoggingInterceptor(),
    ]);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> uploadFile<T>(
    String path,
    FormData formData, {
    ProgressCallback? onSendProgress,
  }) async {
    return _dio.post<T>(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  void setToken(String? token) {
    _tokenProvider.token = token;
  }

  void setRefreshToken(String? token) {
    _tokenProvider.refreshToken = token;
  }
}

class _TokenProvider {
  String? token;
  String? refreshToken;
  bool isRefreshing = false;
}

class _AuthInterceptor extends Interceptor {
  final _TokenProvider _tokenProvider;
  final Dio _dio;

  _AuthInterceptor(this._tokenProvider, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenProvider.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_tokenProvider.isRefreshing) {
      final refreshToken = _tokenProvider.refreshToken;
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          _tokenProvider.isRefreshing = true;
          final response = await _dio.post(
            '/auth/refresh',
            data: {'refresh_token': refreshToken},
            options: Options(
              headers: {'Authorization': null},
            ),
          );
          final newToken = response.data['access_token'] as String?;
          if (newToken != null) {
            _tokenProvider.token = newToken;
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newToken';
            final cloneReq = await _dio.fetch(opts);
            return handler.resolve(cloneReq);
          }
        } catch (_) {
          _tokenProvider.token = null;
          _tokenProvider.refreshToken = null;
        } finally {
          _tokenProvider.isRefreshing = false;
        }
      }
    }
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    String message = 'An error occurred';

    if (response != null) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        message = data['message'] as String? ?? message;
      }
    } else if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      message = 'Connection timeout. Please check your internet connection.';
    } else if (err.type == DioExceptionType.connectionError) {
      message = 'No internet connection. Please try again.';
    }

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: message,
        message: message,
      ),
    );
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
    if (options.data != null) debugPrint('DATA: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}: ${err.message}');
    handler.next(err);
  }
}
