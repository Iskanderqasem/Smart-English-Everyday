import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../main.dart';
import '../../../../shared/services/storage_service.dart';

class HangmanGame extends StatefulWidget {
  const HangmanGame({super.key});
  @override
  State<HangmanGame> createState() => _HangmanGameState();
}

class _HangmanGameState extends State<HangmanGame> {
  static const _categories = {
    'Grammar':    ['PRESENT','PERFECT','PASSIVE','CONDITIONAL','SUBJUNCTIVE','PARTICIPLE','GERUND','INFINITIVE'],
    'Vocabulary': ['PERSEVERANCE','ELOQUENT','METICULOUS','AMBIGUOUS','PROFOUND','UBIQUITOUS','EPHEMERAL','TENACIOUS'],
    'Countries':  ['AUSTRALIA','ARGENTINA','NETHERLANDS','SWITZERLAND','INDONESIA','SINGAPORE','PHILIPPINES','MOZAMBIQUE'],
    'Animals':    ['RHINOCEROS','CHIMPANZEE','CROCODILE','FLAMINGO','PORCUPINE','SALAMANDER','CHAMELEON','WOLVERINE'],
    'Science':    ['PHOTOSYNTHESIS','ATMOSPHERE','HYPOTHESIS','EXPERIMENT','TELESCOPE','MICROSCOPE','ECOSYSTEM','CHROMOSOME'],
  };

  static const int _maxWrong = 6;
  final _rng = Random();

  late String _word;
  late String _category;
  final Set<String> _guessed = {};

  bool get _won => _word.split('').every(_guessed.contains);
  bool get _lost => _wrongCount >= _maxWrong;
  int get _wrongCount => _guessed.where((l) => !_word.contains(l)).length;

  @override
  void initState() { super.initState(); _newGame(); }

  void _newGame() {
    final cats = _categories.keys.toList();
    _category = cats[_rng.nextInt(cats.length)];
    final words = _categories[_category]!;
    _word = words[_rng.nextInt(words.length)];
    _guessed.clear();
  }

  void _guess(String letter) {
    if (_guessed.contains(letter) || _won || _lost) return;
    setState(() => _guessed.add(letter));
    if (_won) _onWin();
  }

  Future<void> _onWin() async {
    final s = sl<StorageService>();
    await s.saveInt('total_xp', s.getInt('total_xp', defaultValue: 0) + 30);
  }

  @override
  Widget build(BuildContext context) {
    final wrong = _wrongCount;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hangman'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => setState(_newGame),
            child: const Text('Skip', style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Category chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
                ),
                child: Text('Category: $_category',
                    style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 20),

              // Lives
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ...List.generate(_maxWrong, (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(
                    i < (_maxWrong - wrong) ? Icons.favorite : Icons.favorite_border,
                    color: i < (_maxWrong - wrong) ? Colors.red : Colors.grey.shade400,
                    size: 26,
                  ),
                )),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: wrong / _maxWrong,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      wrong >= 4 ? Colors.red : Colors.orange),
                ),
              ),
              const SizedBox(height: 30),

              // Word blanks
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8, runSpacing: 10,
                children: _word.split('').map((letter) {
                  final revealed = _guessed.contains(letter);
                  return Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      revealed ? letter : (_won || _lost ? letter : '?'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: revealed ? AppColors.primary
                            : (_lost ? Colors.red.shade400 : Colors.grey.shade300),
                      ),
                    ),
                    Container(width: 22, height: 2, color: Colors.grey.shade400),
                  ]);
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Win / Lose state
              if (_won) _statusCard(
                icon: Icons.emoji_events, color: Colors.amber,
                title: 'Correct! +30 XP',
                subtitle: 'The word was $_word',
                buttonLabel: 'Play Again',
                onButton: () => setState(_newGame),
              ),
              if (_lost && !_won) _statusCard(
                icon: Icons.sentiment_dissatisfied, color: Colors.red,
                title: 'Game Over!',
                subtitle: 'The word was $_word',
                buttonLabel: 'Try Again',
                onButton: () => setState(_newGame),
              ),

              const SizedBox(height: 12),

              // Keyboard — only shown while playing
              if (!_won && !_lost) ...[
                ...['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'].map((row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 5,
                    children: row.split('').map((letter) {
                      final used = _guessed.contains(letter);
                      final correct = used && _word.contains(letter);
                      final wrong2 = used && !_word.contains(letter);
                      return GestureDetector(
                        onTap: used ? null : () => _guess(letter),
                        child: Container(
                          width: 33, height: 42,
                          decoration: BoxDecoration(
                            color: correct ? Colors.green : wrong2 ? Colors.red.shade300 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Text(letter, style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold,
                            color: used ? Colors.white : Colors.black87,
                          )),
                        ),
                      );
                    }).toList(),
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusCard({
    required IconData icon, required Color color,
    required String title, required String subtitle,
    required String buttonLabel, required VoidCallback onButton,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 36),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: onButton,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          child: Text(buttonLabel),
        ),
      ]),
    );
  }
}
