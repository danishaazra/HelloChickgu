import 'package:flutter/material.dart';
import '../../shared/theme/theme.dart';

class ChippyChatbotPage extends StatelessWidget {
  const ChippyChatbotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ask Chippy',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close, color: Colors.redAccent),
            tooltip: 'Close',
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/chatbotbg.png', fit: BoxFit.cover),
          ),
          Column(
            children: [
              const SizedBox(height: 8),
              // chat area
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: const [
                    _ChatBubble(
                      text: 'Hi, I am Chippy, the chatbot.',
                      isUser: false,
                      color: Color(0xFFF2B266),
                    ),
                    SizedBox(height: 16),
                    _ChatBubble(
                      text:
                          "I'm going through the Introduction to Python course, and I understand what variables are, but I'm still a bit confused about how they actually store data. For example, when I assign a number to a variable, where does it go, and why do we even need variables instead of just writing the number directly? Could you explain this in a simple way?",
                      isUser: true,
                      color: AppTheme.primaryBlue,
                    ),
                  ],
                ),
              ),
              // input bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Ask anything...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final Color? color;

  const _ChatBubble({required this.text, required this.isUser, this.color});

  @override
  Widget build(BuildContext context) {
    final bubbleColor = color ?? (isUser ? AppTheme.primaryBlue : Colors.white);
    final textColor = isUser ? Colors.white : Colors.black87;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor, height: 1.3),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
