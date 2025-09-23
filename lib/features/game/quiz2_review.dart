import 'package:flutter/material.dart';

class Quiz2ReviewPage extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<String?> typedAnswers;

  const Quiz2ReviewPage({
    super.key,
    required this.questions,
    required this.typedAnswers,
  });

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll('\n', ' ')
        .replaceAll("'", '')
        .replaceAll('"', '')
        .replaceAll(RegExp(r"[^a-z0-9?+*/<>=-]"), '')
        .trim();
  }

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
              final List acceptable = (q['acceptable'] as List);
              final String? user = typedAnswers.length > i ? typedAnswers[i] : null;
              final bool isCorrect = user != null && acceptable.map((e) => _normalize(e.toString())).contains(_normalize(user));
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: isCorrect ? const Color(0xFF4FC3F7) : Colors.black.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(isCorrect ? Icons.check_circle : Icons.edit, color: const Color(0xFF4FC3F7), size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(user ?? '(no answer)')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Acceptable:', style: TextStyle(fontWeight: FontWeight.w700)),
                    ...acceptable.map((e) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(e.toString()),
                        )),
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


