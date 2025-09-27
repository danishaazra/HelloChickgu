import 'package:flutter/material.dart';

class QuizSummaryOptionsPage extends StatelessWidget {
  final String fileName;
  const QuizSummaryOptionsPage({super.key, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Options')),
      body: Center(
        child: Text(
          'Uploaded: ' + fileName,
          style: const TextStyle(fontFamily: 'Baloo2'),
        ),
      ),
    );
  }
}
