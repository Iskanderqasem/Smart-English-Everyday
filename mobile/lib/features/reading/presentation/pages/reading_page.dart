import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ReadingPage extends StatefulWidget {
  const ReadingPage({super.key});
  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  int _selected = -1;
  bool _answered = false;
  final _passages = [
    {
      'title': 'The Power of Habit',
      'level': 'B1',
      'text': 'Habits are powerful forces in our lives. Every day, we perform hundreds of habitual behaviors without thinking consciously. Scientists have discovered that habits form because the brain is always looking for ways to save effort. Once we develop a habit, it becomes automatic.',
      'question': 'Why do habits form according to scientists?',
      'options': ['Because people are lazy', 'Because the brain saves effort', 'Because of peer pressure', 'Due to cultural influence'],
      'answer': 1,
    },
    {
      'title': 'Climate Change',
      'level': 'B2',
      'text': 'Climate change refers to long-term shifts in global temperatures and weather patterns. While natural factors have always influenced climate, scientific evidence shows that human activities have been the main driver of climate change since the 1800s, primarily due to burning fossil fuels.',
      'question': 'What is the main driver of climate change since the 1800s?',
      'options': ['Volcanic eruptions', 'Solar activity', 'Human activities', 'Ocean currents'],
      'answer': 2,
    },
  ];
  int _currentPassage = 0;

  @override
  Widget build(BuildContext context) {
    final p = _passages[_currentPassage];
    final opts = p['options'] as List<String>;
    return Scaffold(
      appBar: AppBar(title: const Text('Reading'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)), child: Text(p['level'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            const SizedBox(width: 8),
            Expanded(child: Text(p['title'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
            child: Text(p['text'] as String, style: const TextStyle(fontSize: 16, height: 1.8)),
          ),
          const SizedBox(height: 24),
          const Text('Comprehension Question', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(p['question'] as String, style: const TextStyle(fontSize: 15, color: Colors.black87)),
          const SizedBox(height: 16),
          ...opts.asMap().entries.map((e) {
            Color? bg; Color? border;
            if (_answered) {
              if (e.key == p['answer']) { bg = Colors.green[50]; border = Colors.green; }
              else if (e.key == _selected) { bg = Colors.red[50]; border = Colors.red; }
            } else if (e.key == _selected) { bg = AppColors.primary.withOpacity(0.08); border = AppColors.primary; }
            return GestureDetector(
              onTap: _answered ? null : () => setState(() => _selected = e.key),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: bg ?? Colors.white, border: Border.all(color: border ?? Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
                child: Text(e.value, style: const TextStyle(fontSize: 15)),
              ),
            );
          }),
          const SizedBox(height: 8),
          if (!_answered && _selected >= 0)
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => setState(() => _answered = true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: const Text('Check Answer')))
          else if (_answered && _currentPassage < _passages.length - 1)
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => setState(() { _currentPassage++; _selected = -1; _answered = false; }), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: const Text('Next Passage'))),
        ]),
      ),
    );
  }
}
