import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AiTeacherPage extends StatefulWidget {
  const AiTeacherPage({super.key});
  @override
  State<AiTeacherPage> createState() => _AiTeacherPageState();
}

class _AiTeacherPageState extends State<AiTeacherPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isTyping = false;

  final List<Map<String, dynamic>> _messages = [
    {'role': 'ai', 'text': 'Hello! I\'m your AI English Teacher 👋 I\'m here 24/7 to help you with grammar, vocabulary, pronunciation, writing, speaking, and anything else you need. What would you like to learn today?'},
  ];

  final _quickQuestions = [
    'Explain the Present Perfect tense',
    'What is the difference between "affect" and "effect"?',
    'How do I use phrasal verbs?',
    'Correct my grammar: "She don\'t like apples"',
    'Give me 5 business idioms',
    'How to improve my accent?',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(18)),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 20)))),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI English Teacher', style: TextStyle(color: Colors.white, fontSize: 16)),
            Text('Always available', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ]),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) return _buildTypingIndicator();
                final m = _messages[i];
                return _ChatBubble(isAi: m['role'] == 'ai', text: m['text']);
              },
            ),
          ),
          if (_messages.length == 1) _buildQuickQuestions(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildQuickQuestions() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickQuestions.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _sendMessage(_quickQuestions[i]),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withOpacity(0.3))),
            child: Text(_quickQuestions[i], style: const TextStyle(color: AppColors.primary, fontSize: 13)),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4))]),
      child: Row(children: [
        IconButton(icon: const Icon(Icons.mic_outlined, color: AppColors.primary), onPressed: () {}),
        Expanded(
          child: TextField(
            controller: _msgCtrl,
            decoration: InputDecoration(
              hintText: 'Ask your teacher anything...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onSubmitted: (v) { if (v.isNotEmpty) _sendMessage(v); },
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () { if (_msgCtrl.text.isNotEmpty) _sendMessage(_msgCtrl.text); },
          child: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(22)),
            child: const Icon(Icons.send, color: Colors.white, size: 20)),
        ),
      ]),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(right: 60, bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(18).copyWith(bottomLeft: Radius.zero)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          ...List.generate(3, (i) => Container(width: 8, height: 8, margin: EdgeInsets.only(right: i < 2 ? 4 : 0), decoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle))),
        ]),
      ),
    );
  }

  void _sendMessage(String text) async {
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _msgCtrl.clear();
      _isTyping = true;
    });
    _scrollToBottom();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add({'role': 'ai', 'text': _generateResponse(text)});
    });
    _scrollToBottom();
  }

  String _generateResponse(String question) {
    if (question.toLowerCase().contains('present perfect')) {
      return 'The **Present Perfect** tense is used to describe:\n\n1️⃣ Actions that happened at an unspecified time in the past:\n*"I have visited Paris."*\n\n2️⃣ Actions that started in the past and continue now:\n*"She has lived here for 5 years."*\n\n3️⃣ Recent actions with present relevance:\n*"He has just finished his homework."*\n\n**Structure:** Subject + have/has + past participle\n\nWould you like some practice exercises? 😊';
    }
    if (question.toLowerCase().contains('affect') && question.toLowerCase().contains('effect')) {
      return '"**Affect**" and "**Effect**" are commonly confused!\n\n🔵 **Affect** (verb) = to influence or impact something\n*"The rain affected our plans."*\n\n🟢 **Effect** (noun) = the result or outcome\n*"The effect of rain was that we stayed home."*\n\n💡 **Memory tip:** "**A**ffect is the **A**ction, **E**ffect is the **E**nd result"';
    }
    return 'Great question! As your AI English teacher, I\'m analyzing your question and preparing a comprehensive answer with examples, exercises, and tips tailored to your B1 level. 📚\n\nI can also provide audio pronunciation guides, grammar exercises, and real-world usage examples. Keep asking — every question helps you improve! 🚀';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }
}

class _ChatBubble extends StatelessWidget {
  final bool isAi;
  final String text;
  const _ChatBubble({required this.isAi, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(right: isAi ? 60 : 0, left: isAi ? 0 : 60, bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isAi ? Colors.grey[100] : AppColors.primary,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomLeft: isAi ? Radius.zero : const Radius.circular(18),
            bottomRight: isAi ? const Radius.circular(18) : Radius.zero,
          ),
        ),
        child: Text(text, style: TextStyle(color: isAi ? Colors.black87 : Colors.white, fontSize: 14, height: 1.5)),
      ),
    );
  }
}
