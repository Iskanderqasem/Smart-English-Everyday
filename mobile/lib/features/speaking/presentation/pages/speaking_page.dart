import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/speech_recognition_service.dart';

class SpeakingPage extends StatefulWidget {
  const SpeakingPage({super.key});
  @override
  State<SpeakingPage> createState() => _SpeakingPageState();
}

class _SpeakingPageState extends State<SpeakingPage>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _showResults = false;
  late AnimationController _waveController;
  Timer? _timer;
  int _elapsed = 0;
  String _liveTranscript = '';
  String _finalTranscript = '';
  Map<String, dynamic>? _scores;
  String? _errorMsg;
  bool _micGranted = false;

  int _selectedTopic = 0;

  final List<Map<String, dynamic>> _topics = [
    {
      'title': 'Introduce Yourself',
      'level': 'A1',
      'levelColor': Colors.green,
      'duration': '30s',
      'maxSeconds': 30,
      'prompt': 'Tell us your name, where you are from, what you do, and one interesting fact about yourself.',
      'keywords': ['name', 'from', 'work', 'study', 'like', 'hobby', 'live'],
    },
    {
      'title': 'Describe Your Home',
      'level': 'A2',
      'levelColor': Colors.teal,
      'duration': '45s',
      'maxSeconds': 45,
      'prompt': 'Describe the place where you live. Talk about the rooms, the location, and what you like or dislike about it.',
      'keywords': ['room', 'house', 'flat', 'city', 'neighbourhood', 'kitchen', 'bedroom', 'garden'],
    },
    {
      'title': 'Technology in Daily Life',
      'level': 'B1',
      'levelColor': Colors.blue,
      'duration': '60s',
      'maxSeconds': 60,
      'prompt': 'How has technology changed everyday life in the last ten years? Give specific examples.',
      'keywords': ['smartphone', 'internet', 'social', 'communication', 'work', 'changed', 'online', 'digital'],
    },
    {
      'title': 'Discuss a Social Issue',
      'level': 'B2',
      'levelColor': Colors.orange,
      'duration': '90s',
      'maxSeconds': 90,
      'prompt': 'Choose a social issue you feel strongly about — such as climate change, education, or inequality — and explain why it matters and what could be done to address it.',
      'keywords': ['because', 'therefore', 'however', 'important', 'solution', 'government', 'society', 'should'],
    },
    {
      'title': 'Persuasive Argument',
      'level': 'C1',
      'levelColor': Colors.purple,
      'duration': '120s',
      'maxSeconds': 120,
      'prompt': 'Argue for or against the following statement: "Artificial intelligence will do more harm than good to society." Use evidence and logical reasoning to support your position.',
      'keywords': ['argue', 'evidence', 'furthermore', 'contrary', 'nevertheless', 'consequently', 'impact', 'perspective'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _timer?.cancel();
    SpeechRecognitionService.stop();
    super.dispose();
  }

  void _startRecording() {
    if (!SpeechRecognitionService.isAvailable) {
      setState(() => _errorMsg =
          'Speech recognition is not supported in this browser.\nPlease use Google Chrome or Microsoft Edge.');
      return;
    }

    setState(() {
      _isRecording = true;
      _liveTranscript = '';
      _finalTranscript = '';
      _elapsed = 0;
      _errorMsg = null;
      _micGranted = false;
    });

    SpeechRecognitionService.start(
      lang: 'en-US',
      onResult: (transcript, isFinal) {
        if (!mounted) return;
        setState(() {
          _micGranted = true;
          _liveTranscript = transcript;
          if (isFinal) _finalTranscript = transcript;
        });
      },
      onError: (error) {
        if (!mounted) return;
        if (error == 'not-allowed') {
          setState(() {
            _errorMsg = 'Microphone access was denied.\nPlease allow microphone access in your browser settings and try again.';
            _isRecording = false;
          });
          _timer?.cancel();
        } else if (error != 'no-speech') {
          setState(() => _errorMsg = 'Recognition error: $error');
        }
      },
      onEnd: () {
        if (!mounted) return;
        if (_isRecording) {
          SpeechRecognitionService.start(
            lang: 'en-US',
            onResult: (t, f) {
              if (!mounted) return;
              setState(() {
                _micGranted = true;
                _liveTranscript = t;
                if (f) _finalTranscript = t;
              });
            },
            onError: (_) {},
          );
        }
      },
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _elapsed++);
      final maxSec = _topics[_selectedTopic]['maxSeconds'] as int;
      if (_elapsed >= maxSec) _stopRecording();
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    SpeechRecognitionService.stop();
    final text = _liveTranscript.isNotEmpty ? _liveTranscript : _finalTranscript;
    final prompt = _topics[_selectedTopic]['prompt'] as String;
    final result = SpeakingAnalyzer.analyze(text, _elapsed, prompt);

    setState(() {
      _isRecording = false;
      _scores = result;
      _showResults = true;
    });
  }

  void _reset() {
    _timer?.cancel();
    SpeechRecognitionService.stop();
    setState(() {
      _isRecording = false;
      _showResults = false;
      _liveTranscript = '';
      _finalTranscript = '';
      _elapsed = 0;
      _scores = null;
      _errorMsg = null;
    });
  }

  String _formatTime(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speaking Practice', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _showResults ? _buildResults() : _buildPractice(),
    );
  }

  Widget _buildPractice() {
    final topic = _topics[_selectedTopic];
    final maxSec = topic['maxSeconds'] as int;
    final progress = maxSec > 0 ? (_elapsed / maxSec).clamp(0.0, 1.0) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Choose a Topic', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _topics.length,
            itemBuilder: (_, i) {
              final t = _topics[i];
              final sel = i == _selectedTopic;
              return GestureDetector(
                onTap: _isRecording ? null : () => setState(() { _selectedTopic = i; _reset(); }),
                child: Container(
                  width: 155,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: sel ? AppColors.primary : Colors.grey[200]!, width: 1.5),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: sel ? Colors.white24 : (t['levelColor'] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(t['level'] as String,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: sel ? Colors.white : t['levelColor'] as Color)),
                    ),
                    const SizedBox(height: 8),
                    Text(t['title'] as String,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: sel ? Colors.white : Colors.black87)),
                    const Spacer(),
                    Row(children: [
                      Icon(Icons.timer_outlined, size: 13, color: sel ? Colors.white70 : Colors.grey),
                      const SizedBox(width: 4),
                      Text(t['duration'] as String, style: TextStyle(fontSize: 12, color: sel ? Colors.white70 : Colors.grey)),
                    ]),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue[100]!)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: const [
              Icon(Icons.lightbulb_outline, color: Colors.blue, size: 18),
              SizedBox(width: 8),
              Text('Speaking Prompt', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ]),
            const SizedBox(height: 10),
            Text(topic['prompt'] as String, style: const TextStyle(fontSize: 15, height: 1.7, color: Colors.black87)),
          ]),
        ),
        if (_errorMsg != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red[200]!)),
            child: Row(children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(child: Text(_errorMsg!, style: const TextStyle(color: Colors.red, height: 1.5))),
            ]),
          ),
        ],
        const SizedBox(height: 28),
        if (_isRecording) ...[
          Column(children: [
            if (!_micGranted)
              const Text('Waiting for microphone permission…', style: TextStyle(color: Colors.orange, fontSize: 13)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(progress > 0.8 ? Colors.red : AppColors.primary),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(_formatTime(_elapsed), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              Text('/ ${topic['duration']}', style: const TextStyle(color: Colors.grey)),
            ]),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _waveController,
              builder: (_, __) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(7, (i) {
                  final h = 12.0 + (_waveController.value * 28 * ((i % 3 + 1) / 3.0));
                  return Container(
                    width: 5, height: h,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.6 + _waveController.value * 0.4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Listening… speak naturally', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            if (_liveTranscript.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('What I hear:', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(_liveTranscript, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
                ]),
              ),
            ],
          ]),
        ] else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
            child: Column(children: [
              const Row(children: [
                Icon(Icons.tips_and_updates_outlined, color: Colors.amber, size: 18),
                SizedBox(width: 8),
                Text('Tips for best results', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
              ]),
              const SizedBox(height: 10),
              ...[
                'Use Google Chrome or Edge for best microphone support',
                'Speak clearly at a natural pace',
                'Allow microphone access when the browser asks',
                'Try to speak for the full duration shown',
              ].map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('• ', style: TextStyle(color: Colors.grey)),
                  Expanded(child: Text(tip, style: const TextStyle(color: Colors.grey, fontSize: 13))),
                ]),
              )),
            ]),
          ),
        const SizedBox(height: 28),
        Center(
          child: GestureDetector(
            onTap: _isRecording ? _stopRecording : _startRecording,
            child: Column(children: [
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: (_isRecording ? Colors.red : AppColors.primary).withOpacity(0.4),
                    blurRadius: 24, spreadRadius: 6,
                  )],
                ),
                child: Icon(_isRecording ? Icons.stop_rounded : Icons.mic, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 10),
              Text(
                _isRecording ? 'Tap to stop' : 'Tap to start recording',
                style: TextStyle(color: _isRecording ? Colors.red : Colors.grey, fontWeight: FontWeight.w500),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _buildResults() {
    final s = _scores!;
    final overall = s['overall'] as int;
    final transcript = _liveTranscript.isNotEmpty ? _liveTranscript : _finalTranscript;
    final feedback = SpeakingAnalyzer.generateFeedback(s, transcript);
    final topic = _topics[_selectedTopic];

    final Color overallColor = overall >= 75
        ? Colors.green
        : (overall >= 55 ? Colors.orange : Colors.red);
    final String overallLabel = overall >= 80
        ? 'Excellent!'
        : (overall >= 65 ? 'Good! Keep practising' : (overall >= 45 ? 'Keep going!' : 'More practice needed'));

    final scoreItems = [
      {'label': 'Pronunciation', 'key': 'pronunciation', 'color': Colors.blue},
      {'label': 'Fluency', 'key': 'fluency', 'color': Colors.green},
      {'label': 'Grammar', 'key': 'grammar', 'color': Colors.orange},
      {'label': 'Vocabulary', 'key': 'vocabulary', 'color': Colors.purple},
      {'label': 'Confidence', 'key': 'confidence', 'color': Colors.teal},
      {'label': 'Naturalness', 'key': 'naturalness', 'color': Colors.red},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
          child: Column(children: [
            Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                color: overallColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: overallColor, width: 4),
              ),
              child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('$overall', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: overallColor)),
                Text('/ 100', style: TextStyle(fontSize: 11, color: overallColor.withOpacity(0.7))),
              ])),
            ),
            const SizedBox(height: 10),
            const Text('Overall Score', style: TextStyle(color: Colors.grey)),
            Text(overallLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
          ]),
        ),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _StatChip(Icons.timer_outlined, '${_formatTime(_elapsed)} recorded', Colors.blue),
          const SizedBox(width: 10),
          _StatChip(Icons.record_voice_over, '${s['wordCount']} words', Colors.green),
          const SizedBox(width: 10),
          _StatChip(Icons.speed, '${s['wordsPerMinute']} wpm', Colors.orange),
        ]),
        const SizedBox(height: 24),
        const Text('Skill Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 14),
        ...scoreItems.map((item) {
          final score = s[item['key'] as String] as int;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                SizedBox(width: 110, child: Text(item['label'] as String, style: const TextStyle(fontSize: 13, color: Colors.black87))),
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(item['color'] as Color),
                    minHeight: 10,
                  ),
                )),
                const SizedBox(width: 10),
                SizedBox(width: 38, child: Text('$score%', style: TextStyle(fontWeight: FontWeight.bold, color: item['color'] as Color))),
              ]),
            ]),
          );
        }),
        if (transcript.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text('What You Said', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
            child: Text(transcript, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.7, fontStyle: FontStyle.italic)),
          ),
        ],
        const SizedBox(height: 20),
        const Text('AI Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 10),
        ...feedback.map((item) {
          final type = item['type']!;
          final Color bg = type == 'good' ? Colors.green[50]! : (type == 'warn' ? Colors.orange[50]! : Colors.blue[50]!);
          final Color border = type == 'good' ? Colors.green[200]! : (type == 'warn' ? Colors.orange[200]! : Colors.blue[200]!);
          final IconData icon = type == 'good' ? Icons.check_circle_outline : (type == 'warn' ? Icons.warning_amber_rounded : Icons.tips_and_updates_outlined);
          final Color iconColor = type == 'good' ? Colors.green[700]! : (type == 'warn' ? Colors.orange[700]! : Colors.blue[700]!);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(item['text']!, style: TextStyle(color: iconColor, height: 1.5))),
            ]),
          );
        }),
        const SizedBox(height: 20),
        const Text('Next Steps', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            _NextStep(Icons.replay, 'Try this topic again', 'Repeat practice improves your score', () => _reset()),
            const Divider(height: 20),
            _NextStep(Icons.arrow_upward, 'Try a harder topic',
                overall >= 70 ? 'You are ready for the next level!' : 'Build confidence first with this level',
                overall >= 70 ? () { setState(() { if (_selectedTopic < _topics.length - 1) _selectedTopic++; _reset(); }); } : null),
            const Divider(height: 20),
            _NextStep(Icons.menu_book_outlined, 'Study vocabulary', 'Expand your word range for better scores', () => Navigator.pop(context)),
          ]),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  String _formatTime(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    ]),
  );
}

class _NextStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _NextStep(this.icon, this.title, this.subtitle, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: onTap != null ? AppColors.primary.withOpacity(0.1) : Colors.grey[100], borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 20, color: onTap != null ? AppColors.primary : Colors.grey),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: onTap != null ? Colors.black87 : Colors.grey)),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ])),
      if (onTap != null) const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    ]),
  );
}
