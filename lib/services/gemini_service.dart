import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  GeminiService._internal();
  static final GeminiService instance = GeminiService._internal();

  // Priority: dart-define -> .env -> empty
  static final String _apiKey =
      const String.fromEnvironment('GEMINI_API_KEY').isNotEmpty
          ? const String.fromEnvironment('GEMINI_API_KEY')
          : (dotenv.maybeGet('GEMINI_API_KEY') ?? '');

  late final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _apiKey,
    safetySettings: const [],
  );

  Future<String> askChippy(String prompt) async {
    if (_apiKey.isEmpty) {
      throw const GeminiException(
        'Missing GEMINI_API_KEY. Add it to .env or pass --dart-define=GEMINI_API_KEY=your_key',
      );
    }

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    final text = response.text?.trim();
    if (text == null || text.isEmpty) {
      throw const GeminiException('Empty response from Gemini');
    }
    return text;
  }
}

class GeminiException implements Exception {
  final String message;
  const GeminiException(this.message);
  @override
  String toString() => message;
}
