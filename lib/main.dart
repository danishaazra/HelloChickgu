import 'package:flutter/material.dart';
import 'shared/theme/theme.dart';
import 'features/tutor/main_tutor.dart';
import 'features/game/quiz1.dart';
import 'features/tutor/main_tutor.dart';
import 'map.dart';
import 'features/home/home.dart';
import 'features/community/community.dart';
import 'features/library/library_main.dart';
import 'features/library/library_courseoutline.dart';
import 'features/game/quiz1.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/onboarding/onboarding.dart';
import 'features/auth/login.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/library/ar_model.dart';
import 'features/library/test_ar.dart';
import 'features/library/ar_model.dart';
import 'features/game/level_page.dart';
import 'features/library/library_main.dart';
import 'features/ar/ar_page.dart';
import 'features/learning pet/pet_home.dart';
import 'package:hellochickgu/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/coin_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.initialize();
  // One-time backfill: keep coins >= points for signed-in user
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final data = doc.data() as Map<String, dynamic>?;
      final points = (data?['points'] as int?) ?? 0;
      final coins = (data?['coins'] as int?) ?? 0;
      if (coins < points) {
        await CoinService.instance.addCoins(points - coins);
      }
    }
  } catch (_) {}
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
      home: const OnboardingPage(),
    );
  }
}
