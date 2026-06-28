import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LessonDetailPage extends StatefulWidget {
  final String lessonId;
  const LessonDetailPage({super.key, required this.lessonId});
  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  int _step = 0;
  final _steps = [
    {'title': 'Introduction', 'content': 'Welcome to this lesson! Let\'s learn together.', 'type': 'info'},
    {'title': 'Vocabulary', 'content': 'Learn 5 new words for today\'s lesson.', 'type': 'vocab'},
    {'title': 'Practice', 'content': 'Complete the exercises below.', 'type': 'exercise'},
    {'title': 'Quiz', 'content': 'Test your understanding!', 'type': 'quiz'},
  ];

  @override
  Widget build(BuildContext context) {
    final s = _steps[_step];
    return Scaffold(
      appBar: AppBar(
        title: Text('Lesson ${widget.lessonId}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_step + 1) / _steps.length, backgroundColor: Colors.white30, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step ${_step + 1} of ${_steps.length}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(s['title'] as String, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
                  child: Text(s['content'] as String, style: const TextStyle(fontSize: 18, height: 1.6), textAlign: TextAlign.center),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_step < _steps.length - 1) setState(() => _step++);
                  else Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(_step < _steps.length - 1 ? 'Continue' : 'Complete Lesson'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
