import 'package:flutter/material.dart';
import 'package:hellochickgu/shared/utils/responsive.dart';
import 'package:hellochickgu/features/game/level_page.dart';
import 'package:hellochickgu/features/game/quiz3_review.dart';

class quiz3end extends StatefulWidget {
  final int correct;
  final int wrong;
  final int timeTaken;
  final int level;
  final List<Map<String, dynamic>> questions;
  final List<String?> guesses;

  const quiz3end({
    Key? key,
    required this.correct,
    required this.wrong,
    required this.timeTaken,
    required this.level,
    required this.questions,
    required this.guesses,
  }) : super(key: key);

  @override
  State<quiz3end> createState() => _Quiz3EndState();
}

class _Quiz3EndState extends State<quiz3end> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}.${remainingSeconds.toString().padLeft(2, '0')}';
  }

  int get _points => widget.correct * 10;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = Responsive.isSmallScreen(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/backgroundgame.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              width: Responsive.scaleWidth(context, 350),
              constraints: BoxConstraints(
                maxHeight: isSmallScreen ? screenSize.height * 0.86 : screenSize.height * 0.7,
              ),
              padding: Responsive.scalePaddingAll(context, 26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: Responsive.scaleBorderRadiusAll(context, 30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        final int nextUnlocked = (widget.level + 1).clamp(1, 11);
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => LevelPage(
                              initialHighestUnlockedLevel: nextUnlocked,
                              completedLevel: widget.level,
                            ),
                          ),
                          (route) => false,
                        );
                      },
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
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Level Completed",
                    style: TextStyle(
                      fontFamily: 'Baloo2',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 260,
                    height: 230,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ScaleTransition(
                          scale: _scale,
                          child: Image.asset(
                            'assets/chickenYes.png',
                            width: 600,
                            height: 600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StatBadge(
                        icon: Icons.stars,
                        accentColor: const Color(0xFFF4B942),
                        label: 'Points:',
                        value: _points.toString(),
                        fullWidth: true,
                      ),
                      const SizedBox(height: 12),
                      _StatBadge(
                        iconWidget: Image.asset('assets/clock.png', width: 22, height: 22),
                        accentColor: const Color(0xFF4FC3F7),
                        label: 'Time Taken:',
                        value: _formatTime(widget.timeTaken),
                        fullWidth: true,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4FC3F7),
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            side: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Quiz3ReviewPage(
                                  questions: widget.questions,
                                  guesses: widget.guesses,
                                ),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Review Answers',
                              style: TextStyle(fontFamily: 'Baloo2', fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4FC3F7),
                            foregroundColor: Colors.white,
                            elevation: 6,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            side: const BorderSide(color: Colors.white, width: 2),
                          ),
                          onPressed: () {
                            final int nextLevel = (widget.level + 1).clamp(1, 11);
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => LevelPage(
                                  initialHighestUnlockedLevel: nextLevel,
                                  completedLevel: widget.level,
                                ),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'DONE!',
                              style: TextStyle(fontFamily: 'Baloo2', fontWeight: FontWeight.w800),
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
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData? icon;
  final Color? accentColor;
  final Widget? iconWidget;
  final String label;
  final String value;
  final bool fullWidth;

  const _StatBadge({
    this.icon,
    this.accentColor,
    this.iconWidget,
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = accentColor ?? Colors.black54;
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.10), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: accent.withOpacity(0.6), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: iconWidget ?? Icon(icon, color: accent, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Baloo2',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Baloo2',
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}


