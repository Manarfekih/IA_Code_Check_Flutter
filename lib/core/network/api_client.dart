import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  
  ApiClient._internal();
  
  factory ApiClient() {
    return _instance;
  }
  
  Dio? _dio;
  
  void init({String? token}) {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => true,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ));
    
    if (kDebugMode) {
      _dio!.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        logPrint: (Object print) => debugPrint(print.toString()),
      ));
    }
    
    debugPrint('✅ ApiClient initialized successfully');
  }
  
  Dio get dio {
    if (_dio == null) {
      throw StateError('ApiClient not initialized. Call ApiClient().init() first in main.dart');
    }
    return _dio!;
  }
  
  bool get isInitialized => _dio != null;
}
