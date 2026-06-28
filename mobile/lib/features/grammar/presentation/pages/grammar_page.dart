import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class GrammarPage extends StatefulWidget {
  const GrammarPage({super.key});
  @override
  State<GrammarPage> createState() => _GrammarPageState();
}

class _GrammarPageState extends State<GrammarPage> {
  String _selectedCategory = 'All';

  final _categories = ['All', 'Tenses', 'Modal Verbs', 'Passive Voice', 'Conditionals', 'Prepositions', 'Articles', 'Phrasal Verbs'];

  final _topics = [
    {'title': 'Simple Present', 'category': 'Tenses', 'level': 'A1', 'lessons': 5, 'completed': 5, 'icon': '📅'},
    {'title': 'Simple Past', 'category': 'Tenses', 'level': 'A1', 'lessons': 5, 'completed': 5, 'icon': '⏪'},
    {'title': 'Present Perfect', 'category': 'Tenses', 'level': 'B1', 'lessons': 6, 'completed': 3, 'icon': '✅'},
    {'title': 'Future Tenses', 'category': 'Tenses', 'level': 'B1', 'lessons': 5, 'completed': 0, 'icon': '🔮'},
    {'title': 'Can, Could, May', 'category': 'Modal Verbs', 'level': 'A2', 'lessons': 4, 'completed': 4, 'icon': '💪'},
    {'title': 'Must, Should, Would', 'category': 'Modal Verbs', 'level': 'B1', 'lessons': 4, 'completed': 1, 'icon': '🤔'},
    {'title': 'Passive Voice', 'category': 'Passive Voice', 'level': 'B1', 'lessons': 5, 'completed': 0, 'icon': '🔄'},
    {'title': 'First Conditional', 'category': 'Conditionals', 'level': 'B1', 'lessons': 3, 'completed': 0, 'icon': 'if'},
    {'title': 'Phrasal Verbs', 'category': 'Phrasal Verbs', 'level': 'B1', 'lessons': 8, 'completed': 0, 'icon': '🔤'},
    {'title': 'A, An, The', 'category': 'Articles', 'level': 'A2', 'lessons': 4, 'completed': 4, 'icon': '📌'},
  ];

  List<Map<String, dynamic>> get _filtered => _selectedCategory == 'All' ? _topics : _topics.where((t) => t['category'] == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grammar'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: Column(
        children: [
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
                  child: Text(_categories[i], style: TextStyle(color: _selectedCategory == _categories[i] ? Colors.white : Colors.black87, fontSize: 13)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final t = _filtered[i];
                final progress = (t['completed'] as int) / (t['lessons'] as int);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(width: 52, height: 52, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                      child: Center(child: Text(t['icon'] as String, style: const TextStyle(fontSize: t['icon'] == 'if' ? 16 : 22)))),
                    title: Row(children: [
                      Expanded(child: Text(t['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                        child: Text(t['level'] as String, style: TextStyle(fontSize: 11, color: Colors.blue[700]))),
                    ]),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${t['category']} • ${t['lessons']} lessons', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation(progress == 1.0 ? Colors.green : AppColors.primary), borderRadius: BorderRadius.circular(4), minHeight: 6),
                      const SizedBox(height: 4),
                      Text('${t['completed']}/${t['lessons']} completed', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ]),
                    trailing: progress == 1.0 ? const Icon(Icons.check_circle, color: Colors.green, size: 28) : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
