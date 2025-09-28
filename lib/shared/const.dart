import 'package:flutter_dotenv/flutter_dotenv.dart';

// Use getters so they only load AFTER dotenv is ready
String get GEMINI_API_KEY => dotenv.env['GEMINI_API_KEY'] ?? '';
String get GEMINI_MODEL => dotenv.env['GEMINI_MODEL'] ?? 'gemini-1.5-flash';