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

  final _topics = [
    {'title': 'My Family', 'level': 'A1', 'desc': 'Describe your family members and your relationship with them.'},
    {'title': 'Technology', 'level': 'B1', 'desc': 'How has technology changed our daily lives in the past decade?'},
    {'title': 'Climate Change', 'level': 'B2', 'desc': 'What solutions can individuals and governments adopt to tackle climate change?'},
    {'title': 'Future of Education', 'level': 'C1', 'desc': 'Discuss how AI and technology will transform education in the next 20 years.'},
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

  Widget _buildEditor() {
    return Column(
      children: [
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
                onTap: () => setState(() => _selectedTopic = i),
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
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: sel ? Colors.white24 : Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                      child: Text(t['level']!, style: TextStyle(fontSize: 11, color: sel ? Colors.white : Colors.blue[700]))),
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
                hintText: 'Start writing here... (aim for 2–3 paragraphs)',
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
              Text('${_textCtrl.text.split(' ').where((w) => w.isNotEmpty).length} words', style: const TextStyle(color: Colors.grey)),
              Text('${_textCtrl.text.length} characters', style: const TextStyle(color: Colors.grey)),
            ]),
            const SizedBox(height: 12),
            CustomButton(
              label: '✨ Analyse My Writing',
              isLoading: _isAnalyzing,
              onPressed: _textCtrl.text.length > 50 ? _analyseWriting : null,
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildResults() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('AI Analysis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton.icon(icon: const Icon(Icons.edit), label: const Text('Edit'), onPressed: () => setState(() => _showResults = false)),
          ]),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _ScoreCircle('Overall', 78, Colors.green),
            _ScoreCircle('Grammar', 85, Colors.blue),
            _ScoreCircle('Vocab', 72, Colors.purple),
            _ScoreCircle('Style', 76, Colors.orange),
          ]),
          const SizedBox(height: 20),
          const Text('Your Text (with corrections)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.7),
                children: [
                  const TextSpan(text: 'Technology has '),
                  TextSpan(text: 'revolutionized', style: const TextStyle(backgroundColor: Color(0xFFE8F5E9), color: Colors.green, decoration: TextDecoration.underline)),
                  const TextSpan(text: ' our daily lives in countless ways. '),
                  TextSpan(text: 'Peoples', style: const TextStyle(backgroundColor: Color(0xFFFFEBEE), color: Colors.red, decoration: TextDecoration.lineThrough)),
                  TextSpan(text: ' People', style: const TextStyle(backgroundColor: Color(0xFFE8F5E9), color: Colors.green)),
                  const TextSpan(text: ' now communicate instantly across the globe.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('AI Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('✅ Strengths', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 6),
              Text('• Good use of complex vocabulary\n• Clear paragraph structure\n• Effective use of examples', style: TextStyle(height: 1.6)),
              SizedBox(height: 12),
              Text('⚠️ Areas to Improve', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              SizedBox(height: 6),
              Text('• Watch subject-verb agreement ("peoples" → "people")\n• Add more transition words between paragraphs\n• Try using more advanced connectors (furthermore, however)', style: TextStyle(height: 1.6)),
            ]),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.replay), label: const Text('Try Again'), onPressed: () => setState(() { _showResults = false; _textCtrl.clear(); }))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.save), label: const Text('Save'), onPressed: () {})),
          ]),
        ],
      ),
    );
  }

  void _analyseWriting() async {
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() { _isAnalyzing = false; _showResults = true; });
  }
}

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
