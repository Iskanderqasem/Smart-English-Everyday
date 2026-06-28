import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HangmanGame extends StatefulWidget {
  const HangmanGame({super.key});
  @override
  State<HangmanGame> createState() => _HangmanGameState();
}

class _HangmanGameState extends State<HangmanGame> {
  final _words = ['PERSEVERANCE', 'VOCABULARY', 'GRAMMAR', 'PRONUNCIATION', 'FLUENCY', 'ELOQUENT', 'METICULOUS', 'AMBIGUOUS'];
  late String _word;
  final Set<String> _guessed = {};
  int _wrong = 0;
  static const _maxWrong = 6;

  @override
  void initState() { super.initState(); _newWord(); }

  void _newWord() { _word = (_words..shuffle()).first; _guessed.clear(); _wrong = 0; }

  bool get _won => _word.split('').every((c) => _guessed.contains(c));
  bool get _lost => _wrong >= _maxWrong;

  void _guess(String letter) {
    if (_guessed.contains(letter) || _won || _lost) return;
    setState(() {
      _guessed.add(letter);
      if (!_word.contains(letter)) _wrong++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hangman'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Text('Mistakes: $_wrong / $_maxWrong', style: TextStyle(color: _wrong >= 4 ? Colors.red : Colors.grey)),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: 1 - _wrong / _maxWrong, backgroundColor: Colors.red[100], color: Colors.green, minHeight: 8)),
          const SizedBox(height: 32),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: _word.split('').map((c) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(children: [
                Text(_guessed.contains(c) ? c : '?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _guessed.contains(c) ? AppColors.primary : Colors.grey[400])),
                Container(margin: const EdgeInsets.only(top: 4), height: 2, width: 24, color: Colors.grey[400]),
              ]),
            )).toList(),
          ),
          const SizedBox(height: 32),
          if (_won || _lost) Column(children: [
            Text(_won ? '🎉 Correct!' : '💔 Game Over!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            if (_lost) Text('Word was: $_word', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => setState(_newWord), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: const Text('Play Again')),
          ]) else Wrap(spacing: 8, runSpacing: 8, children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((c) {
            final used = _guessed.contains(c);
            final correct = used && _word.contains(c);
            final wrong = used && !_word.contains(c);
            return GestureDetector(
              onTap: () => _guess(c),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: correct ? Colors.green : wrong ? Colors.red[100] : Colors.white,
                  border: Border.all(color: correct ? Colors.green : wrong ? Colors.red : Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text(c, style: TextStyle(fontWeight: FontWeight.bold, color: wrong ? Colors.red : correct ? Colors.white : Colors.black87))),
              ),
            );
          }).toList()),
        ]),
      ),
    );
  }
}
