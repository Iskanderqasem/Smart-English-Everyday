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
  static const Map<String, List<String>> _categories = {
    'Grammar': [
      'PRESENT',
      'PERFECT',
      'PASSIVE',
      'CONDITIONAL',
      'SUBJUNCTIVE',
      'PARTICIPLE',
      'GERUND',
      'INFINITIVE',
    ],
    'Vocabulary': [
      'PERSEVERANCE',
      'ELOQUENT',
      'METICULOUS',
      'AMBIGUOUS',
      'PROFOUND',
      'UBIQUITOUS',
      'EPHEMERAL',
      'TENACIOUS',
    ],
    'Countries': [
      'AUSTRALIA',
      'ARGENTINA',
      'NETHERLANDS',
      'SWITZERLAND',
      'INDONESIA',
      'SINGAPORE',
      'PHILIPPINES',
      'MOZAMBIQUE',
    ],
    'Animals': [
      'RHINOCEROS',
      'CHIMPANZEE',
      'CROCODILE',
      'FLAMINGO',
      'PORCUPINE',
      'SALAMANDER',
      'CHAMELEON',
      'WOLVERINE',
    ],
    'Science': [
      'PHOTOSYNTHESIS',
      'ATMOSPHERE',
      'HYPOTHESIS',
      'EXPERIMENT',
      'TELESCOPE',
      'MICROSCOPE',
      'ECOSYSTEM',
      'CHROMOSOME',
    ],
  };

  static const int _maxLives = 6;

  late String _word;
  late String _category;
  final Set<String> _guessed = {};
  bool _gameOver = false;
  bool _won = false;

  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    final categoryKeys = _categories.keys.toList();
    _category = categoryKeys[_rng.nextInt(categoryKeys.length)];
    final words = _categories[_category]!;
    _word = words[_rng.nextInt(words.length)];
    _guessed.clear();
    _gameOver = false;
    _won = false;
  }

  int get _wrongCount => _guessed.where((l) => !_word.contains(l)).length;
  int get _livesLeft => _maxLives - _wrongCount;

  bool get _isWordComplete => _word.split('').every((l) => _guessed.contains(l));

  void _guess(String letter) {
    if (_gameOver || _won) return;
    if (_guessed.contains(letter)) return;
    setState(() {
      _guessed.add(letter);
      if (_isWordComplete) {
        _won = true;
        _gameOver = true;
        _onWin();
      } else if (_livesLeft <= 0) {
        _gameOver = true;
      }
    });
  }

  Future<void> _onWin() async {
    final storage = sl<StorageService>();
    final current = storage.getInt('total_xp', defaultValue: 0);
    await storage.saveInt('total_xp', current + 30);
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('\u{1F389} Correct!'),
        content: const Text('You earned 30 XP!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _startNewGame());
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }

  void _skip() {
    setState(() => _startNewGame());
  }

  Widget _buildWordDisplay() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: _word.split('').map((letter) {
        final revealed = _guessed.contains(letter);
        return Container(
          width: 28,
          height: 36,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.primary, width: 2)),
          ),
          alignment: Alignment.bottomCenter,
          child: Text(
            revealed ? letter : '',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeyboard() {
    const rows = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];
    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            children: row.split('').map((letter) {
              final guessed = _guessed.contains(letter);
              final correct = _word.contains(letter);
              Color bg;
              Color fg;
              if (!guessed) {
                bg = Colors.grey.shade200;
                fg = Colors.black87;
              } else if (correct) {
                bg = Colors.green;
                fg = Colors.white;
              } else {
                bg = Colors.red.shade400;
                fg = Colors.white;
              }
              return GestureDetector(
                onTap: (guessed || _gameOver) ? null : () => _guess(letter),
                child: Container(
                  width: 32,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: fg,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _wrongCount / _maxLives;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hangman'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _skip,
            child: const Text('Skip', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
                ),
                child: Text(
                  'Category: $_category',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lives: $_livesLeft / $_maxLives',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  ...List.generate(_maxLives, (i) {
                    return Icon(
                      i < _livesLeft ? Icons.favorite : Icons.favorite_border,
                      color: i < _livesLeft ? Colors.red : Colors.grey,
                      size: 20,
                    );
                  }),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
              const SizedBox(height: 30),
              _buildWordDisplay(),
              const SizedBox(height: 30),
              if (_gameOver && !_won)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '\u{1F494} Game Over!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'The word was $_word',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => setState(() => _startNewGame()),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              _buildKeyboard(),
              const SizedBox(height: 16),
              if (_guessed.isNotEmpty)
                Text(
                  'Guessed: ${_guessed.toList()..sort()..join(' ')}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
