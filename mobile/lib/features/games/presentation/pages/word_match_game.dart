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
  static const List<List<String>> _allPairs = [
    ['Happy', 'Joyful'],
    ['Big', 'Large'],
    ['Fast', 'Quick'],
    ['Cold', 'Chilly'],
    ['Old', 'Ancient'],
    ['Smart', 'Clever'],
    ['Brave', 'Courageous'],
    ['Kind', 'Generous'],
    ['Angry', 'Furious'],
    ['Small', 'Tiny'],
    ['Tired', 'Exhausted'],
    ['Sad', 'Unhappy'],
    ['Strong', 'Powerful'],
    ['Loud', 'Noisy'],
    ['Clean', 'Spotless'],
    ['Dark', 'Gloomy'],
    ['Funny', 'Humorous'],
    ['Famous', 'Renowned'],
    ['Strange', 'Peculiar'],
    ['Difficult', 'Challenging'],
    ['Rich', 'Wealthy'],
    ['Dangerous', 'Hazardous'],
    ['Beautiful', 'Gorgeous'],
    ['Honest', 'Truthful'],
    ['Lazy', 'Idle'],
    ['Polite', 'Courteous'],
    ['Careless', 'Reckless'],
    ['Eager', 'Enthusiastic'],
    ['Calm', 'Peaceful'],
    ['Bright', 'Brilliant'],
    ['Afraid', 'Terrified'],
    ['Free', 'Liberated'],
  ];

  late List<List<String>> _sessionPairs;
  late List<String> _leftWords;
  late List<String> _rightWords;
  final Set<String> _matchedWords = {};
  String? _selectedLeft;
  String? _selectedRight;
  String? _flashLeft;
  String? _flashRight;
  bool _flashCorrect = false;
  int _matched = 0;

  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    final shuffled = List<List<String>>.from(_allPairs)..shuffle(_rng);
    _sessionPairs = shuffled.take(8).toList();
    _leftWords = _sessionPairs.map((p) => p[0]).toList();
    _rightWords = _sessionPairs.map((p) => p[1]).toList()..shuffle(_rng);
    _matchedWords.clear();
    _selectedLeft = null;
    _selectedRight = null;
    _flashLeft = null;
    _flashRight = null;
    _flashCorrect = false;
    _matched = 0;
  }

  String? _synonymFor(String word) {
    for (final pair in _sessionPairs) {
      if (pair[0] == word) return pair[1];
    }
    return null;
  }

  void _selectLeft(String word) {
    if (_matchedWords.contains(word)) return;
    setState(() {
      _selectedLeft = word;
    });
    _tryMatch();
  }

  void _selectRight(String word) {
    if (_matchedWords.contains(word)) return;
    setState(() {
      _selectedRight = word;
    });
    _tryMatch();
  }

  void _tryMatch() {
    if (_selectedLeft == null || _selectedRight == null) return;
    final expected = _synonymFor(_selectedLeft!);
    if (expected == _selectedRight) {
      setState(() {
        _flashLeft = _selectedLeft;
        _flashRight = _selectedRight;
        _flashCorrect = true;
        _matchedWords.add(_selectedLeft!);
        _matchedWords.add(_selectedRight!);
        _matched++;
        _selectedLeft = null;
        _selectedRight = null;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          _flashLeft = null;
          _flashRight = null;
        });
        if (_matched == _sessionPairs.length) {
          _onAllMatched();
        }
      });
    } else {
      setState(() {
        _flashLeft = _selectedLeft;
        _flashRight = _selectedRight;
        _flashCorrect = false;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _flashLeft = null;
          _flashRight = null;
          _selectedLeft = null;
          _selectedRight = null;
        });
      });
    }
  }

  Future<void> _onAllMatched() async {
    final storage = sl<StorageService>();
    final current = storage.getInt('total_xp', defaultValue: 0);
    await storage.saveInt('total_xp', current + 50);
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('\u{1F389} Well Done!'),
        content: Text('You matched all ${_sessionPairs.length} pairs!\nYou earned 50 XP!'),
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

  Color _leftColor(String word) {
    if (_flashLeft == word) {
      return _flashCorrect ? Colors.green.shade200 : Colors.red.shade200;
    }
    if (_matchedWords.contains(word)) return Colors.green.shade100;
    if (_selectedLeft == word) return AppColors.primary.withOpacity(0.2);
    return Colors.grey.shade100;
  }

  Color _rightColor(String word) {
    if (_flashRight == word) {
      return _flashCorrect ? Colors.green.shade200 : Colors.red.shade200;
    }
    if (_matchedWords.contains(word)) return Colors.green.shade100;
    if (_selectedRight == word) return AppColors.secondary.withOpacity(0.2);
    return Colors.grey.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Match  $_matched/${_sessionPairs.length}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'New Game',
            onPressed: () => setState(() => _startNewGame()),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Match each word with its synonym',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Words',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._leftWords.map((word) {
                            final matched = _matchedWords.contains(word);
                            return GestureDetector(
                              onTap: matched ? null : () => _selectLeft(word),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: _leftColor(word),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _selectedLeft == word
                                        ? AppColors.primary
                                        : Colors.grey.shade300,
                                    width: _selectedLeft == word ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    word,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: matched ? Colors.green.shade700 : Colors.black87,
                                      decoration: matched ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Synonyms',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._rightWords.map((word) {
                            final matched = _matchedWords.contains(word);
                            return GestureDetector(
                              onTap: matched ? null : () => _selectRight(word),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: _rightColor(word),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _selectedRight == word
                                        ? AppColors.secondary
                                        : Colors.grey.shade300,
                                    width: _selectedRight == word ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    word,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: matched ? Colors.green.shade700 : Colors.black87,
                                      decoration: matched ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
