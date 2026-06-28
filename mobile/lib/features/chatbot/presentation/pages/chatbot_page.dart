import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});
  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _msgs = <Map<String, dynamic>>[
    {'text': 'Hello! I\'m your AI conversation partner. Choose a topic and let\'s practice your English together! 🌟', 'isUser': false},
  ];
  bool _typing = false;

  static const _topics = ['🌍 Travel', '🍕 Food', '💼 Work', '🎬 Movies', '🏃 Sports', '🎓 Education'];

  final _replies = [
    "That's a great point! Can you tell me more about why you think that?",
    "Interesting! I completely agree with you on that. What's your experience?",
    "Great use of vocabulary! Let me add to that — have you ever considered the other perspective?",
    "Excellent! Your English is improving. Now, let's explore this topic further.",
    "Well said! Can you describe that in more detail using different words?",
  ];
  int _replyIndex = 0;

  void _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    setState(() { _msgs.add({'text': text, 'isUser': true}); _typing = true; });
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _typing = false;
      _msgs.add({'text': _replies[_replyIndex % _replies.length], 'isUser': false});
      _replyIndex++;
    });
    await Future.delayed(const Duration(milliseconds: 100));
    _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AI Conversation Partner', style: TextStyle(fontSize: 16)),
          Text('Practice speaking freely', style: TextStyle(fontSize: 12, color: Colors.white70)),
        ]),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      ),
      body: Column(children: [
        SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: _topics.map((t) => GestureDetector(
            onTap: () { _ctrl.text = 'Let\'s talk about $t'; },
            child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withOpacity(0.3))),
              child: Text(t, style: const TextStyle(fontSize: 13))),
          )).toList()),
        ),
        Expanded(child: ListView.builder(
          controller: _scroll, padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _msgs.length + (_typing ? 1 : 0),
          itemBuilder: (_, i) {
            if (i == _msgs.length) return Align(alignment: Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
              child: const Text('...', style: TextStyle(fontSize: 20))));
            final m = _msgs[i];
            final isUser = m['isUser'] as bool;
            return Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                decoration: BoxDecoration(
                  gradient: isUser ? const LinearGradient(colors: [AppColors.primary, AppColors.secondary]) : null,
                  color: isUser ? null : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(m['text'] as String, style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15)),
              ),
            );
          },
        )),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))]),
          child: Row(children: [
            Expanded(child: TextField(controller: _ctrl, decoration: InputDecoration(hintText: 'Type a message...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), filled: true, fillColor: Colors.grey[100], contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)), onSubmitted: (_) => _send())),
            const SizedBox(width: 8),
            FloatingActionButton(onPressed: _send, mini: true, backgroundColor: AppColors.primary, child: const Icon(Icons.send, color: Colors.white)),
          ]),
        ),
      ]),
    );
  }
}
