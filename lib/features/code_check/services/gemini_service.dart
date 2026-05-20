import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/prompts.dart';
import '../../../core/utils/env_loader.dart';
import '../models/analysis_result.dart';

class GeminiService {
  final ApiClient _apiClient;

  GeminiService(this._apiClient);

  Future<AnalysisResult> analyzeCode(String code) async {
    try {
      final url =
          '${AppConstants.geminiGenerateEndpoint}?key=${EnvLoader.geminiApiKey}';

      final prompt = Prompts.detectionPrompt + code;

      final response = await _apiClient.dio.post(
        url,
        data: {
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        },
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 429) {
          final retry = _extractRetryDelay(response.data);
          final retryText = retry == null
              ? 'Please wait a moment and try again.'
              : 'Please wait about ${retry.inSeconds}s and try again.';

          return AnalysisResult.failure(
            'Gemini',
            'Gemini is temporarily unavailable due to rate limits. $retryText',
          );
        }

        final friendly = _friendlyHttpError(response.statusCode);
        return AnalysisResult.failure(
          'Gemini',
          friendly,
        );
      }

      final text = _extractText(response.data);

      final jsonMap = _tryParseJson(text);

      return AnalysisResult.fromJson('Gemini', jsonMap);
    } on DioException catch (e) {
      return AnalysisResult.failure(
        'Gemini',
        _mapDioError(e),
      );
    } catch (e) {
      return AnalysisResult.failure('Gemini', e.toString());
    }
  }

  // Extract Gemini response safely
  String _extractText(dynamic data) {
    try {
      return data['candidates'][0]['content']['parts'][0]['text'] ?? '';
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
        'explanation': 'Failed to parse AI response',
      };
    }
  }

  String _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    if (status != null) {
      if (status == 429) {
        return 'Gemini is temporarily unavailable due to rate limits. Please wait a moment and try again.';
      }
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

  String _friendlyHttpError(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Gemini could not process the request. Please try again.';
      case 401:
      case 403:
        return 'Gemini authentication failed. Please check your API key.';
      case 404:
        return 'Gemini service endpoint not found. Please try again later.';
      case 408:
        return 'Gemini request timed out. Please try again.';
      case 429:
        return 'Gemini is temporarily unavailable due to rate limits. Please wait a moment and try again.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Gemini service is temporarily unavailable. Please try again later.';
      default:
        return 'Gemini request failed. Please try again.';
    }
  }

  String? _extractApiErrorMessage(dynamic data) {
    try {
      final message = data['error']?['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    } catch (_) {}
    return null;
  }

  Duration? _extractRetryDelay(dynamic data) {
    try {
      final details = data['error']?['details'];
      if (details is List) {
        for (final entry in details) {
          final retryDelay = entry?['retryDelay'];
          if (retryDelay is String) {
            final match = RegExp(r'^(\d+)s$').firstMatch(retryDelay.trim());
            if (match != null) {
              return Duration(seconds: int.parse(match.group(1)!));
            }
          }
        }
      }

      final message = _extractApiErrorMessage(data);
      if (message != null) {
        final match =
            RegExp(r'Please retry in\s+([0-9]+(?:\.[0-9]+)?)s')
                .firstMatch(message);
        if (match != null) {
          final seconds = double.parse(match.group(1)!);
          return Duration(milliseconds: (seconds * 1000).round());
        }
      }
    } catch (_) {}
    return null;
  }
}