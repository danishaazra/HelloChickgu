import 'package:flutter/material.dart';
import 'shared/theme/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hellochickgu/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/coin_service.dart';
import 'features/chatbot/chippy_chatbot.dart';
import 'shared/const.dart';
import 'services/gemini_service.dart'; // ✅ your custom service

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  // ✅ Load env
  await dotenv.load(fileName: '.env');

  // ✅ Firebase init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Notification init
  await NotificationService.instance.initialize();

  // ✅ Coin backfill
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final data = doc.data();
      final points = (data?['points'] as int?) ?? 0;
      final coins = (data?['coins'] as int?) ?? 0;
      if (coins < points) {
        await CoinService.instance.addCoins(points - coins);
      }
    }
  } catch (_) {}

  // ✅ Initialize your GeminiService once
  await GeminiService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello Chickgu!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ChippyChatbotPage(),
    );
  }
}

