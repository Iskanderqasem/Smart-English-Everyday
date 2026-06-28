import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SpeakingPage extends StatefulWidget {
  const SpeakingPage({super.key});
  @override
  State<SpeakingPage> createState() => _SpeakingPageState();
}

class _SpeakingPageState extends State<SpeakingPage> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _showResults = false;
  late AnimationController _waveController;

  final List<Map<String, dynamic>> _topics = [
    {'title': 'Introduce Yourself', 'level': 'Beginner', 'duration': '30s', 'prompt': 'Tell us your name, where you are from, and what you do.'},
    {'title': 'Describe Your Home', 'level': 'Elementary', 'duration': '45s', 'prompt': 'Describe the place where you live in detail.'},
    {'title': 'Talk About Technology', 'level': 'Intermediate', 'duration': '60s', 'prompt': 'How has technology changed everyday life in the last 10 years?'},
    {'title': 'Business Presentation', 'level': 'Advanced', 'duration': '90s', 'prompt': 'Present a business idea that solves a real problem.'},
  ];

  int _selectedTopic = 0;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speaking Practice'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _showResults ? _buildResults() : _buildPractice(),
    );
  }

  Widget _buildPractice() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose a Topic', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _topics.length,
              itemBuilder: (context, i) {
                final t = _topics[i];
                final selected = i == _selectedTopic;
                return GestureDetector(
                  onTap: () => setState(() { _selectedTopic = i; _showResults = false; }),
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selected ? AppColors.primary : Colors.grey[200]!),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: selected ? Colors.white24 : Colors.green[50], borderRadius: BorderRadius.circular(8)),
                          child: Text(t['level'], style: TextStyle(fontSize: 11, color: selected ? Colors.white : Colors.green[700]))),
                        const SizedBox(height: 8),
                        Text(t['title'], style: TextStyle(fontWeight: FontWeight.bold, color: selected ? Colors.white : Colors.black)),
                        const Spacer(),
                        Row(children: [
                          Icon(Icons.timer_outlined, size: 14, color: selected ? Colors.white70 : Colors.grey),
                          const SizedBox(width: 4),
                          Text(t['duration'], style: TextStyle(fontSize: 12, color: selected ? Colors.white70 : Colors.grey)),
                        ]),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(Icons.lightbulb_outline, color: Colors.blue), SizedBox(width: 8), Text('Your Prompt', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))]),
                const SizedBox(height: 8),
                Text(_topics[_selectedTopic]['prompt'], style: const TextStyle(fontSize: 16, height: 1.6)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                if (_isRecording) ...[
                  AnimatedBuilder(
                    animation: _waveController,
                    builder: (_, __) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) => Container(
                        width: 6, height: 20 + (_waveController.value * 30 * (i % 3 + 0.5)),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.7 + _waveController.value * 0.3), borderRadius: BorderRadius.circular(3)),
                      )),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Recording...', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                ] else
                  const Text('Tap the microphone to start', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _toggleRecording,
                  child: Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.red : AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: (_isRecording ? Colors.red : AppColors.primary).withOpacity(0.4), blurRadius: 24, spreadRadius: 6)],
                    ),
                    child: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 40),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.tips_and_updates_outlined, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              const Text('Speak clearly and at a natural pace', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final scores = [
      {'label': 'Pronunciation', 'score': 78, 'color': Colors.blue},
      {'label': 'Fluency', 'score': 82, 'color': Colors.green},
      {'label': 'Grammar', 'score': 70, 'color': Colors.orange},
      {'label': 'Vocabulary', 'score': 85, 'color': Colors.purple},
      {'label': 'Confidence', 'score': 75, 'color': Colors.teal},
      {'label': 'Naturalness', 'score': 73, 'color': Colors.red},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle, border: Border.all(color: Colors.green, width: 3)),
                  child: const Center(child: Text('78', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green))),
                ),
                const SizedBox(height: 8),
                const Text('Overall Score', style: TextStyle(color: Colors.grey)),
                const Text('Good! Keep practicing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Skill Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...scores.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              SizedBox(width: 110, child: Text(s['label'] as String)),
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: (s['score'] as int) / 100, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation(s['color'] as Color), minHeight: 10))),
              const SizedBox(width: 8),
              Text('${s['score']}%', style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
          )),
          const SizedBox(height: 20),
          const Text('AI Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(12)),
            child: const Text(
              '✅ Great vocabulary range and confident delivery.\n\n⚠️ Work on pausing between phrases — your speed was slightly fast at times.\n\n💡 Try practicing tongue twisters daily to improve pronunciation clarity.',
              style: TextStyle(height: 1.6),
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.replay), label: const Text('Try Again'), onPressed: () => setState(() { _showResults = false; _isRecording = false; }))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.share), label: const Text('Share Result'), onPressed: () {})),
          ]),
        ],
      ),
    );
  }

  void _toggleRecording() async {
    if (_isRecording) {
      setState(() { _isRecording = false; });
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _showResults = true);
    } else {
      setState(() => _isRecording = true);
    }
  }
}
