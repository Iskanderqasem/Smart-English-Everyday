import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WordMatchGame extends StatefulWidget {
  const WordMatchGame({super.key});
  @override
  State<WordMatchGame> createState() => _WordMatchGameState();
}

class _WordMatchGameState extends State<WordMatchGame> {
  final _pairs = [
    ['Happy', 'Joyful'], ['Big', 'Large'], ['Fast', 'Quick'], ['Cold', 'Chilly'],
    ['Old', 'Ancient'], ['Smart', 'Clever'], ['Brave', 'Courageous'], ['Kind', 'Generous'],
  ];
  late List<String> _left, _right;
  int? _selLeft, _selRight;
  final Set<int> _matchedLeft = {}, _matchedRight = {};
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _left = _pairs.map((p) => p[0]).toList();
    _right = (_pairs.map((p) => p[1]).toList()..shuffle());
  }

  void _selectLeft(int i) {
    if (_matchedLeft.contains(i)) return;
    setState(() { _selLeft = i; _checkMatch(); });
  }

  void _selectRight(int i) {
    if (_matchedRight.contains(i)) return;
    setState(() { _selRight = i; _checkMatch(); });
  }

  void _checkMatch() {
    if (_selLeft == null || _selRight == null) return;
    final word = _left[_selLeft!];
    final match = _right[_selRight!];
    final pair = _pairs.firstWhere((p) => p[0] == word, orElse: () => []);
    if (pair.isNotEmpty && pair[1] == match) {
      _matchedLeft.add(_selLeft!);
      _matchedRight.add(_selRight!);
      _score++;
    }
    _selLeft = null;
    _selRight = null;
  }

  @override
  Widget build(BuildContext context) {
    final done = _matchedLeft.length == _pairs.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Word Match'), backgroundColor: AppColors.primary, foregroundColor: Colors.white,
        actions: [Padding(padding: const EdgeInsets.all(16), child: Text('$_score/${_pairs.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))],
      ),
      body: done
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('Perfect! $_score/${_pairs.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () { setState(() { _matchedLeft.clear(); _matchedRight.clear(); _score = 0; _right.shuffle(); }); }, child: const Text('Play Again')),
          ]))
        : Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: Column(children: _left.asMap().entries.map((e) {
                final matched = _matchedLeft.contains(e.key);
                final sel = _selLeft == e.key;
                return GestureDetector(
                  onTap: () => _selectLeft(e.key),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: matched ? Colors.green[100] : sel ? AppColors.primary.withOpacity(0.15) : Colors.white,
                      border: Border.all(color: matched ? Colors.green : sel ? AppColors.primary : Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(e.value, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: matched ? Colors.green[800] : Colors.black87)),
                  ),
                );
              }).toList())),
              const SizedBox(width: 12),
              Expanded(child: Column(children: _right.asMap().entries.map((e) {
                final matched = _matchedRight.contains(e.key);
                final sel = _selRight == e.key;
                return GestureDetector(
                  onTap: () => _selectRight(e.key),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: matched ? Colors.green[100] : sel ? AppColors.secondary.withOpacity(0.15) : Colors.white,
                      border: Border.all(color: matched ? Colors.green : sel ? AppColors.secondary : Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(e.value, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: matched ? Colors.green[800] : Colors.black87)),
                  ),
                );
              }).toList())),
            ]),
          ),
    );
  }
}
