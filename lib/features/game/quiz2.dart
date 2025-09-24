import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hellochickgu/shared/theme/theme.dart';
import 'package:hellochickgu/shared/utils/responsive.dart';
import 'package:hellochickgu/features/game/quiz2end.dart';

class quiz2 extends StatefulWidget {
  const quiz2({super.key});

  @override
  State<quiz2> createState() => _Quiz2State();
}

class _Quiz2State extends State<quiz2> {
  final TextEditingController _controller = TextEditingController();

  // Timer & progress
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isQuizCompleted = false;

  int currentQuestionIndex = 0;
  int correctCount = 0;
  int wrongCount = 0;
  late List<String?> typedAnswers;

  // 15 free‑text questions: trickier outputs
final List<Map<String, dynamic>> questions = [
  {
    'question': "Dart\nvoid main(){\n  print(0.1 + 0.2);\n}\n\nOutput?",
    'acceptable': ['0.3'],
  },
  {
    'question': "Dart\nvoid main(){\n  var a = [1,2,3];\n  var b = a;\n  b.add(4);\n  print(a);\n}\n\nOutput?",
    'acceptable': ['[1, 2, 3, 4]','[1,2,3,4]'],
  },
  {
    'question': "Dart\nvoid main(){\n  int x = 5;\n  print(++x);\n}\n\nOutput?",
    'acceptable': ['6'],
  },
  {
    'question': "Dart\nvoid main(){\n  print('Hi' + ' Dart');\n}\n\nOutput?",
    'acceptable': ['Hi Dart'],
  },
  {
    'question': "Dart\nvoid main(){\n  print(int.parse('12') + 8);\n}\n\nOutput?",
    'acceptable': ['20'],
  },
  {
    'question': "Dart\nvoid main(){\n  List<int> n = [1,2,3];\n  n.add(4);\n  print(n.length);\n}\n\nOutput?",
    'acceptable': ['4'],
  },
  {
    'question': "Dart\nvoid main(){\n  var s = {'a','b'};\n  print(s.length);\n}\n\nOutput?",
    'acceptable': ['2'],
  },
  {
    'question': "Dart\nvoid main(){\n  var m = {'a':1,'b':2};\n  m['a'] = 5;\n  print(m);\n}\n\nOutput?",
    'acceptable': ['{a: 5, b: 2}','{a:5, b:2}','{a:5,b:2}'],
  },
  {
    'question': "Dart\nvoid main(){\n  String t = 'abc';\n  print(t[1]);\n}\n\nOutput?",
    'acceptable': ['b'],
  },
  {
    'question': "Dart\nvoid main(){\n  int? v;\n  print(v ?? 10);\n}\n\nOutput?",
    'acceptable': ['10'],
  },
  {
    'question': "Dart\nvoid main(){\n  final l = [1,2,3,4];\n  print(l.first);\n}\n\nOutput?",
    'acceptable': ['1'],
  },
  {
    'question': "Dart\nvoid main(){\n  int x = 10;\n  print(x > 5 ? 'big' : 'small');\n}\n\nOutput?",
    'acceptable': ['big'],
  },
  {
    'question': "Dart\nvoid main(){\n  var list = [1,2,3];\n  list.removeAt(0);\n  print(list);\n}\n\nOutput?",
    'acceptable': ['[2, 3]','[2,3]'],
  },
  {
    'question': "Dart\nvoid main(){\n  var x;\n  print(x ??= 7);\n}\n\nOutput?",
    'acceptable': ['7'],
  },
  {
    'question': "Dart\nvoid main(){\n  final a = [1,2];\n  final b = a;\n  a.add(3);\n  print(b);\n}\n\nOutput?",
    'acceptable': ['[1, 2, 3]','[1,2,3]'],
  },
];


  @override
  void initState() {
    super.initState();
    typedAnswers = List<String?>.filled(questions.length, null);
    _controller.text = '';
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
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

  void _submitAnswer() {
    final raw = _controller.text.trim();
    typedAnswers[currentQuestionIndex] = raw.isEmpty ? null : raw;

    final normalized = _normalize(raw);
    final acceptable = (questions[currentQuestionIndex]['acceptable'] as List)
        .map((e) => _normalize(e.toString()))
        .toList();
    final isCorrect = acceptable.contains(normalized);
    if (isCorrect) {
      correctCount++;
    } else {
      wrongCount++;
    }

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        _controller.clear();
      });
    } else {
      _stopTimer();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => quiz2end(
            correct: correctCount,
            wrong: wrongCount,
            timeTaken: _secondsElapsed,
            questions: questions,
            typedAnswers: typedAnswers,
            level: 2,
          ),
        ),
      );
    }
  }

  void _nextQuestion() {
    // save current input (optional)
    typedAnswers[currentQuestionIndex] = _controller.text.trim().isEmpty ? typedAnswers[currentQuestionIndex] : _controller.text.trim();
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        _controller.text = typedAnswers[currentQuestionIndex] ?? '';
      });
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        _controller.text = typedAnswers[currentQuestionIndex] ?? '';
      });
    }
  }

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isSmallScreen = Responsive.isSmallScreen(context);
    final isVerySmallScreen = Responsive.isVerySmallScreen(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
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
                                        style: TextStyle(
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
                                      child: Image.asset(
                                        'assets/xbutton.png',
                                        fit: BoxFit.contain,
                                      ),
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
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 16),
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
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
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
                                children: [
                                  const Text("💡", style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 6),
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
                            SizedBox(height: 12),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    questions[currentQuestionIndex]['question'],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: 'Baloo2',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ),
                  SizedBox(height: isSmallScreen ? 80 : 120),
                ],
              ),
            ),
          ),
          // Bottom input bar + Back/Next/Done like quiz1
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
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _controller,
                              onSubmitted: (_) => _submitAnswer(),
                              textInputAction: TextInputAction.send,
                              decoration: InputDecoration(
                                hintText: 'type here',
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                fontFamily: 'Baloo2',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _submitAnswer,
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
                            child: const Icon(Icons.send_rounded, size: 24, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                          onTap: currentQuestionIndex < questions.length - 1 ? _nextQuestion : _submitAnswer,
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


