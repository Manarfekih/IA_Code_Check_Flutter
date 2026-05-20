import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/prompts.dart';
import '../../../core/utils/env_loader.dart';
import '../models/analysis_result.dart';

class GroqService {
  final ApiClient _apiClient;

  GroqService(this._apiClient);

  Future<AnalysisResult> analyzeCode(String code) async {
    try {
      final model = EnvLoader.groqModel;
      final response = await _apiClient.dio.post(
        AppConstants.groqChatEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${EnvLoader.groqApiKey}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "model": model,
          "messages": [
            {
              "role": "user",
              "content": Prompts.detectionPrompt + code,
            }
          ],
          "temperature": 0.3,
          "max_tokens": 500,
        },
      );

      if (response.statusCode != 200) {
        final message = _extractApiErrorMessage(response.data) ??
            _friendlyHttpError(response.statusCode);
        return AnalysisResult.failure(
          'Groq',
          message,
        );
      }

      final text = _extractText(response.data);
      final jsonMap = _tryParseJson(text);

      return AnalysisResult.fromJson('Groq', jsonMap);
    } on DioException catch (e) {
      return AnalysisResult.failure(
        'Groq',
        _mapError(e),
      );
    } catch (e) {
      return AnalysisResult.failure('Groq', e.toString());
    }
  }

  // Extract response safely
  String _extractText(dynamic data) {
    try {
      return data['choices'][0]['message']['content'] ?? '';
    } catch (_) {
      return '';
    }
  }

  // Safe JSON parsing
  Map<String, dynamic> _tryParseJson(String text) {
    try {
      final cleaned = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      return jsonDecode(cleaned);
    } catch (_) {
      return {
        'probability': 50,
        'label': 'Unknown',
        'explanation': 'Failed to parse Groq response',
      };
    }
  }

  String _mapError(DioException e) {
    final status = e.response?.statusCode;
    if (status != null) {
      return _friendlyHttpError(status);
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Check your network and retry.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  String? _extractApiErrorMessage(dynamic data) {
    try {
      final message = data['error']?['message'];
      if (message is String && message.trim().isNotEmpty) {
        // Keep it user-friendly: remove excessive whitespace/newlines.
        return message.trim().replaceAll(RegExp(r'\s+'), ' ');
      }
    } catch (_) {}
    return null;
  }

  String _friendlyHttpError(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Request failed. Please try again.';
      case 401:
      case 403:
        return 'Authentication failed. Check your Groq API key and try again.';
      case 404:
        return 'Service endpoint not found. Please try again later.';
      case 408:
        return 'Request timed out. Please try again.';
      case 429:
        return 'Too many requests. Please wait a bit and retry.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Groq service is temporarily unavailable. Please try again later.';
      default:
        return 'Groq request failed (HTTP ${statusCode ?? 'unknown'}). Please try again.';
    }
  }
}