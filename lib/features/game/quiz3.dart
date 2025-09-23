import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hellochickgu/shared/theme/theme.dart';
import 'package:hellochickgu/shared/utils/responsive.dart';
import 'package:hellochickgu/features/game/quiz3end.dart';

class quiz3 extends StatefulWidget {
  const quiz3({super.key});

  @override
  State<quiz3> createState() => _Quiz3State();
}

class _Quiz3State extends State<quiz3> {
  // Timer & progress
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isQuizCompleted = false;

  int currentQuestionIndex = 0;
  int correctCount = 0;
  int wrongCount = 0;

  // Full alphabet as letter bank for all questions
  static const String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  // Hangman-style: each entry has a prompt, answer string, and letter bank
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'In Java, which keyword is used when a method does not return any value? Choose the correct keyword to complete the statement.',
      'hint': 'It’s the return type for methods with no result.',
      'answer': 'VOID',
    },
    {
      'question': 'In Dart, which collection stores only unique elements and does not preserve order? Select the correct term.',
      'hint': 'It is neither a List nor a Map.',
      'answer': 'SET',
    },
    {
      'question': 'In object-oriented programming (Java), which keyword is used to create a subclass that inherits from a parent class?',
      'hint': 'Appears in the class declaration to inherit.',
      'answer': 'EXTENDS',
    },
    {
      'question': 'On the web, which HTTP method is typically used to retrieve resources without modifying them?',
      'hint': 'It is safe and idempotent, often used for pages.',
      'answer': 'GET',
    },
    {
      'question': 'Which three-letter acronym stands for the standard language used to manage and query relational databases?',
      'hint': 'Think of SELECT, INSERT, and UPDATE.',
      'answer': 'SQL',
    },
    {
      'question': 'What is the common two-letter abbreviation for Artificial Intelligence?',
      'hint': 'Frequently paired with ML in tech topics.',
      'answer': 'AI',
    },
    {
      'question': 'Which three-letter keyword is commonly used to set up a counted loop in many languages?',
      'hint': 'Often seen with an index variable i.',
      'answer': 'FOR',
    },
    {
      'question': 'In Dart, the null-coalescing operator (??) returns the left operand if it is not null, otherwise the right operand. Choose a 7-letter word that describes this: it provides a fallback value.',
      'hint': 'Another word for “backup” or “substitute”.',
      'answer': 'DEFAULT',
    },
    {
      'question': 'Inside a class, what do we call a function that belongs to that class?',
      'hint': 'It can access the instance’s fields.',
      'answer': 'METHOD',
    },
    {
      'question': 'Which markup language acronym is used to structure content on the web?',
      'hint': 'Works together with CSS and JS.',
      'answer': 'HTML',
    },
    {
      'question': 'Complete the phrase: Bubble _____ is a simple sorting algorithm with O(n^2) complexity.',
      'hint': 'The missing word is the operation performed.',
      'answer': 'SORT',
    },
    {
      'question': 'Which UI toolkit is used by Dart/Flutter apps for building interfaces across platforms?',
      'hint': 'It uses widgets and hot reload.',
      'answer': 'FLUTTER',
    },
    {
      'question': 'Which structure stores key–value pairs where each key maps to a value?',
      'hint': 'In Dart, it uses curly braces with colons.',
      'answer': 'MAP',
    },
    {
      'question': 'Many programs handle tasks in parallel using multiple threads. Fill the blank: multi______.',
      'hint': 'The word describes the act of running threads.',
      'answer': 'THREAD',
    },
    {
      'question': 'What is the typical name of the entry function that many programs start from?',
      'hint': 'In C, C++, Java, and Dart, it’s the same word.',
      'answer': 'MAIN',
    },
  ];

  late List<String?> filledLetters; // per question current state (for current question)
  late List<Set<int>> usedLetterIndices; // used alphabet indices per question
  late List<int> wrongAttempts; // wrong guesses per question
  late List<bool> revealed; // whether answer revealed due to attempts
  late List<bool> graded; // whether counted towards correct/wrong
  late List<String?> guesses; // collected guesses for review
  late List<bool> hintShown; // track if hint is revealed per question

  @override
  void initState() {
    super.initState();
    filledLetters = List<String?>.filled(questions[0]['answer'].length, null);
    usedLetterIndices = List.generate(questions.length, (_) => <int>{});
    wrongAttempts = List<int>.filled(questions.length, 0);
    revealed = List<bool>.filled(questions.length, false);
    graded = List<bool>.filled(questions.length, false);
    guesses = List<String?>.filled(questions.length, null);
    hintShown = List<bool>.filled(questions.length, false);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isQuizCompleted) {
        setState(() => _secondsElapsed++);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isQuizCompleted = true);
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}.${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _resetForQuestion(int index) {
    final answer = (questions[index]['answer'] as String);
    filledLetters = List<String?>.filled(answer.length, null);
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        _resetForQuestion(currentQuestionIndex);
      });
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        _resetForQuestion(currentQuestionIndex);
      });
    }
  }

  void _selectLetter(int bankIndex) {
    final letters = _alphabet;
    if (usedLetterIndices[currentQuestionIndex].contains(bankIndex)) return;
    final letter = letters[bankIndex];
    final answer = (questions[currentQuestionIndex]['answer'] as String).toUpperCase();
    bool hit = false;
    setState(() {
      // fill all matching positions not yet filled
      for (int i = 0; i < answer.length; i++) {
        if (answer[i] == letter && filledLetters[i] == null) {
          filledLetters[i] = letter;
          hit = true;
        }
      }
      usedLetterIndices[currentQuestionIndex].add(bankIndex);
      if (!hit) {
        wrongAttempts[currentQuestionIndex] = wrongAttempts[currentQuestionIndex] + 1;
        if (wrongAttempts[currentQuestionIndex] >= 5) {
          // reveal the answer
          for (int i = 0; i < answer.length; i++) {
            filledLetters[i] = answer[i];
          }
          guesses[currentQuestionIndex] = answer;
          revealed[currentQuestionIndex] = true;
        }
      } else {
        // if answer fully filled, store guess
        if (_isAnswerFilled()) {
          guesses[currentQuestionIndex] = filledLetters.map((e) => e ?? '').join();
        }
      }
    });
  }

  // backspace reserved (not currently used)

  bool _isAnswerFilled() => filledLetters.every((c) => c != null);

  // delete button removed

  void _submitIfLastQuestion() {
    if (currentQuestionIndex == questions.length - 1) {
      _gradeCurrentIfNeeded();
      _stopTimer();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => quiz3end(
            correct: correctCount,
            wrong: wrongCount,
            timeTaken: _secondsElapsed,
            level: 3,
            questions: questions,
            guesses: guesses,
          ),
        ),
      );
    }
  }

  void _gradeCurrentIfNeeded() {
    if (graded[currentQuestionIndex]) return;
    final answer = (questions[currentQuestionIndex]['answer'] as String);
    final guess = (revealed[currentQuestionIndex]
            ? answer
            : (guesses[currentQuestionIndex] ?? filledLetters.map((e) => e ?? '').join()))
        .toUpperCase();
    if (guess == answer.toUpperCase()) {
      correctCount++;
    } else {
      wrongCount++;
    }
    graded[currentQuestionIndex] = true;
  }

  // advance helper not used (navigation allowed without answering)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isSmallScreen = Responsive.isSmallScreen(context);
    final isVerySmallScreen = Responsive.isVerySmallScreen(context);

    final q = questions[currentQuestionIndex];
    final String prompt = q['question'] as String;
    final String? hint = q['hint'] as String?;
    final String letters = _alphabet;
    final answerLen = (q['answer'] as String).length;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/quiz.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: isSmallScreen ? 20 : 40),
                  // Header with question count, timer, close, and progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: Responsive.scaleWidth(context, 360),
                        padding: Responsive.scalePaddingSymmetric(context, horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: Responsive.scaleBorderRadiusAll(context, 24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 16,
                              spreadRadius: 3,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Question ${currentQuestionIndex + 1} of ${questions.length}",
                                    style: TextStyle(
                                      fontFamily: 'Baloo2',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      color: cs.primary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset("assets/clock.png", width: 28, height: 28),
                                      const SizedBox(width: 10),
                                      Text(
                                        _formatTime(_secondsElapsed),
                                        style: const TextStyle(
                                          fontFamily: 'Baloo2',
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.12),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset('assets/xbutton.png', fit: BoxFit.contain),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: (currentQuestionIndex + 1) / questions.length,
                                minHeight: 10,
                                backgroundColor: Colors.green.withOpacity(0.15),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 16),
                  // Question box styled like quiz2
                  Container(
                    width: Responsive.scaleWidth(context, 360),
                    height: isVerySmallScreen ? 300 : (isSmallScreen ? 350 : Responsive.scaleHeight(context, 370)),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.20),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.6)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text("💡", style: TextStyle(fontSize: 18)),
                                SizedBox(width: 6),
                                Text(
                                  "Let’s think about this",
                                  style: TextStyle(
                                    fontFamily: 'Baloo2',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  prompt,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontFamily: 'Baloo2',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (hint != null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    hintShown[currentQuestionIndex] = !hintShown[currentQuestionIndex];
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.amber.shade400),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.help_outline, size: 18, color: Colors.amber),
                                      const SizedBox(width: 6),
                                      Text(
                                        hintShown[currentQuestionIndex] ? hint : 'Tap to show hint',
                                        style: const TextStyle(
                                          fontFamily: 'Baloo2',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Answer slots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(answerLen, (i) {
                      final c = filledLetters.length > i ? filledLetters[i] : null;
                      return Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            c == null ? '_' : c,
                            style: const TextStyle(fontFamily: 'Baloo2', fontWeight: FontWeight.w800, fontSize: 18),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  // Attempts indicator (containers showing X)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final bool active = i < wrongAttempts[currentQuestionIndex];
                      return Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: active ? Colors.red : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: Border.all(color: active ? Colors.red : Colors.black26, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            'X',
                            style: TextStyle(
                              color: active ? Colors.white : Colors.black45,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  // Letter bank grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...List.generate(letters.length, (i) {
                        final used = usedLetterIndices[currentQuestionIndex].contains(i);
                        return GestureDetector(
                          onTap: used ? null : () => _selectLetter(i),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: used ? Colors.grey : const Color(0xFFFFB6C1),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6, offset: const Offset(0, 3)),
                              ],
                            ),
                              child: Center(
                                child: Text(
                                  letters[i],
                                  style: const TextStyle(fontFamily: 'Baloo2', fontWeight: FontWeight.w800, color: Colors.black),
                                ),
                              ),
                          ),
                        );
                      }),
                        // delete button removed
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 80 : 120),
                ],
              ),
            ),
          ),
          // Bottom controls: Back / Next / Done
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (currentQuestionIndex > 0)
                          GestureDetector(
                            onTap: _previousQuestion,
                            child: Container(
                              width: 64,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Transform.rotate(
                                angle: 3.1415926535,
                                child: const Icon(Icons.play_arrow_rounded, size: 32, color: Colors.white),
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 64, height: 44),
                        const SizedBox(width: 1),
                        GestureDetector(
                          onTap: currentQuestionIndex < questions.length - 1 ? _nextQuestion : _submitIfLastQuestion,
                          child: Container(
                            width: 64,
                            height: 44,
                            decoration: BoxDecoration(
                              color: currentQuestionIndex < questions.length - 1 ? AppTheme.primaryBlue : Colors.green,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: currentQuestionIndex < questions.length - 1
                                ? const Icon(Icons.play_arrow_rounded, size: 32, color: Colors.white)
                                : Center(
                                    child: Text(
                                      'Done',
                                      style: TextStyle(
                                        fontFamily: 'Baloo2',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


