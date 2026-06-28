import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class LessonsPage extends StatelessWidget {
  const LessonsPage({super.key});

  static const _levels = [
    {'title': 'Level 1: Alphabet & Phonics', 'progress': 1.0, 'icon': '🔤', 'locked': false},
    {'title': 'Level 2: Basic Vocabulary', 'progress': 0.75, 'icon': '📚', 'locked': false},
    {'title': 'Level 3: Simple Sentences', 'progress': 0.4, 'icon': '💬', 'locked': false},
    {'title': 'Level 4: Grammar Basics', 'progress': 0.1, 'icon': '📝', 'locked': false},
    {'title': 'Level 5: Everyday Conversations', 'progress': 0.0, 'icon': '🗣️', 'locked': true},
    {'title': 'Level 6: Intermediate Grammar', 'progress': 0.0, 'icon': '🎓', 'locked': true},
    {'title': 'Level 7: Reading & Writing', 'progress': 0.0, 'icon': '📖', 'locked': true},
    {'title': 'Level 8: Advanced Vocabulary', 'progress': 0.0, 'icon': '🏆', 'locked': true},
    {'title': 'Level 9: Business English', 'progress': 0.0, 'icon': '💼', 'locked': true},
    {'title': 'Level 10: IELTS/TOEFL Prep', 'progress': 0.0, 'icon': '🌟', 'locked': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Path'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _levels.length,
        itemBuilder: (ctx, i) {
          final l = _levels[i];
          final locked = l['locked'] as bool;
          final progress = l['progress'] as double;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: locked ? Colors.grey[100] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: locked ? Colors.grey[300]! : AppColors.primaryLight.withOpacity(0.4)),
              boxShadow: locked ? [] : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: locked ? Colors.grey[200] : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Text(l['icon'] as String, style: const TextStyle(fontSize: 26))),
              ),
              title: Text(l['title'] as String, style: TextStyle(fontWeight: FontWeight.w600, color: locked ? Colors.grey : Colors.black87)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      color: progress == 1.0 ? AppColors.success : AppColors.primary,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(locked ? 'Locked' : '${(progress * 100).toInt()}% complete', style: TextStyle(fontSize: 12, color: locked ? Colors.grey : AppColors.primary)),
                ],
              ),
              trailing: Icon(locked ? Icons.lock_outline : Icons.chevron_right, color: locked ? Colors.grey[400] : AppColors.primary),
              onTap: locked ? null : () => context.push('/lesson/${i + 1}'),
            ),
          );
        },
      ),
    );
  }
}
