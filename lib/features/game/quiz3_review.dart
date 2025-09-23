import 'package:flutter/material.dart';

class Quiz3ReviewPage extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<String?> guesses;

  const Quiz3ReviewPage({
    super.key,
    required this.questions,
    required this.guesses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/backgroundgame.png', fit: BoxFit.cover),
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            itemBuilder: (_, i) {
              final q = questions[i];
              final String answer = q['answer'] as String;
              final String? user = guesses.length > i ? guesses[i] : null;
              final bool isCorrect = user != null && user.toUpperCase() == answer.toUpperCase();
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
                    Text(q['question'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your: ', style: TextStyle(fontWeight: FontWeight.w700)),
                        Expanded(child: Text(user ?? '(no answer)')),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Answer: ', style: TextStyle(fontWeight: FontWeight.w700)),
                        Expanded(child: Text(answer)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(isCorrect ? 'Correct' : 'Incorrect',
                        style: TextStyle(color: isCorrect ? Colors.green : Colors.red, fontWeight: FontWeight.w700)),
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


