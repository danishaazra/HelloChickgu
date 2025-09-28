// lib/services/gemini_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';
import '../shared/const.dart';

class GeminiService {
  GeminiService._();
  static final GeminiService instance = GeminiService._();

  GenerativeModel? _model;

  /// Initialize Gemini once
  Future<void> init() async {
    if (_model != null) return;

    final apiKey = GEMINI_API_KEY;
    if (apiKey.isEmpty) {
      throw Exception("❌ GEMINI_API_KEY is missing. Check your .env file.");
    }

    _model = GenerativeModel(model: GEMINI_MODEL, apiKey: apiKey);
    print("✅ GeminiService initialized");
  }

  /// Send message to Gemini
  Future<String> sendMessage(String message) async {
    if (_model == null) {
      throw Exception("GeminiService not initialized! Call init() first.");
    }

    final content = [Content.text(message)];
    final response = await _model!.generateContent(content);
    return response.text ?? "⚠️ No response from Gemini.";
  }
}