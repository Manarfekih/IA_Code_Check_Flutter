class AppConstants {
  // App Info
  static const String appName = 'AI Code Check';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String storageUserKey = 'user_data';
  static const String storageAuthTokenKey = 'auth_token';
  static const String storageHistoryKey = 'code_check_history';
  static const String storageSettingsKey = 'app_settings';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const int maxCodeLength = 10000;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);

  // AI Models
  static const String geminiModel = 'gemini-2.5-flash';
  
  static const String groqModel = 'llama-3.1-8b-instant';   

  // API Endpoints
  static const String geminiGenerateEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent';

  static const String groqChatEndpoint =
      'https://api.groq.com/openai/v1/chat/completions';
}