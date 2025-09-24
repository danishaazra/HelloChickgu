import 'package:flutter/material.dart';

class Quiz4ReviewPage extends StatelessWidget {
  final List<Map<String, dynamic>> questions;

  const Quiz4ReviewPage({super.key, required this.questions});

  // Fixed tiles that correspond to the quiz4.dart fixedTiles
  static const List<String> fixedTiles = [
    'Queue',
    'Binary Search', 
    'Stack',
    'MongoDB',
    'Application Programming Interface',
    'Structured Query Language',
    'Merge Sort',
    'O(log n)',
    'O(n²)',
    'Cascading Style Sheets',
    'Singleton',
    'HTTPS',
    'Git',
    '2ʰ⁺¹ - 1',
    'Not Found',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Quiz 4')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/backgroundgame.png', fit: BoxFit.cover),
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            itemBuilder: (_, i) {
              final q = questions[i];
              final int correctTileIndex = q['correctTileIndex'] as int;
              final String correctAnswer = fixedTiles[correctTileIndex];
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Q${i + 1}.', style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(
                      q['question'] as String, 
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Correct Answer: ', style: TextStyle(fontWeight: FontWeight.w700)),
                        Expanded(child: Text(correctAnswer)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


