import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../main.dart';
import '../../../../shared/services/storage_service.dart';
import 'grammar_lesson_page.dart';

class GrammarPage extends StatefulWidget {
  const GrammarPage({super.key});
  @override
  State<GrammarPage> createState() => _GrammarPageState();
}

class _GrammarPageState extends State<GrammarPage> {
  String _selectedCategory = 'All';
  Map<String, int> _progress = {};

  final _categories = ['All', 'Tenses', 'Modal Verbs', 'Passive Voice', 'Conditionals', 'Prepositions', 'Articles', 'Phrasal Verbs'];

  final _topics = [
    // Tenses
    {'title': 'Simple Present',       'category': 'Tenses',       'level': 'A1', 'lessons': 5,  'icon': '📅'},
    {'title': 'Simple Past',          'category': 'Tenses',       'level': 'A1', 'lessons': 5,  'icon': '⏪'},
    {'title': 'Present Continuous',   'category': 'Tenses',       'level': 'A2', 'lessons': 4,  'icon': '🔁'},
    {'title': 'Past Continuous',      'category': 'Tenses',       'level': 'A2', 'lessons': 4,  'icon': '⌛'},
    {'title': 'Present Perfect',      'category': 'Tenses',       'level': 'B1', 'lessons': 6,  'icon': '✅'},
    {'title': 'Past Perfect',         'category': 'Tenses',       'level': 'B2', 'lessons': 4,  'icon': '⏮️'},
    {'title': 'Future with Will',     'category': 'Tenses',       'level': 'A2', 'lessons': 4,  'icon': '🔮'},
    {'title': 'Future with Going To', 'category': 'Tenses',       'level': 'A2', 'lessons': 3,  'icon': '🗓️'},
    {'title': 'Future Perfect',       'category': 'Tenses',       'level': 'C1', 'lessons': 3,  'icon': '🏁'},
    // Modal Verbs
    {'title': 'Can & Could',          'category': 'Modal Verbs',  'level': 'A1', 'lessons': 4,  'icon': '💪'},
    {'title': 'May & Might',          'category': 'Modal Verbs',  'level': 'A2', 'lessons': 3,  'icon': '🤷'},
    {'title': 'Must & Have To',       'category': 'Modal Verbs',  'level': 'A2', 'lessons': 4,  'icon': '❗'},
    {'title': 'Should & Ought To',    'category': 'Modal Verbs',  'level': 'B1', 'lessons': 4,  'icon': '🤔'},
    {'title': 'Would & Used To',      'category': 'Modal Verbs',  'level': 'B1', 'lessons': 4,  'icon': '🔂'},
    {'title': 'Modal Perfect',        'category': 'Modal Verbs',  'level': 'B2', 'lessons': 4,  'icon': '🎯'},
    // Passive Voice
    {'title': 'Passive: Present',     'category': 'Passive Voice','level': 'B1', 'lessons': 4,  'icon': '🔄'},
    {'title': 'Passive: Past',        'category': 'Passive Voice','level': 'B1', 'lessons': 4,  'icon': '📜'},
    {'title': 'Passive: Future',      'category': 'Passive Voice','level': 'B2', 'lessons': 3,  'icon': '🔁'},
    {'title': 'Passive with Modals',  'category': 'Passive Voice','level': 'B2', 'lessons': 4,  'icon': '🎭'},
    {'title': 'Causative Have/Get',   'category': 'Passive Voice','level': 'C1', 'lessons': 3,  'icon': '🛠️'},
    // Conditionals
    {'title': 'Zero Conditional',     'category': 'Conditionals', 'level': 'A2', 'lessons': 3,  'icon': '🌡️'},
    {'title': 'First Conditional',    'category': 'Conditionals', 'level': 'B1', 'lessons': 4,  'icon': '1️⃣'},
    {'title': 'Second Conditional',   'category': 'Conditionals', 'level': 'B1', 'lessons': 4,  'icon': '2️⃣'},
    {'title': 'Third Conditional',    'category': 'Conditionals', 'level': 'B2', 'lessons': 4,  'icon': '3️⃣'},
    {'title': 'Mixed Conditionals',   'category': 'Conditionals', 'level': 'C1', 'lessons': 3,  'icon': '🔀'},
    // Prepositions
    {'title': 'Prepositions of Place','category': 'Prepositions', 'level': 'A1', 'lessons': 4,  'icon': '📍'},
    {'title': 'Prepositions of Time', 'category': 'Prepositions', 'level': 'A1', 'lessons': 4,  'icon': '🕐'},
    {'title': 'In / On / At',         'category': 'Prepositions', 'level': 'A2', 'lessons': 5,  'icon': '📦'},
    {'title': 'Prepositions of Movement','category':'Prepositions','level':'A2', 'lessons': 3,  'icon': '➡️'},
    {'title': 'Dependent Prepositions','category':'Prepositions', 'level': 'B2', 'lessons': 5,  'icon': '🔗'},
    // Articles
    {'title': 'A & An (Indefinite)',  'category': 'Articles',     'level': 'A1', 'lessons': 4,  'icon': '📌'},
    {'title': 'The (Definite)',       'category': 'Articles',     'level': 'A1', 'lessons': 4,  'icon': '☑️'},
    {'title': 'Zero Article',         'category': 'Articles',     'level': 'B1', 'lessons': 3,  'icon': '0️⃣'},
    {'title': 'Articles with Proper Nouns','category':'Articles', 'level': 'B2', 'lessons': 3,  'icon': '🌍'},
    // Phrasal Verbs
    {'title': 'Phrasal Verbs: Movement',    'category':'Phrasal Verbs','level':'A2','lessons':5,'icon':'🚶'},
    {'title': 'Phrasal Verbs: Relationships','category':'Phrasal Verbs','level':'B1','lessons':5,'icon':'🤝'},
    {'title': 'Phrasal Verbs: Work & Study','category':'Phrasal Verbs','level':'B1','lessons':5,'icon':'💼'},
    {'title': 'Separable vs Inseparable',   'category':'Phrasal Verbs','level':'B2','lessons':4,'icon':'✂️'},
    {'title': 'Advanced Phrasal Verbs',     'category':'Phrasal Verbs','level':'C1','lessons':6,'icon':'🎓'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() {
    final map = <String, int>{};
    try {
      final storage = sl<StorageService>();
      for (final t in _topics) {
        final key = 'grammar_done_${t['title']}';
        map[t['title'] as String] = storage.getInt(key) ?? 0;
      }
    } catch (_) {}
    setState(() => _progress = map);
  }

  List<Map<String, dynamic>> get _filtered =>
      _selectedCategory == 'All' ? _topics : _topics.where((t) => t['category'] == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grammar'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(children: [
        // Category filter chips
        SizedBox(
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _categories.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => setState(() => _selectedCategory = _categories[i]),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _selectedCategory == _categories[i] ? AppColors.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_categories[i],
                    style: TextStyle(
                        color: _selectedCategory == _categories[i] ? Colors.white : Colors.black87,
                        fontSize: 13)),
              ),
            ),
          ),
        ),

        // Topic list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final t = _filtered[i];
              final done = _progress[t['title']] ?? 0;
              final lessons = t['lessons'] as int;
              final progress = done / lessons;
              final complete = progress >= 1.0;

              return GestureDetector(
                onTap: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => GrammarLessonPage(topic: t)),
                  );
                  if (result == true) _loadProgress();
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: complete ? Colors.green.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(child: Text(t['icon'] as String, style: const TextStyle(fontSize: 22))),
                    ),
                    title: Row(children: [
                      Expanded(child: Text(t['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                        child: Text(t['level'] as String, style: TextStyle(fontSize: 11, color: Colors.blue[700])),
                      ),
                    ]),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${t['category']} • $lessons lessons',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(complete ? Colors.green : AppColors.primary),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 6,
                      ),
                      const SizedBox(height: 4),
                      Text(done == 0 ? 'Tap to start' : '$done/$lessons completed',
                          style: TextStyle(fontSize: 11, color: done == 0 ? AppColors.primary : Colors.grey)),
                    ]),
                    trailing: complete
                        ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                        : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
