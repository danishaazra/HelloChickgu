import 'package:flutter/material.dart';
import '../../shared/theme/theme.dart';
import 'package:hellochickgu/services/gemini_service.dart';

class ChippyChatbotPage extends StatefulWidget {
  const ChippyChatbotPage({super.key});

  @override
  State<ChippyChatbotPage> createState() => _ChippyChatbotPageState();
}

class _ChippyChatbotPageState extends State<ChippyChatbotPage> {
  final TextEditingController _inputController = TextEditingController();
  final List<_Message> _messages = <_Message>[
    const _Message(
      text: 'Hi, I am Chippy, the chatbot.',
      isUser: false,
      color: Color(0xFFF2B266),
    ),
  ];
  bool _sending = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _messages.add(
        _Message(text: text, isUser: true, color: AppTheme.primaryBlue),
      );
      _inputController.clear();
    });
    try {
      final reply = await GeminiService.instance.askChippy(text);
      if (!mounted) return;
      setState(() {
        _messages.add(
          _Message(text: reply, isUser: false, color: const Color(0xFFF2B266)),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _Message(
            text: e.toString(),
            isUser: false,
            color: Colors.red.shade200,
          ),
        );
      });
    } finally {
      if (!mounted) return;
      setState(() => _sending = false);
    }
  }

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
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemBuilder: (context, index) {
                    final m = _messages[index];
                    return _ChatBubble(
                      text: m.text,
                      isUser: m.isUser,
                      color: m.color,
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: _messages.length,
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
                          child: TextField(
                            controller: _inputController,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            decoration: const InputDecoration(
                              hintText: 'Ask anything...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: _sending ? null : _sendMessage,
                        borderRadius: BorderRadius.circular(21),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child:
                              _sending
                                  ? const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Icon(
                                    Icons.arrow_upward,
                                    color: Colors.white,
                                  ),
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

class _Message {
  final String text;
  final bool isUser;
  final Color? color;
  const _Message({required this.text, required this.isUser, this.color});
}
