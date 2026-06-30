import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../main.dart';
import '../../../../shared/services/storage_service.dart';

class WordMatchGame extends StatefulWidget {
  const WordMatchGame({super.key});
  @override
  State<WordMatchGame> createState() => _WordMatchGameState();
}

class _WordMatchGameState extends State<WordMatchGame> {
  static const _bank = [
    ['Happy', 'Joyful'], ['Big', 'Large'], ['Fast', 'Quick'], ['Cold', 'Chilly'],
    ['Old', 'Ancient'], ['Smart', 'Clever'], ['Brave', 'Courageous'], ['Kind', 'Generous'],
    ['Angry', 'Furious'], ['Small', 'Tiny'], ['Tired', 'Exhausted'], ['Sad', 'Unhappy'],
    ['Strong', 'Powerful'], ['Loud', 'Noisy'], ['Clean', 'Spotless'], ['Dark', 'Gloomy'],
    ['Funny', 'Humorous'], ['Famous', 'Renowned'], ['Strange', 'Peculiar'],
    ['Difficult', 'Challenging'], ['Rich', 'Wealthy'], ['Dangerous', 'Hazardous'],
    ['Beautiful', 'Gorgeous'], ['Honest', 'Truthful'], ['Lazy', 'Idle'],
    ['Polite', 'Courteous'], ['Careless', 'Reckless'], ['Eager', 'Enthusiastic'],
    ['Calm', 'Peaceful'], ['Bright', 'Brilliant'], ['Afraid', 'Terrified'],
    ['Free', 'Liberated'],
  ];

  final _rng = Random();
  late List<List<String>> _pairs;
  late List<String> _left;
  late List<String> _right;
  final Set<String> _matched = {};
  String? _selLeft;
  String? _selRight;
  bool? _lastCorrect;
  bool _done = false;

  @override
  void initState() { super.initState(); _newGame(); }

  void _newGame() {
    final shuffled = List.of(_bank)..shuffle(_rng);
    _pairs = shuffled.take(8).toList();
    _left = _pairs.map((p) => p[0]).toList();
    _right = (_pairs.map((p) => p[1]).toList())..shuffle(_rng);
    _matched.clear();
    _selLeft = _selRight = null;
    _lastCorrect = null;
    _done = false;
  }

  String? _synonymOf(String word) {
    for (final p in _pairs) if (p[0] == word) return p[1];
    return null;
  }

  void _tapLeft(String w) {
    if (_matched.contains(w)) return;
    setState(() { _selLeft = w; _lastCorrect = null; });
    _check();
  }

  void _tapRight(String w) {
    if (_matched.contains(w)) return;
    setState(() { _selRight = w; _lastCorrect = null; });
    _check();
  }

  void _check() {
    if (_selLeft == null || _selRight == null) return;
    final correct = _synonymOf(_selLeft!) == _selRight;
    setState(() => _lastCorrect = correct);
    if (correct) {
      final l = _selLeft!, r = _selRight!;
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        setState(() { _matched.add(l); _matched.add(r); _selLeft = _selRight = null; _lastCorrect = null; });
        if (_matched.length == _pairs.length * 2) _finish();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() { _selLeft = _selRight = null; _lastCorrect = null; });
      });
    }
  }

  Future<void> _finish() async {
    final s = sl<StorageService>();
    await s.saveInt('total_xp', s.getInt('total_xp', defaultValue: 0) + 50);
    if (mounted) setState(() => _done = true);
  }

  Color _leftBg(String w) {
    if (_matched.contains(w)) return Colors.green.shade200;
    if (_selLeft == w) return _lastCorrect == true ? Colors.green.shade200 : _lastCorrect == false ? Colors.red.shade200 : Colors.blue.shade100;
    return Colors.grey.shade100;
  }

  Color _rightBg(String w) {
    if (_matched.contains(w)) return Colors.green.shade200;
    if (_selRight == w) return _lastCorrect == true ? Colors.green.shade200 : _lastCorrect == false ? Colors.red.shade200 : Colors.purple.shade100;
    return Colors.grey.shade100;
  }

  @override
  Widget build(BuildContext context) {
    final matchedPairs = _matched.length ~/ 2;
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Match  $matchedPairs/${_pairs.length}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'New Game',
              onPressed: () => setState(_newGame)),
        ],
      ),
      body: SafeArea(
        child: _done ? _buildWin() : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Tap a word on the left, then its synonym on the right',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _column('Words', _left, _leftBg, _tapLeft, _selLeft)),
                    const SizedBox(width: 10),
                    Expanded(child: _column('Synonyms', _right, _rightBg, _tapRight, _selRight)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _column(String title, List<String> words, Color Function(String) bg,
      void Function(String) onTap, String? selected) {
    return Column(
      children: [
        Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
        const SizedBox(height: 6),
        ...words.map((w) {
          final done = _matched.contains(w);
          return GestureDetector(
            onTap: done ? null : () => onTap(w),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
              decoration: BoxDecoration(
                color: bg(w),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected == w ? AppColors.primary : Colors.grey.shade300,
                  width: selected == w ? 2 : 1,
                ),
                boxShadow: selected == w ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 6)] : [],
              ),
              child: Center(
                child: Text(w, style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: done ? Colors.green.shade800 : Colors.black87,
                  decoration: done ? TextDecoration.lineThrough : null,
                )),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWin() {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🎉', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        const Text('All matched!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('You earned 50 XP!', style: TextStyle(fontSize: 18, color: Colors.green)),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Play Again'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
          onPressed: () => setState(_newGame),
        ),
        const SizedBox(height: 12),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Games')),
      ]),
    ));
  }
}
