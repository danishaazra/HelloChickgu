import 'package:flutter/material.dart';
import 'quiz_review.dart';

class TrainingFolderPage extends StatefulWidget {
  final String title;

  const TrainingFolderPage({super.key, required this.title});

  @override
  State<TrainingFolderPage> createState() => _TrainingFolderPageState();
}

class _TrainingFolderPageState extends State<TrainingFolderPage> {
  late List<String> items;
  bool selectionMode = false;
  final Set<int> selectedIndices = <int>{};

  @override
  void initState() {
    super.initState();
    items = List<String>.generate(12, (i) => 'Quizzes by AI set ${(i + 1)}');
  }

  void _confirmDeleteAll() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Delete all files?',
              style: TextStyle(
                fontFamily: 'Baloo2',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'This will remove all files in this folder. This action cannot be undone.',
              style: TextStyle(fontFamily: 'Baloo2'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontFamily: 'Baloo2'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(fontFamily: 'Baloo2', color: Colors.red),
                ),
              ),
            ],
          ),
    );
    if (ok == true) {
      setState(() {
        items.clear();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All files deleted')));
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      selectionMode = !selectionMode;
      selectedIndices.clear();
    });
  }

  void _toggleSelected(int index) {
    setState(() {
      if (selectedIndices.contains(index)) {
        selectedIndices.remove(index);
      } else {
        selectedIndices.add(index);
      }
    });
  }

  void _deleteSelected() {
    final List<int> toRemove =
        selectedIndices.toList()..sort((a, b) => b.compareTo(a));
    setState(() {
      for (final i in toRemove) {
        if (i >= 0 && i < items.length) items.removeAt(i);
      }
      selectedIndices.clear();
      selectionMode = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Selected files deleted')));
  }

  void _openQuizReview(String quizTitle) {
    // Generate sample quiz data based on the quiz title
    final List<Map<String, dynamic>> sampleQuestions = _generateSampleQuestions(
      quizTitle,
    );
    final List<int?> sampleAnswers = List.filled(sampleQuestions.length, null);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => QuizReviewPage(
              questions: sampleQuestions,
              selectedAnswers: sampleAnswers,
            ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateSampleQuestions(String quizTitle) {
    // Generate sample questions based on the quiz title
    final List<Map<String, dynamic>> questions = [];

    for (int i = 0; i < 10; i++) {
      questions.add({
        'question':
            'Sample Question ${i + 1} from $quizTitle: What is the correct answer?',
        'answers': ['A) Option A', 'B) Option B', 'C) Option C', 'D) Option D'],
        'correctAnswer': i % 4,
      });
    }

    return questions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/backgroundgame.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF4E342E)),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.title,
                style: const TextStyle(
                  fontFamily: 'Baloo2',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E342E),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _toggleSelectionMode,
                  child: Text(
                    selectionMode ? 'Cancel' : 'Select',
                    style: const TextStyle(
                      fontFamily: 'Baloo2',
                      color: Color(0xFF4E342E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: selectionMode ? 'Delete selected' : 'Delete all',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed:
                      selectionMode
                          ? (selectedIndices.isEmpty ? null : _deleteSelected)
                          : (items.isEmpty ? null : _confirmDeleteAll),
                ),
              ],
            ),
            body:
                items.isEmpty
                    ? const Center(
                      child: Text(
                        'No files in this folder',
                        style: TextStyle(
                          fontFamily: 'Baloo2',
                          color: Colors.black54,
                        ),
                      ),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.1,
                          ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final String item = items[index];
                        final bool isSelected = selectedIndices.contains(index);
                        return GestureDetector(
                          onTap: () {
                            if (selectionMode) {
                              _toggleSelected(index);
                            } else {
                              _openQuizReview(item);
                            }
                          },
                          child: Center(
                            child: SizedBox(
                              width: 600,
                              height: 600,
                              child: Stack(
                                children: [
                                  AnimatedScale(
                                    scale: isSelected ? 1.03 : 1.0,
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOut,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 220,
                                      ),
                                      curve: Curves.easeOut,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFFFFFBE6),
                                            Color(0xFFFFF0C2),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              isSelected ? 0.18 : 0.12,
                                            ),
                                            blurRadius: isSelected ? 26 : 20,
                                            spreadRadius: isSelected ? 4 : 3,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 72,
                                            height: 72,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF3CD),
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFFF4B942,
                                                  ).withOpacity(0.25),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.emoji_events,
                                              color: Color(0xFF4E342E),
                                              size: 40,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: 560,
                                            child: Text(
                                              item,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontFamily: 'Baloo2',
                                                fontSize: 22,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF4E342E),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Tap to view',
                                            style: TextStyle(
                                              fontFamily: 'Baloo2',
                                              fontSize: 13,
                                              color: Color(0xFF4E342E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 12,
                                    top: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4B942),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        'AI',
                                        style: TextStyle(
                                          fontFamily: 'Baloo2',
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (selectionMode)
                                    Positioned(
                                      right: 6,
                                      top: 6,
                                      child: Checkbox(
                                        value: isSelected,
                                        onChanged:
                                            (_) => _toggleSelected(index),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
