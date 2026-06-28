import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ListeningPage extends StatefulWidget {
  const ListeningPage({super.key});
  @override
  State<ListeningPage> createState() => _ListeningPageState();
}

class _ListeningPageState extends State<ListeningPage> {
  String _selectedAccent = 'All';
  bool _isPlaying = false;
  double _progress = 0.0;
  bool _showTranscript = false;
  int? _selectedAnswer;
  bool _answered = false;

  final _accents = ['All', 'British 🇬🇧', 'American 🇺🇸', 'Australian 🇦🇺', 'Canadian 🇨🇦', 'NZ 🇳🇿'];

  final _lessons = [
    {'title': 'A Day in London', 'accent': 'British 🇬🇧', 'level': 'B1', 'duration': '2:15', 'topic': 'Daily Life', 'icon': '🇬🇧'},
    {'title': 'Coffee Shop Order', 'accent': 'American 🇺🇸', 'level': 'A2', 'duration': '1:45', 'topic': 'Shopping', 'icon': '🇺🇸'},
    {'title': 'The Great Barrier Reef', 'accent': 'Australian 🇦🇺', 'level': 'B2', 'duration': '3:00', 'topic': 'Nature', 'icon': '🇦🇺'},
    {'title': 'Job Interview Tips', 'accent': 'Canadian 🇨🇦', 'level': 'B2', 'duration': '2:45', 'topic': 'Business', 'icon': '🇨🇦'},
  ];

  final _questions = [
    {'question': 'What does the speaker say about public transport?', 'options': ['It is very expensive', 'It is unreliable', 'It is the best way to travel', 'It is rarely used'], 'correct': 2},
    {'question': 'What time does the speaker usually wake up?', 'options': ['6:00 AM', '7:30 AM', '8:00 AM', '9:00 AM'], 'correct': 1},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listening Practice'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: Column(
        children: [
          _buildAccentFilter(),
          Expanded(child: ListView(children: [
            _buildFeaturedPlayer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ..._questions.asMap().entries.map((e) => _buildQuestion(e.key, e.value)),
                  const SizedBox(height: 24),
                  const Text('More Lessons', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ..._lessons.skip(1).map((l) => _buildLessonCard(l)),
                ],
              ),
            ),
          ])),
        ],
      ),
    );
  }

  Widget _buildAccentFilter() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _accents.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => setState(() => _selectedAccent = _accents[i]),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _selectedAccent == _accents[i] ? AppColors.primary : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_accents[i], style: TextStyle(color: _selectedAccent == _accents[i] ? Colors.white : Colors.black87, fontSize: 13)),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedPlayer() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF283593), Color(0xFF5C6BC0)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🇬🇧', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('A Day in London', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('British English • B1 Level', style: TextStyle(color: Colors.white70)),
            ]),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
              child: const Text('2:15', style: TextStyle(color: Colors.white))),
          ]),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderThemeData(thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8), overlayShape: const RoundSliderOverlayShape(overlayRadius: 14), trackHeight: 4),
            child: Slider(value: _progress, onChanged: (v) => setState(() => _progress = v), activeColor: Colors.white, inactiveColor: Colors.white30),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${(_progress * 135).toInt()}s', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const Text('2:15', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(icon: const Icon(Icons.replay_10, color: Colors.white, size: 28), onPressed: () {}),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => setState(() => _isPlaying = !_isPlaying),
              child: Container(
                width: 56, height: 56,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: const Color(0xFF283593), size: 32),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(icon: const Icon(Icons.forward_10, color: Colors.white, size: 28), onPressed: () {}),
          ]),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => setState(() => _showTranscript = !_showTranscript),
            icon: Icon(_showTranscript ? Icons.visibility_off : Icons.article, color: Colors.white70),
            label: Text(_showTranscript ? 'Hide Transcript' : 'Show Transcript', style: const TextStyle(color: Colors.white70)),
          ),
          if (_showTranscript) Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
            child: const Text('Good morning! Today I\'m going to tell you about a typical day in London. I usually start my day by taking the underground — which locals call the Tube — to get to work. It\'s the most efficient way to travel in this busy city...', style: TextStyle(color: Colors.white, fontSize: 13, height: 1.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(int idx, Map<String, dynamic> q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Q${idx+1}: ${q['question']}', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...(q['options'] as List<String>).asMap().entries.map((e) {
          Color? bg; Color? border;
          if (_answered) {
            if (e.key == q['correct']) { bg = Colors.green[50]; border = Colors.green; }
            else if (e.key == _selectedAnswer) { bg = Colors.red[50]; border = Colors.red; }
          } else if (e.key == _selectedAnswer) { bg = AppColors.primary.withOpacity(0.08); border = AppColors.primary; }
          return GestureDetector(
            onTap: _answered ? null : () => setState(() => _selectedAnswer = e.key),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bg ?? Colors.grey[50], border: Border.all(color: border ?? Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
              child: Text(e.value),
            ),
          );
        }),
        if (_selectedAnswer != null && !_answered) ElevatedButton(onPressed: () => setState(() => _answered = true), child: const Text('Check Answer')),
        if (_answered) Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: _selectedAnswer == q['correct'] ? Colors.green[50] : Colors.red[50], borderRadius: BorderRadius.circular(8)),
          child: Text(_selectedAnswer == q['correct'] ? '✅ Correct! Well done.' : '❌ Incorrect. The correct answer is: "${(q['options'] as List)[q['correct'] as int]}"', style: TextStyle(color: _selectedAnswer == q['correct'] ? Colors.green[800] : Colors.red[800])),
        ),
      ]),
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> l) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)), child: Center(child: Text(l['icon'] as String, style: const TextStyle(fontSize: 24)))),
        title: Text(l['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${l['accent']} • ${l['level']} • ${l['duration']}', style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.play_circle_outline, color: AppColors.primary, size: 32),
      ),
    );
  }
}
