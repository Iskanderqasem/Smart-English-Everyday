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

    _startListening();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _elapsed++);
      final maxSec = _topics[_selectedTopic]['maxSeconds'] as int;
      if (_elapsed >= maxSec) _stopRecording();
    });
  }

  void _startListening() {
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
            _errorMsg =
                'Microphone access was denied.\nOpen your browser address bar, tap the lock/info icon, and allow the Microphone permission. Then try again.';
            _isRecording = false;
          });
          _timer?.cancel();
        } else if (error == 'network') {
          setState(() => _errorMsg =
              'Network error — speech recognition needs an internet connection. Please check your connection.');
        } else if (error != 'no-speech' && error != 'aborted') {
          setState(() => _errorMsg = 'Microphone error: $error');
        }
      },
      onEnd: () {
        // Browser stops after a pause — restart automatically while still recording
        if (!mounted || !_isRecording) return;
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted && _isRecording) _startListening();
        });
      },
    );
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
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8, runSpacing: 8,
          children: [
            _StatChip(Icons.timer_outlined, '${_formatTime(_elapsed)} recorded', Colors.blue),
            _StatChip(Icons.record_voice_over, '${s['wordCount']} words', Colors.green),
            _StatChip(Icons.speed, '${s['wordsPerMinute']} wpm', Colors.orange),
            _StatChip(Icons.school, 'CEFR: ${s['cefrLevel']}', AppColors.primary),
            _StatChip(Icons.auto_awesome, '${s['uniqueWords']} unique words', Colors.purple),
            _StatChip(Icons.link, '${s['connectiveCount']} connectives', Colors.teal),
          ],
        ),
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

// ─── Speaking Analyzer ────────────────────────────────────────────────────────
// Analyzes a speech transcript and returns CEFR-aligned scores (0–100) with
// detailed, actionable feedback for each dimension.

class SpeakingAnalyzer {
  static const _fillers = ['um', 'uh', 'er', 'like', 'you know', 'basically',
      'literally', 'sort of', 'kind of', 'i mean', 'right', 'okay so'];

  static const _connectives = [
    'however', 'therefore', 'furthermore', 'nevertheless', 'consequently',
    'moreover', 'although', 'despite', 'whereas', 'on the other hand',
    'in addition', 'as a result', 'for instance', 'for example', 'in contrast',
    'similarly', 'in conclusion', 'to summarise', 'firstly', 'secondly',
    'finally', 'additionally', 'subsequently', 'because', 'since', 'although',
    'even though', 'in order to', 'so that', 'as long as',
  ];

  static const _pastMarkers = ['was', 'were', 'had', 'did', 'went', 'said',
      'told', 'came', 'took', 'made', 'got', 'knew', 'thought', 'felt',
      'became', 'began', 'brought', 'bought', 'built', 'caught', 'chose',
      'could', 'would', 'should', 'might', 'must'];

  static const _conditionals = ['if ', 'unless ', 'provided that', 'as long as',
      'would have', 'could have', 'might have', 'should have', 'had been',
      'were to ', 'supposing'];

  static const _passiveMarkers = [' is ', ' are ', ' was ', ' were ', ' been ',
      ' being '];

  static const _advancedVocab = [
    'significant', 'considerable', 'substantial', 'demonstrate', 'indicate',
    'suggest', 'contribute', 'emphasise', 'highlight', 'crucial', 'essential',
    'fundamental', 'perspective', 'approach', 'implementation', 'consequence',
    'impact', 'influence', 'facilitate', 'acknowledge', 'elaborate', 'clarify',
    'perceive', 'assume', 'analyse', 'evaluate', 'distinguish', 'associate',
    'attribute', 'incorporate', 'generate', 'maintain', 'obtain', 'require',
    'involve', 'establish', 'identify', 'examine', 'investigate',
  ];

  /// Returns a map with keys: pronunciation, fluency, grammar, vocabulary,
  /// confidence, naturalness, overall, wordCount, wordsPerMinute,
  /// uniqueWords, fillerCount, connectiveCount, cefrLevel
  static Map<String, dynamic> analyze(String text, int seconds, String prompt) {
    if (text.trim().isEmpty) {
      return {
        'pronunciation': 0, 'fluency': 0, 'grammar': 0, 'vocabulary': 0,
        'confidence': 0, 'naturalness': 0, 'overall': 0,
        'wordCount': 0, 'wordsPerMinute': 0, 'uniqueWords': 0,
        'fillerCount': 0, 'connectiveCount': 0, 'cefrLevel': 'Not assessed',
      };
    }

    final lower = text.toLowerCase();
    final words = lower.split(RegExp(r'\s+')).where((w) => w.length > 1).toList();
    final wordCount = words.length;
    final uniqueWords = words.toSet().length;
    final elapsed = seconds < 5 ? 5 : seconds;
    final wpm = ((wordCount / elapsed) * 60).round();

    // ── Filler word count ────────────────────────────────────────────────
    int fillerCount = 0;
    for (final f in _fillers) {
      final re = RegExp(r'\b' + RegExp.escape(f) + r'\b');
      fillerCount += re.allMatches(lower).length;
    }

    // ── Connective / discourse marker count ──────────────────────────────
    int connectiveCount = 0;
    for (final c in _connectives) {
      if (lower.contains(c)) connectiveCount++;
    }

    // ── Grammar: past tense, conditionals, passive voice ─────────────────
    int pastCount = 0;
    for (final m in _pastMarkers) {
      pastCount += RegExp(r'\b' + RegExp.escape(m) + r'\b').allMatches(lower).length;
    }
    int conditionalCount = 0;
    for (final c in _conditionals) {
      if (lower.contains(c)) conditionalCount++;
    }
    int passiveCount = 0;
    for (final p in _passiveMarkers) {
      if (lower.contains(p)) passiveCount++;
    }
    final sentences = text.split(RegExp(r'[.!?]+')).where((s) => s.trim().isNotEmpty).length;
    final avgSentenceLen = sentences > 0 ? wordCount / sentences : wordCount.toDouble();

    // ── Advanced vocabulary count ─────────────────────────────────────────
    int advancedCount = 0;
    for (final v in _advancedVocab) {
      if (lower.contains(v)) advancedCount++;
    }

    // ── Topic relevance ────────────────────────────────────────────────────
    // Count how many prompt words appear in the transcript
    final promptWords = prompt.toLowerCase()
        .split(RegExp(r'\W+'))
        .where((w) => w.length > 4)
        .toSet();
    int topicHits = 0;
    for (final w in promptWords) {
      if (lower.contains(w)) topicHits++;
    }
    final topicRelevance = promptWords.isEmpty ? 1.0 : (topicHits / promptWords.length).clamp(0.0, 1.0);

    // ── Vocabulary diversity (Type-Token Ratio) ────────────────────────────
    final ttr = wordCount > 0 ? uniqueWords / wordCount : 0.0;

    // ─────────────────── SCORING ──────────────────────────────────────────

    // FLUENCY (wpm, filler rate, pause-inferred from sentence length variance)
    int fluency;
    if (wpm < 60) fluency = 30;
    else if (wpm < 90) fluency = 50;
    else if (wpm <= 130) fluency = 70;
    else if (wpm <= 160) fluency = 85;
    else fluency = 75; // too fast

    final fillerRate = wordCount > 0 ? fillerCount / wordCount : 0;
    if (fillerRate > 0.15) fluency -= 20;
    else if (fillerRate > 0.08) fluency -= 10;
    else if (fillerRate < 0.03) fluency += 5;
    fluency = fluency.clamp(10, 100);

    // GRAMMAR (sentence complexity, past tense usage, conditionals, passive)
    int grammar = 40;
    if (avgSentenceLen >= 8) grammar += 15;
    if (avgSentenceLen >= 12) grammar += 10;
    if (pastCount >= 3) grammar += 10;
    if (conditionalCount >= 1) grammar += 15;
    if (conditionalCount >= 2) grammar += 5;
    if (passiveCount >= 2) grammar += 5;
    if (sentences >= 4) grammar += 5;
    grammar = grammar.clamp(20, 100);

    // VOCABULARY (TTR, advanced words, topic relevance)
    int vocabulary = 35;
    if (ttr >= 0.5) vocabulary += 15;
    else if (ttr >= 0.4) vocabulary += 10;
    else if (ttr >= 0.3) vocabulary += 5;
    vocabulary += (advancedCount * 6).clamp(0, 30);
    vocabulary += (topicRelevance * 15).round();
    if (wordCount >= 80) vocabulary += 5;
    vocabulary = vocabulary.clamp(20, 100);

    // CONFIDENCE (word count relative to max, speaking started, coverage)
    int confidence;
    if (wordCount < 20) confidence = 30;
    else if (wordCount < 50) confidence = 50;
    else if (wordCount < 100) confidence = 65;
    else if (wordCount < 150) confidence = 78;
    else confidence = 88;
    if (fillerRate < 0.05) confidence += 5;
    confidence = confidence.clamp(20, 100);

    // NATURALNESS (connectives, sentence variety, wpm range)
    int naturalness = 45;
    naturalness += (connectiveCount * 5).clamp(0, 25);
    if (wpm >= 110 && wpm <= 150) naturalness += 15;
    if (avgSentenceLen >= 7 && avgSentenceLen <= 18) naturalness += 10;
    if (fillerRate < 0.05) naturalness += 5;
    naturalness = naturalness.clamp(20, 100);

    // PRONUNCIATION — we can only infer this from word count (more words =
    // recogniser understood more) and speaking rate; actual phoneme scoring
    // needs a server-side model, so we estimate conservatively.
    int pronunciation = 50;
    if (wordCount >= 30) pronunciation += 10;
    if (wordCount >= 70) pronunciation += 10;
    if (wpm >= 90 && wpm <= 160) pronunciation += 10;
    pronunciation += (topicRelevance * 10).round();
    pronunciation = pronunciation.clamp(30, 88); // cap at 88 since we can't do true phoneme check

    // OVERALL weighted average
    final overall = ((pronunciation * 0.15) + (fluency * 0.20) + (grammar * 0.25) +
        (vocabulary * 0.20) + (confidence * 0.10) + (naturalness * 0.10)).round();

    // CEFR mapping
    String cefr;
    if (overall >= 85) cefr = 'C1–C2';
    else if (overall >= 70) cefr = 'B2';
    else if (overall >= 55) cefr = 'B1';
    else if (overall >= 40) cefr = 'A2';
    else cefr = 'A1';

    return {
      'pronunciation': pronunciation,
      'fluency': fluency,
      'grammar': grammar,
      'vocabulary': vocabulary,
      'confidence': confidence,
      'naturalness': naturalness,
      'overall': overall,
      'wordCount': wordCount,
      'wordsPerMinute': wpm,
      'uniqueWords': uniqueWords,
      'fillerCount': fillerCount,
      'connectiveCount': connectiveCount,
      'cefrLevel': cefr,
      // raw metrics exposed for feedback
      '_ttr': ttr,
      '_avgSentLen': avgSentenceLen,
      '_advancedCount': advancedCount,
      '_conditionalCount': conditionalCount,
      '_topicRelevance': topicRelevance,
    };
  }

  /// Returns a list of feedback cards: [{'type': 'good'|'warn'|'tip', 'text': '...'}]
  static List<Map<String, String>> generateFeedback(
      Map<String, dynamic> s, String transcript) {
    final feedback = <Map<String, String>>[];
    final wpm = s['wordsPerMinute'] as int;
    final wordCount = s['wordCount'] as int;
    final uniqueWords = s['uniqueWords'] as int;
    final fillerCount = s['fillerCount'] as int;
    final connectiveCount = s['connectiveCount'] as int;
    final ttr = s['_ttr'] as double? ?? 0;
    final avgSentLen = s['_avgSentLen'] as double? ?? 0;
    final advancedCount = s['_advancedCount'] as int? ?? 0;
    final conditionals = s['_conditionalCount'] as int? ?? 0;
    final topicRel = s['_topicRelevance'] as double? ?? 0;
    final cefr = s['cefrLevel'] as String;
    final overall = s['overall'] as int;

    // Overall CEFR result
    feedback.add({'type': 'tip', 'text': 'Estimated CEFR level: $cefr  •  Overall score: $overall/100'});

    // Speaking speed
    if (wpm < 70) {
      feedback.add({'type': 'warn', 'text': 'Speaking pace: $wpm words/min — this is quite slow. Aim for 110–150 wpm for natural conversation. Practise reading aloud to build speed.'});
    } else if (wpm > 170) {
      feedback.add({'type': 'warn', 'text': 'Speaking pace: $wpm words/min — this is very fast. Slow down slightly to improve clarity. Aim for 110–150 wpm.'});
    } else if (wpm >= 110 && wpm <= 150) {
      feedback.add({'type': 'good', 'text': 'Great speaking pace: $wpm words/min — this is natural and easy to follow.'});
    } else {
      feedback.add({'type': 'tip', 'text': 'Speaking pace: $wpm words/min. The ideal range is 110–150 wpm for clear English speech.'});
    }

    // Word count / effort
    if (wordCount < 30) {
      feedback.add({'type': 'warn', 'text': 'Only $wordCount words detected. Try to speak for the full duration — longer responses show more language ability.'});
    } else if (wordCount >= 100) {
      feedback.add({'type': 'good', 'text': 'Good response length: $wordCount words. This gives enough material to assess your English properly.'});
    }

    // Vocabulary diversity
    final ttrPct = (ttr * 100).round();
    if (ttr >= 0.55) {
      feedback.add({'type': 'good', 'text': 'Excellent vocabulary diversity: $uniqueWords unique words out of $wordCount ($ttrPct%). You avoid repeating the same words — a C1/C2 strength.'});
    } else if (ttr >= 0.40) {
      feedback.add({'type': 'tip', 'text': 'Good vocabulary range: $ttrPct% unique words. To reach B2/C1, try to vary your words more — use synonyms instead of repeating the same terms.'});
    } else {
      feedback.add({'type': 'warn', 'text': 'Limited vocabulary variety: only $ttrPct% unique words. This is typical of A2–B1. Try to expand your vocabulary by learning synonyms and topic-specific words.'});
    }

    // Advanced vocabulary
    if (advancedCount >= 4) {
      feedback.add({'type': 'good', 'text': 'Strong academic/advanced vocabulary detected ($advancedCount advanced words). This is characteristic of B2+ speakers.'});
    } else if (advancedCount == 0) {
      feedback.add({'type': 'tip', 'text': 'Try to include more varied, formal vocabulary. Words like "significant", "demonstrate", "highlight", "crucial" raise your level from A2/B1 to B2/C1.'});
    }

    // Grammar complexity
    if (avgSentLen >= 12) {
      feedback.add({'type': 'good', 'text': 'Complex sentence structure: average ${avgSentLen.toStringAsFixed(1)} words per sentence. Long, well-formed sentences indicate B2+ grammar control.'});
    } else if (avgSentLen < 7) {
      feedback.add({'type': 'warn', 'text': 'Short sentences detected (avg ${avgSentLen.toStringAsFixed(1)} words). Try connecting ideas with "because", "although", "which means that" to build more complex sentences.'});
    }

    // Conditionals (key B2+ marker)
    if (conditionals >= 2) {
      feedback.add({'type': 'good', 'text': 'You used conditional structures (if/would/could have) — this is an important marker of B2–C1 grammar range.'});
    } else if (conditionals == 0) {
      feedback.add({'type': 'tip', 'text': 'Consider using conditional sentences: "If this continues, it will…" or "It would be better if…". This is a key B2 grammar feature.'});
    }

    // Discourse connectives
    if (connectiveCount >= 5) {
      feedback.add({'type': 'good', 'text': 'Excellent use of discourse markers ($connectiveCount connectives like however/therefore/furthermore). This makes your speech structured and coherent — a C1 quality.'});
    } else if (connectiveCount >= 2) {
      feedback.add({'type': 'tip', 'text': 'You used $connectiveCount discourse markers. Add more: "Furthermore", "On the other hand", "As a result" to link ideas and reach B2 coherence standards.'});
    } else {
      feedback.add({'type': 'warn', 'text': 'Few or no discourse markers detected. Use words like "However", "Therefore", "In addition" to connect your ideas. This is essential for B1 and above.'});
    }

    // Filler words
    if (fillerCount == 0) {
      feedback.add({'type': 'good', 'text': 'No filler words (um/uh/like) detected. Your speech sounds fluent and prepared.'});
    } else if (fillerCount <= 3) {
      feedback.add({'type': 'tip', 'text': '$fillerCount filler word(s) detected. A small number is natural. To reduce them, pause silently instead of saying "um" or "uh".'});
    } else {
      feedback.add({'type': 'warn', 'text': '$fillerCount filler words detected (um/uh/like/you know). Too many fillers reduce fluency. Practise pausing instead — a 1-second pause sounds more professional than "uh".'});
    }

    // Topic relevance
    if (topicRel >= 0.6) {
      feedback.add({'type': 'good', 'text': 'Good topic relevance — you addressed the prompt directly and stayed on topic.'});
    } else if (topicRel < 0.3 && wordCount > 30) {
      feedback.add({'type': 'warn', 'text': 'Your answer didn\'t address the prompt closely. Make sure you directly answer the question asked — examiners score for task completion.'});
    }

    // CEFR-level specific advice
    if (overall < 45) {
      feedback.add({'type': 'tip', 'text': 'Focus on A1–A2 basics: simple present and past tense, everyday vocabulary (50–500 words), and short clear sentences. Listen to native speakers at slow speed (BBC Learning English).'});
    } else if (overall < 60) {
      feedback.add({'type': 'tip', 'text': 'You\'re at B1 level. To reach B2: use more varied tenses (present perfect, conditionals), expand your vocabulary with academic words, and practise speaking for 60–90 seconds on a topic.'});
    } else if (overall < 75) {
      feedback.add({'type': 'tip', 'text': 'You\'re at B2 level. To reach C1: master complex grammar (passive, reported speech, inversion), use sophisticated discourse markers, and practise giving structured arguments.'});
    } else {
      feedback.add({'type': 'good', 'text': 'Strong performance! You\'re demonstrating C1–C2 characteristics. Continue refining idiomatic usage and nuanced vocabulary to polish your proficiency.'});
    }

    return feedback;
  }
}
