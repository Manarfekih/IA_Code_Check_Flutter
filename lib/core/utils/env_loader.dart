import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvLoader {
  static const String _geminiKey = 'GEMINI_API_KEY';
  static const String _groqKey = 'GROQ_API_KEY';

  static const String _geminiBase = 'GEMINI_BASE_URL';
  static const String _groqBase = 'GROQ_BASE_URL';
  static const String _groqModel = 'GROQ_MODEL';  // Add this

  static const String _env = 'ENVIRONMENT';

  static Future<void> load() async {
    await dotenv.load(fileName: ".env");
  }

  // ================= GEMINI =================
  static String get geminiApiKey {
    final key = dotenv.env[_geminiKey];
    if (key == null || key.isEmpty) {
      throw Exception('$_geminiKey not found in .env file');
    }
    return key;
  }

  static String get geminiBaseUrl {
    return dotenv.env[_geminiBase] ??
        'https://generativelanguage.googleapis.com/v1beta';
  }

  // ================= GROQ =================
  static String get groqApiKey {
    final key = dotenv.env[_groqKey];
    if (key == null || key.isEmpty) {
      throw Exception('$_groqKey not found in .env file');
    }
    return key;
  }

  static String get groqBaseUrl {
    return dotenv.env[_groqBase] ??
        'https://api.groq.com/openai/v1';
  }

  // Add this getter for Groq model
  static String get groqModel {
    // Keep a safe default in case GROQ_MODEL is missing.
    final raw = dotenv.env[_groqModel];
    final trimmed = (raw == null || raw.trim().isEmpty)
        ? 'llama-3.1-8b-instant'
        : raw.trim();

    // Common copy/paste issues seen in error reports:
    // - trailing backticks
    // - "Ilama" (capital i) instead of "llama"
    var sanitized = trimmed.replaceAll('`', '');
    if (sanitized.startsWith('Ilama')) {
      sanitized = 'l${sanitized.substring(1)}';
    }

    return sanitized;
  }

  // ================= ENV =================
  static String get environment {
    return dotenv.env[_env] ?? 'development';
  }
}
