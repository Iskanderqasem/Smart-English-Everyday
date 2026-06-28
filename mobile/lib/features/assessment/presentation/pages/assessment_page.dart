import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';

class AssessmentPage extends StatefulWidget {
  const AssessmentPage({super.key});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  int _step = 0;
  bool _isRecording = false;
  bool _isLoading = false;
  final Map<String, dynamic> _answers = {};

  final List<Map<String, dynamic>> _grammarQuestions = [
    {'q': 'She ___ to school every day.', 'options': ['go', 'goes', 'going', 'gone'], 'answer': 1},
    {'q': 'They ___ watching TV when I arrived.', 'options': ['is', 'are', 'was', 'were'], 'answer': 3},
    {'q': 'I have ___ this book before.', 'options': ['read', 'reading', 'reads', 'readed'], 'answer': 0},
    {'q': 'If it rains, we ___ stay inside.', 'options': ['will', 'would', 'shall', 'should'], 'answer': 0},
    {'q': 'She is ___ than her sister.', 'options': ['tall', 'taller', 'tallest', 'more tall'], 'answer': 1},
  ];

  int _currentQuestion = 0;
  List<int?> _selectedAnswers = List.filled(5, null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(child: _buildCurrentStep()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = ['Welcome', 'Reading', 'Listening', 'Writing', 'Grammar', 'Results'];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
      ),
      child: Row(
        children: [
          if (_step > 0 && _step < 5)
            IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => setState(() => _step--)),
          Expanded(
            child: Text(
              titles[_step],
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    if (_step == 0 || _step == 5) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step $_step of 4', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _step / 4,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0: return _buildWelcome();
      case 1: return _buildReadingStep();
      case 2: return _buildListeningStep();
      case 3: return _buildWritingStep();
      case 4: return _buildGrammarStep();
      case 5: return _buildResults();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildWelcome() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          const Text('AI Level Assessment', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          const Text(
            'We\'ll assess your English level across Reading, Listening, Writing, and Grammar to create your personalized learning plan.',
            style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _AssessmentInfoRow(icon: Icons.timer_outlined, text: 'Takes about 15–20 minutes'),
          const SizedBox(height: 12),
          _AssessmentInfoRow(icon: Icons.mic_outlined, text: 'Microphone required for speaking'),
          const SizedBox(height: 12),
          _AssessmentInfoRow(icon: Icons.school_outlined, text: 'Determines your CEFR level (A1–C2)'),
          const SizedBox(height: 12),
          _AssessmentInfoRow(icon: Icons.psychology_outlined, text: 'Estimates IELTS & TOEFL scores'),
          const SizedBox(height: 40),
          CustomButton(
            label: 'Start Assessment',
            onPressed: () => setState(() => _step = 1),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text('Skip for now', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingStep() {
    const passage = '''
The Amazon rainforest, often called the "lungs of the Earth," produces about 20% of the world's oxygen. It spans across nine countries in South America and is home to an estimated 10% of all species on our planet. However, deforestation threatens this vital ecosystem at an alarming rate. Scientists warn that if current trends continue, much of the rainforest could disappear within decades, with catastrophic consequences for global climate and biodiversity.
''';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Read the following passage aloud:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(16)),
            child: const Text(passage, style: TextStyle(fontSize: 16, height: 1.8)),
          ),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _isRecording = !_isRecording),
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: (_isRecording ? Colors.red : AppColors.primary).withOpacity(0.4), blurRadius: 20, spreadRadius: 4)],
                ),
                child: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 36),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text(_isRecording ? 'Recording... Tap to stop' : 'Tap to start recording', style: const TextStyle(color: Colors.grey))),
          const SizedBox(height: 32),
          if (!_isRecording && _answers.containsKey('reading'))
            CustomButton(label: 'Next: Listening →', onPressed: () => setState(() => _step = 2))
          else if (!_isRecording)
            CustomButton(
              label: 'Skip this step',
              onPressed: () => setState(() => _step = 2),
              isOutlined: true,
            ),
        ],
      ),
    );
  }

  Widget _buildListeningStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Listen and answer the questions:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.purple[50], borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(30)),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Audio Sample — British English', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Duration: 1:30', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: 0.4, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation(Colors.purple), minHeight: 6)),
                  ],
                )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Q1: What is the main topic of the audio?', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...['Climate change', 'Technology in education', 'Daily life in London', 'British culture'].asMap().entries.map(
            (e) => RadioListTile<int>(
              value: e.key,
              groupValue: _answers['listening_q1'],
              onChanged: (v) => setState(() => _answers['listening_q1'] = v),
              title: Text(e.value),
              activeColor: AppColors.primary,
            ),
          ),
          const Spacer(),
          CustomButton(label: 'Next: Writing →', onPressed: () => setState(() => _step = 3)),
        ],
      ),
    );
  }

  Widget _buildWritingStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Write 2–3 paragraphs on the topic below:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12)),
            child: const Text('📝 Topic: Describe the benefits and challenges of learning a new language.', style: TextStyle(fontSize: 15, height: 1.5)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              maxLines: null,
              expands: true,
              onChanged: (v) => _answers['writing'] = v,
              decoration: InputDecoration(
                hintText: 'Start writing here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                alignLabelWithHint: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(label: 'Next: Grammar →', onPressed: () => setState(() => _step = 4)),
        ],
      ),
    );
  }

  Widget _buildGrammarStep() {
    final q = _grammarQuestions[_currentQuestion];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question ${_currentQuestion + 1} of ${_grammarQuestions.length}', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Text(q['q'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ...(q['options'] as List<String>).asMap().entries.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedAnswers[_currentQuestion] = e.key),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedAnswers[_currentQuestion] == e.key ? AppColors.primary.withOpacity(0.1) : Colors.white,
                  border: Border.all(color: _selectedAnswers[_currentQuestion] == e.key ? AppColors.primary : Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: _selectedAnswers[_currentQuestion] == e.key ? AppColors.primary : Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text(String.fromCharCode(65 + e.key), style: TextStyle(fontWeight: FontWeight.bold, color: _selectedAnswers[_currentQuestion] == e.key ? Colors.white : Colors.grey))),
                  ),
                  const SizedBox(width: 12),
                  Text(e.value, style: const TextStyle(fontSize: 16)),
                ]),
              ),
            ),
          )),
          const Spacer(),
          if (_currentQuestion < _grammarQuestions.length - 1)
            CustomButton(
              label: 'Next Question →',
              onPressed: _selectedAnswers[_currentQuestion] != null ? () => setState(() => _currentQuestion++) : null,
            )
          else
            CustomButton(
              label: 'Submit & See Results',
              isLoading: _isLoading,
              onPressed: _selectedAnswers[_currentQuestion] != null ? _submitAssessment : null,
            ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text('Assessment Complete!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Here are your results:', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          _ResultCard('CEFR Level', 'B1 — Intermediate', '🏆', Colors.amber),
          const SizedBox(height: 12),
          _ResultCard('IELTS Estimate', '5.5 — Good User', '📋', Colors.blue),
          const SizedBox(height: 12),
          _ResultCard('TOEFL Estimate', '72 / 120', '📊', Colors.green),
          const SizedBox(height: 24),
          const Text('Skill Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _SkillBar('Reading', 0.72, Colors.blue),
          _SkillBar('Listening', 0.65, Colors.purple),
          _SkillBar('Writing', 0.58, Colors.orange),
          _SkillBar('Grammar', 0.80, Colors.green),
          _SkillBar('Vocabulary', 0.68, Colors.teal),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.lightbulb, color: AppColors.primary),
                SizedBox(width: 8),
                Text('AI Recommendation', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ]),
              const SizedBox(height: 8),
              const Text('Focus on writing fluency and listening comprehension. Your grammar foundation is strong — build on it with Level 5 lessons.', style: TextStyle(height: 1.5)),
            ]),
          ),
          const SizedBox(height: 32),
          CustomButton(label: '🚀 Start My Personalized Plan', onPressed: () => context.go('/home')),
        ],
      ),
    );
  }

  void _submitAssessment() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() { _isLoading = false; _step = 5; });
  }
}

class _AssessmentInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _AssessmentInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 15)),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title, value, emoji;
  final Color color;
  const _ResultCard(this.title, this.value, this.emoji, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ]),
      ]),
    );
  }
}

class _SkillBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _SkillBar(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        SizedBox(width: 80, child: Text(label)),
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: value, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation(color), minHeight: 10))),
        const SizedBox(width: 8),
        Text('${(value * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
