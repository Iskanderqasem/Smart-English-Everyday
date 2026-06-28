import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TestsPage extends StatelessWidget {
  const TestsPage({super.key});

  static const _tests = [
    {'name': 'Grammar Test — Level 1', 'questions': 20, 'time': '20 min', 'level': 'A1', 'color': 0xFF10B981},
    {'name': 'Vocabulary Quiz — Level 2', 'questions': 25, 'time': '25 min', 'level': 'A2', 'color': 0xFF3B82F6},
    {'name': 'Reading Comprehension', 'questions': 15, 'time': '30 min', 'level': 'B1', 'color': 0xFF8B5CF6},
    {'name': 'Listening Test', 'questions': 20, 'time': '35 min', 'level': 'B1', 'color': 0xFFF59E0B},
    {'name': 'IELTS Practice Test', 'questions': 40, 'time': '60 min', 'level': 'C1', 'color': 0xFFEC4899},
    {'name': 'TOEFL Practice Test', 'questions': 45, 'time': '90 min', 'level': 'C1', 'color': 0xFFEF4444},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tests & Certificates'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Text('🏆', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Pass a test to earn a certificate!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text('Share it on LinkedIn or CV', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          ..._tests.map((t) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)]),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: Color(t['color'] as int).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(t['level'] as String, style: TextStyle(color: Color(t['color'] as int), fontWeight: FontWeight.bold))),
              ),
              title: Text(t['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${t['questions']} questions • ${t['time']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              trailing: ElevatedButton(
                onPressed: () => _showTestDialog(context, t),
                style: ElevatedButton.styleFrom(backgroundColor: Color(t['color'] as int), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('Start'),
              ),
            ),
          )),
        ],
      ),
    );
  }

  void _showTestDialog(BuildContext ctx, Map t) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      title: Text(t['name'] as String),
      content: Text('${t['questions']} questions • ${t['time']}\nLevel: ${t['level']}\n\nAre you ready to start?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Test started! Good luck!'))); }, child: const Text('Start Test')),
      ],
    ));
  }
}
