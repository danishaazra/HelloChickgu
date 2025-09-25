import 'package:flutter/material.dart';

class QuizReviewPage extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<dynamic> selectedAnswers;

  const QuizReviewPage({
    super.key,
    required this.questions,
    required this.selectedAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/backgroundgame.png', fit: BoxFit.cover),
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            itemBuilder: (_, i) {
              final q = questions[i];
              final selected = selectedAnswers[i];
              
              // Handle different question types
              if (q.containsKey('correctAnswer')) {
                // Multiple choice questions (Level 1, 2, 4)
                final correctIndex = q['correctAnswer'] as int;
                final isCorrect = selected != null && selected == correctIndex;
                return _buildMultipleChoiceQuestion(i, q, correctIndex, selected, isCorrect);
              } else if (q.containsKey('answer')) {
                // Hangman-style questions (Level 3)
                final correctAnswer = q['answer'] as String;
                final isCorrect = selected != null && selected.toString().toUpperCase() == correctAnswer.toUpperCase();
                return _buildHangmanQuestion(i, q, correctAnswer, selected, isCorrect);
              } else {
                // Fallback for other question types
                return _buildGenericQuestion(i, q, selected);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceQuestion(int i, Map<String, dynamic> q, int correctIndex, dynamic selected, bool isCorrect) {
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
          Text(
            'Q${i + 1}.',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            q['question'],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ...List.generate((q['answers'] as List).length, (idx) {
            final answerText = q['answers'][idx] as String;
            final bool isAnswer = idx == correctIndex;
            final bool isChosen = selected == idx;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: isAnswer
                      ? const Color(0xFF4FC3F7)
                      : (isChosen ? const Color(0xFF4FC3F7).withOpacity(0.6) : Colors.black.withOpacity(0.08)),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (isAnswer)
                    const Icon(Icons.check_circle, color: Color(0xFF4FC3F7), size: 18)
                  else if (isChosen)
                    const Icon(Icons.radio_button_checked, color: Color(0xFF4FC3F7), size: 18)
                  else
                    const Icon(Icons.circle_outlined, color: Colors.black26, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(answerText)),
                ],
              ),
            );
          }),
          const SizedBox(height: 6),
          Text(
            isCorrect ? 'Correct' : 'Your answer is incorrect',
            style: TextStyle(
              color: isCorrect ? Colors.green : Colors.red,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHangmanQuestion(int i, Map<String, dynamic> q, String correctAnswer, dynamic selected, bool isCorrect) {
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
          Text(
            'Q${i + 1}.',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            q['question'],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          if (q.containsKey('hint'))
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Text(
                'Hint: ${q['hint']}',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isCorrect ? Colors.green : Colors.red,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Correct Answer: $correctAnswer',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (selected != null)
                        Text(
                          'Your Answer: $selected',
                          style: TextStyle(
                            color: isCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isCorrect ? 'Correct!' : 'Incorrect',
            style: TextStyle(
              color: isCorrect ? Colors.green : Colors.red,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericQuestion(int i, Map<String, dynamic> q, dynamic selected) {
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
          Text(
            'Q${i + 1}.',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            q['question'],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          if (selected != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text('Your Answer: $selected'),
            ),
        ],
      ),
    );
  }
}