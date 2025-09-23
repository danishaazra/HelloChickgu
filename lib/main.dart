import 'package:flutter/material.dart';
import 'shared/theme/theme.dart';
import 'features/home/home.dart';
import 'features/community/community.dart';
import 'features/library/library_main.dart';
import 'features/library/library_courseoutline.dart';

void main() {
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
      home: const LibraryPage(),
    );
  }
}
