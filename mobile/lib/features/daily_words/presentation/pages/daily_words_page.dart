import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DailyWordsPage extends StatefulWidget {
  const DailyWordsPage({super.key});
  @override
  State<DailyWordsPage> createState() => _DailyWordsPageState();
}

class _DailyWordsPageState extends State<DailyWordsPage> {
  bool _quizMode = false;
  int _quizQuestion = 0;
  int? _selectedAnswer;
  bool _answered = false;

  final _words = [
    {'word': 'Perseverance', 'pronunciation': '/pəˌsɪvɪərəns/', 'pos': 'noun', 'definition': 'Continued effort despite difficulty or delay in achieving success', 'example': 'Her perseverance in learning English finally paid off.', 'synonyms': 'persistence, tenacity, determination', 'antonyms': 'giving up, surrender', 'image': '💪'},
    {'word': 'Eloquent', 'pronunciation': '/ˈeləkwənt/', 'pos': 'adjective', 'definition': 'Fluent or persuasive in speaking or writing', 'example': 'He gave an eloquent speech at the conference.', 'synonyms': 'articulate, fluent, expressive', 'antonyms': 'inarticulate, tongue-tied', 'image': '🗣️'},
    {'word': 'Meticulous', 'pronunciation': '/mɪˈtɪkjələs/', 'pos': 'adjective', 'definition': 'Showing great attention to detail; very careful and precise', 'example': 'She is meticulous in her work, never making mistakes.', 'synonyms': 'careful, precise, thorough', 'antonyms': 'careless, sloppy', 'image': '🔍'},
  ];

  final _quizWords = [
    {'word': 'Perseverance', 'correct': 'Continued effort despite difficulty', 'options': ['Continued effort despite difficulty', 'A type of wild animal', 'Feeling of excitement', 'Moving very quickly']},
    {'word': 'Eloquent', 'correct': 'Fluent and persuasive in speaking', 'options': ['Being very quiet', 'Fluent and persuasive in speaking', 'Very expensive', 'Hard to understand']},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Words'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => setState(() { _quizMode = !_quizMode; _quizQuestion = 0; _selectedAnswer = null; _answered = false; }),
            child: Text(_quizMode ? 'Words' : '🧠 Quiz', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _quizMode ? _buildQuiz() : _buildWordCards(),
    );
  }

  Widget _buildWordCards() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _words.length,
      itemBuilder: (_, i) {
        final w = _words[i];
        final isToday = i == 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: isToday ? const LinearGradient(colors: [AppColors.primary, AppColors.secondary]) : null,
            color: isToday ? null : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (isToday) Align(alignment: Alignment.topRight, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)), child: const Text('Today', style: TextStyle(color: Colors.white, fontSize: 12)))),
              Text(w['image'] as String, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text(w['word'] as String, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isToday ? Colors.white : Colors.black)),
              Text(w['pronunciation'] as String, style: TextStyle(fontSize: 14, color: isToday ? Colors.white70 : Colors.grey)),
              Text(w['pos'] as String, style: TextStyle(fontSize: 13, color: isToday ? Colors.white70 : Colors.blue, fontStyle: FontStyle.italic)),
              const SizedBox(height: 12),
              Text(w['definition'] as String, style: TextStyle(fontSize: 16, height: 1.5, color: isToday ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              Text('"${w['example']}"', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: isToday ? Colors.white70 : Colors.grey)),
              const SizedBox(height: 12),
              Row(children: [
                Icon(Icons.add_circle_outline, size: 16, color: isToday ? Colors.white70 : Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text('Synonyms: ${w['synonyms']}', style: TextStyle(fontSize: 13, color: isToday ? Colors.white70 : Colors.grey))),
              ]),
              Row(children: [
                Icon(Icons.remove_circle_outline, size: 16, color: isToday ? Colors.white70 : Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text('Antonyms: ${w['antonyms']}', style: TextStyle(fontSize: 13, color: isToday ? Colors.white70 : Colors.grey))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                IconButton(icon: Icon(Icons.volume_up, color: isToday ? Colors.white : AppColors.primary), onPressed: () {}),
                IconButton(icon: Icon(Icons.bookmark_border, color: isToday ? Colors.white : AppColors.primary), onPressed: () {}),
                IconButton(icon: Icon(Icons.share_outlined, color: isToday ? Colors.white : AppColors.primary), onPressed: () {}),
              ]),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildQuiz() {
    if (_quizQuestion >= _quizWords.length) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🎉', style: TextStyle(fontSize: 72)),
        const SizedBox(height: 16),
        const Text('Quiz Complete!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('You scored ${_quizQuestion}/${_quizWords.length}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: () => setState(() { _quizQuestion = 0; _selectedAnswer = null; _answered = false; }), child: const Text('Try Again')),
      ]));
    }
    final q = _quizWords[_quizQuestion];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question ${_quizQuestion + 1} of ${_quizWords.length}', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]), borderRadius: BorderRadius.circular(20)),
            child: Text(q['word'] as String, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 24),
          const Text('What does this word mean?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...(q['options'] as List<String>).asMap().entries.map((e) {
            Color? bg; Color? border;
            if (_answered) {
              if (e.value == q['correct']) { bg = Colors.green[50]; border = Colors.green; }
              else if (e.key == _selectedAnswer) { bg = Colors.red[50]; border = Colors.red; }
            } else if (e.key == _selectedAnswer) { bg = AppColors.primary.withOpacity(0.08); border = AppColors.primary; }
            return GestureDetector(
              onTap: _answered ? null : () => setState(() => _selectedAnswer = e.key),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: bg ?? Colors.white, border: Border.all(color: border ?? Colors.grey[300]!), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
                child: Text(e.value, style: const TextStyle(fontSize: 15)),
              ),
            );
          }),
          const Spacer(),
          if (!_answered && _selectedAnswer != null)
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => setState(() => _answered = true), child: const Text('Check Answer')))
          else if (_answered)
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => setState(() { _quizQuestion++; _selectedAnswer = null; _answered = false; }), child: Text(_quizQuestion + 1 < _quizWords.length ? 'Next Word →' : 'See Results'))),
        ],
      ),
    );
  }
}
