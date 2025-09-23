import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:hellochickgu/features/game/level_page.dart';
// import 'package:hellochickgu/features/game/quiz2.dart';
import 'shared/theme/theme.dart';
import 'features/game/quiz1.dart';
import 'features/game/training_page.dart';
import 'features/game/quiz4.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
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
      home: const quiz4(),
      routes: {
        '/training': (context) => const TrainingPage(),
      },
    );
  }
}