import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';

class WritingPage extends StatefulWidget {
  const WritingPage({super.key});
  @override
  State<WritingPage> createState() => _WritingPageState();
}

class _WritingPageState extends State<WritingPage> {
  final _textCtrl = TextEditingController();
  int _selectedTopic = 0;
  bool _showResults = false;
  bool _isAnalyzing = false;
  _Analysis? _analysis;

  final _topics = [
    {'title': 'My Family',          'level': 'A1', 'desc': 'Describe your family members and your relationship with them.'},
    {'title': 'Technology',         'level': 'B1', 'desc': 'How has technology changed our daily lives in the past decade?'},
    {'title': 'Climate Change',     'level': 'B2', 'desc': 'What solutions can individuals and governments adopt to tackle climate change?'},
    {'title': 'Future of Education','level': 'C1', 'desc': 'Discuss how AI and technology will transform education in the next 20 years.'},
  ];

  @override
  void dispose() { _textCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Writing Practice'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: _showResults ? _buildResults() : _buildEditor(),
    );
  }

  // ── Editor ────────────────────────────────────────────────────────────────

  Widget _buildEditor() {
    return Column(children: [
      SizedBox(
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          itemCount: _topics.length,
          itemBuilder: (_, i) {
            final t = _topics[i];
            final sel = i == _selectedTopic;
            return GestureDetector(
              onTap: () => setState(() { _selectedTopic = i; _textCtrl.clear(); }),
              child: Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: sel ? AppColors.primary : Colors.grey[200]!),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: sel ? Colors.white24 : Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                    child: Text(t['level']!, style: TextStyle(fontSize: 11, color: sel ? Colors.white : Colors.blue[700])),
                  ),
                  const SizedBox(height: 6),
                  Text(t['title']!, style: TextStyle(fontWeight: FontWeight.bold, color: sel ? Colors.white : Colors.black, fontSize: 14)),
                ]),
              ),
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12)),
          child: Text('📝 ${_topics[_selectedTopic]['desc']}', style: const TextStyle(fontSize: 14, height: 1.5)),
        ),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _textCtrl,
            maxLines: null,
            expands: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Start writing here… (aim for 2–3 paragraphs)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              alignLabelWithHint: true,
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${_wordCount} words', style: const TextStyle(color: Colors.grey)),
            Text('${_textCtrl.text.length} characters', style: const TextStyle(color: Colors.grey)),
          ]),
          const SizedBox(height: 12),
          CustomButton(
            label: '✨ Analyse My Writing',
            isLoading: _isAnalyzing,
            onPressed: _textCtrl.text.length > 20 ? _analyseWriting : null,
          ),
        ]),
      ),
    ]);
  }

  int get _wordCount => _textCtrl.text.trim().isEmpty
      ? 0
      : _textCtrl.text.trim().split(RegExp(r'\s+')).length;

  // ── Analysis ──────────────────────────────────────────────────────────────

  void _analyseWriting() async {
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(seconds: 1));
    final result = _Analysis.analyse(_textCtrl.text);
    if (mounted) setState(() { _isAnalyzing = false; _analysis = result; _showResults = true; });
  }

  // ── Results ───────────────────────────────────────────────────────────────

  Widget _buildResults() {
    final a = _analysis!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('AI Analysis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          TextButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
            onPressed: () => setState(() => _showResults = false),
          ),
        ]),
        const SizedBox(height: 16),

        // Scores
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _ScoreCircle('Overall', a.overall, Colors.green),
          _ScoreCircle('Grammar', a.grammar, Colors.blue),
          _ScoreCircle('Vocab',   a.vocab,   Colors.purple),
          _ScoreCircle('Style',   a.style,   Colors.orange),
        ]),
        const SizedBox(height: 20),

        // Stats row
        Row(children: [
          _StatBadge('${a.wordCount} words',    Colors.teal),
          const SizedBox(width: 8),
          _StatBadge('${a.sentenceCount} sentences', Colors.indigo),
          const SizedBox(width: 8),
          _StatBadge('${a.uniqueWords} unique words', Colors.pink),
        ]),
        const SizedBox(height: 20),

        // User's text with highlights
        const Text('Your Text (with notes)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
          child: RichText(text: TextSpan(style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.7), children: a.annotatedSpans)),
        ),
        const SizedBox(height: 20),

        // Feedback
        const Text('AI Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('✅ Strengths', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 6),
            ...a.strengths.map((s) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• $s', style: const TextStyle(height: 1.5)))),
            const SizedBox(height: 12),
            const Text('⚠️ Areas to Improve', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 6),
            ...a.improvements.map((s) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• $s', style: const TextStyle(height: 1.5)))),
          ]),
        ),
        const SizedBox(height: 20),

        Row(children: [
          Expanded(child: OutlinedButton.icon(
            icon: const Icon(Icons.replay),
            label: const Text('Try Again'),
            onPressed: () => setState(() { _showResults = false; _textCtrl.clear(); }),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton.icon(
            icon: const Icon(Icons.edit_note),
            label: const Text('Improve It'),
            onPressed: () => setState(() => _showResults = false),
          )),
        ]),
      ]),
    );
  }
}

// ── Analysis engine ───────────────────────────────────────────────────────────

class _Analysis {
  final int overall, grammar, vocab, style;
  final int wordCount, sentenceCount, uniqueWords;
  final List<TextSpan> annotatedSpans;
  final List<String> strengths, improvements;

  const _Analysis({
    required this.overall, required this.grammar, required this.vocab, required this.style,
    required this.wordCount, required this.sentenceCount, required this.uniqueWords,
    required this.annotatedSpans, required this.strengths, required this.improvements,
  });

  static _Analysis analyse(String text) {
    final trimmed = text.trim();
    final words = trimmed.isEmpty ? <String>[] : trimmed.split(RegExp(r'\s+'));
    final wordCount = words.length;
    final uniqueWords = words.map((w) => w.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '')).where((w) => w.isNotEmpty).toSet().length;
    final sentences = trimmed.split(RegExp(r'[.!?]+\s*')).where((s) => s.trim().isNotEmpty).toList();
    final sentenceCount = sentences.isEmpty ? 1 : sentences.length;

    // Grammar score: based on avg sentence length and punctuation
    final avgLen = wordCount / sentenceCount;
    int grammarScore = 55;
    if (avgLen >= 8 && avgLen <= 25) grammarScore += 20;
    if (trimmed.contains(RegExp(r'[.!?]'))) grammarScore += 10;
    if (!trimmed.contains(RegExp(r'\bi\b'))) grammarScore += 5; // no lowercase "i"
    if (trimmed[0] == trimmed[0].toUpperCase()) grammarScore += 5;
    final errorCount = _countErrors(trimmed);
    grammarScore = (grammarScore - errorCount * 4).clamp(30, 98);

    // Vocab score: diversity + word length
    final diversity = wordCount > 0 ? uniqueWords / wordCount : 0.0;
    final avgWordLen = wordCount > 0 ? words.map((w) => w.length).reduce((a, b) => a + b) / wordCount : 0.0;
    int vocabScore = (diversity * 100).round().clamp(30, 70);
    if (avgWordLen > 5) vocabScore = (vocabScore + 15).clamp(30, 98);
    if (avgWordLen > 6.5) vocabScore = (vocabScore + 10).clamp(30, 98);

    // Style score: connectors, paragraphs, varied length
    int styleScore = 50;
    final connectors = ['however', 'therefore', 'furthermore', 'moreover', 'although', 'consequently', 'nevertheless', 'in addition', 'on the other hand', 'for example', 'in conclusion', 'firstly', 'secondly', 'finally'];
    final lc = trimmed.toLowerCase();
    final connectorCount = connectors.where((c) => lc.contains(c)).length;
    styleScore += (connectorCount * 8).clamp(0, 30);
    if (trimmed.contains('\n')) styleScore += 10;
    if (sentenceCount >= 4) styleScore += 8;
    styleScore = styleScore.clamp(30, 98);

    // Word count bonus
    int wordBonus = 0;
    if (wordCount >= 50) wordBonus = 5;
    if (wordCount >= 100) wordBonus = 10;
    if (wordCount >= 200) wordBonus = 15;

    final overall = ((grammarScore * 0.35 + vocabScore * 0.30 + styleScore * 0.35) + wordBonus).round().clamp(20, 98);

    // Annotations
    final spans = _buildSpans(trimmed, _findErrors(trimmed));

    // Feedback
    final strengths = <String>[];
    final improvements = <String>[];

    if (wordCount >= 100) strengths.add('Good length — $wordCount words shows strong effort.');
    if (diversity >= 0.6) strengths.add('Strong vocabulary diversity (${(diversity*100).round()}% unique words).');
    if (connectorCount >= 2) strengths.add('Good use of connectors to link ideas.');
    if (sentenceCount >= 4) strengths.add('Well-structured response with multiple sentences.');
    if (avgWordLen > 6) strengths.add('You used some complex vocabulary — well done!');
    if (strengths.isEmpty) strengths.add('You made a good start — keep practising!');

    if (wordCount < 50) improvements.add('Aim for at least 50–100 words to fully develop your ideas.');
    if (diversity < 0.5) improvements.add('Try to vary your vocabulary — avoid repeating the same words.');
    if (connectorCount == 0) improvements.add('Add linking words (however, therefore, furthermore) to connect ideas smoothly.');
    if (!trimmed.contains('\n') && wordCount > 60) improvements.add('Break your text into paragraphs for better readability.');
    if (avgLen < 6) improvements.add('Write longer sentences to express more complete ideas.');
    if (avgLen > 30) improvements.add('Some sentences are very long — try breaking them up for clarity.');
    if (errorCount > 0) improvements.add('Check subject-verb agreement and spelling of highlighted words.');
    if (improvements.isEmpty) improvements.add('Work on adding more advanced vocabulary and complex sentence structures.');

    return _Analysis(
      overall: overall, grammar: grammarScore, vocab: vocabScore, style: styleScore,
      wordCount: wordCount, sentenceCount: sentenceCount, uniqueWords: uniqueWords,
      annotatedSpans: spans, strengths: strengths, improvements: improvements,
    );
  }

  // Simple common-error detection
  static const _errors = {
    r'\bpeoples\b': 'people',
    r'\bchilds\b': 'children',
    r'\bgoods\b': 'good (or "goods" if meaning products)',
    r'\badvices\b': 'advice',
    r'\binformations\b': 'information',
    r'\bequipments\b': 'equipment',
    r'\bknowledges\b': 'knowledge',
    r'\bfurnitures\b': 'furniture',
    r'\bresearcches\b': 'research',
    r'\bi am agree\b': 'I agree',
    r'\bi am disagree\b': 'I disagree',
    r'\bmore better\b': 'better',
    r'\bmore worse\b': 'worse',
    r'\bvery unique\b': 'unique',
    r'\bcan able\b': 'can / is able to',
  };

  static int _countErrors(String text) {
    final lc = text.toLowerCase();
    return _errors.keys.where((p) => RegExp(p).hasMatch(lc)).length;
  }

  static Map<String, String> _findErrors(String text) {
    final found = <String, String>{};
    final lc = text.toLowerCase();
    for (final entry in _errors.entries) {
      final match = RegExp(entry.key).firstMatch(lc);
      if (match != null) {
        found[text.substring(match.start, match.end)] = entry.value;
      }
    }
    return found;
  }

  static List<TextSpan> _buildSpans(String text, Map<String, String> errors) {
    if (errors.isEmpty) return [TextSpan(text: text)];

    final spans = <TextSpan>[];
    int pos = 0;

    // Build a flat list of (start, end, errorText, suggestion) sorted by position
    final marks = <_Mark>[];
    for (final entry in errors.entries) {
      final idx = text.toLowerCase().indexOf(entry.key.toLowerCase().replaceAll(r'\b', ''));
      if (idx >= 0) {
        marks.add(_Mark(idx, idx + entry.key.replaceAll(r'\b', '').length, entry.key, entry.value));
      }
    }
    marks.sort((a, b) => a.start.compareTo(b.start));

    for (final m in marks) {
      if (m.start > pos) spans.add(TextSpan(text: text.substring(pos, m.start)));
      final word = text.substring(m.start, m.end.clamp(m.start, text.length));
      spans.add(TextSpan(text: word, style: const TextStyle(backgroundColor: Color(0xFFFFEBEE), color: Colors.red, decoration: TextDecoration.lineThrough)));
      spans.add(TextSpan(text: ' ${m.suggestion}', style: const TextStyle(backgroundColor: Color(0xFFE8F5E9), color: Colors.green, fontWeight: FontWeight.w600)));
      pos = m.end.clamp(m.start, text.length);
    }
    if (pos < text.length) spans.add(TextSpan(text: text.substring(pos)));
    return spans;
  }
}

class _Mark {
  final int start, end;
  final String pattern, suggestion;
  const _Mark(this.start, this.end, this.pattern, this.suggestion);
}

// ── Widgets ────────────────────────────────────────────────────────────────

class _ScoreCircle extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  const _ScoreCircle(this.label, this.score, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: color, width: 3)),
        child: Center(child: Text('$score', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color))),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]);
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatBadge(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
  );
}
