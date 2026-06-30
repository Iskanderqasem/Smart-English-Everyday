import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../main.dart';
import '../../../../shared/services/storage_service.dart';

class WordSearchGame extends StatefulWidget {
  const WordSearchGame({super.key});

  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  static const int _gridSize = 10;
  static const double _cellSize = 36.0;

  final List<Map<String, dynamic>> _themes = [
    {
      'name': 'Emotions',
      'words': ['HAPPY', 'BRAVE', 'CALM', 'PROUD', 'EAGER', 'JOYFUL'],
    },
    {
      'name': 'English',
      'words': ['SPEAK', 'WRITE', 'LEARN', 'STUDY', 'SPELL', 'FLUENT'],
    },
    {
      'name': 'Nature',
      'words': ['OCEAN', 'RIVER', 'CLOUD', 'EARTH', 'GRASS', 'STORM'],
    },
    {
      'name': 'Animals',
      'words': ['EAGLE', 'TIGER', 'WHALE', 'SNAKE', 'HORSE', 'SHEEP'],
    },
    {
      'name': 'Travel',
      'words': ['HOTEL', 'BEACH', 'TRAIN', 'PLANE', 'GUIDE', 'MONEY'],
    },
  ];

  late List<List<String>> _grid;
  late List<String> _words;
  late String _themeName;
  late Map<String, List<List<int>>> _wordCells;
  final Set<String> _found = {};

  List<List<int>> _selecting = [];
  List<int>? _startCell;

  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    final theme = _themes[_rng.nextInt(_themes.length)];
    _themeName = theme['name'] as String;
    _words = List<String>.from(theme['words'] as List);
    _found.clear();
    _selecting = [];
    _startCell = null;
    _wordCells = {};
    _grid = _buildGrid();
  }

  List<List<String>> _buildGrid() {
    final grid = List.generate(_gridSize, (_) => List.filled(_gridSize, ''));
    const directions = [
      [0, 1],
      [1, 0],
      [1, 1],
      [1, -1],
    ];

    for (final word in _words) {
      bool placed = false;
      int attempts = 0;
      while (!placed && attempts < 200) {
        attempts++;
        final dir = directions[_rng.nextInt(directions.length)];
        final dr = dir[0];
        final dc = dir[1];
        final startR = _rng.nextInt(_gridSize);
        final startC = _rng.nextInt(_gridSize);
        final endR = startR + dr * (word.length - 1);
        final endC = startC + dc * (word.length - 1);
        if (endR < 0 || endR >= _gridSize || endC < 0 || endC >= _gridSize) {
          continue;
        }
        bool canPlace = true;
        for (int i = 0; i < word.length; i++) {
          final r = startR + dr * i;
          final c = startC + dc * i;
          if (grid[r][c] != '' && grid[r][c] != word[i]) {
            canPlace = false;
            break;
          }
        }
        if (canPlace) {
          final cells = <List<int>>[];
          for (int i = 0; i < word.length; i++) {
            final r = startR + dr * i;
            final c = startC + dc * i;
            grid[r][c] = word[i];
            cells.add([r, c]);
          }
          _wordCells[word] = cells;
          placed = true;
        }
      }
    }

    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (int r = 0; r < _gridSize; r++) {
      for (int c = 0; c < _gridSize; c++) {
        if (grid[r][c] == '') {
          grid[r][c] = letters[_rng.nextInt(letters.length)];
        }
      }
    }
    return grid;
  }

  bool _isCellFound(int r, int c) {
    for (final word in _found) {
      final cells = _wordCells[word];
      if (cells != null) {
        for (final cell in cells) {
          if (cell[0] == r && cell[1] == c) return true;
        }
      }
    }
    return false;
  }

  bool _isCellSelecting(int r, int c) {
    for (final cell in _selecting) {
      if (cell[0] == r && cell[1] == c) return true;
    }
    return false;
  }

  List<List<int>> _cellsAlongDirection(int startR, int startC, int endR, int endC) {
    final dr = endR - startR;
    final dc = endC - startC;

    int dirR = 0;
    int dirC = 0;

    if (dr == 0 && dc == 0) {
      return [[startR, startC]];
    }

    final absDr = dr.abs();
    final absDc = dc.abs();

    if (absDr == 0) {
      dirR = 0;
      dirC = dc > 0 ? 1 : -1;
    } else if (absDc == 0) {
      dirR = dr > 0 ? 1 : -1;
      dirC = 0;
    } else if ((absDr - absDc).abs() <= (absDr > absDc ? absDr : absDc) * 0.5) {
      dirR = dr > 0 ? 1 : -1;
      dirC = dc > 0 ? 1 : -1;
    } else if (absDr > absDc) {
      dirR = dr > 0 ? 1 : -1;
      dirC = 0;
    } else {
      dirR = 0;
      dirC = dc > 0 ? 1 : -1;
    }

    final steps = dirR != 0 && dirC != 0
        ? (absDr > absDc ? absDr : absDc)
        : (dirR != 0 ? absDr : absDc);

    final cells = <List<int>>[];
    for (int i = 0; i <= steps; i++) {
      final r = (startR + dirR * i).clamp(0, _gridSize - 1);
      final c = (startC + dirC * i).clamp(0, _gridSize - 1);
      cells.add([r, c]);
    }
    return cells;
  }

  void _onPanStart(DragStartDetails details) {
    final row = (details.localPosition.dy / _cellSize).floor().clamp(0, _gridSize - 1);
    final col = (details.localPosition.dx / _cellSize).floor().clamp(0, _gridSize - 1);
    setState(() {
      _startCell = [row, col];
      _selecting = [[row, col]];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_startCell == null) return;
    final row = (details.localPosition.dy / _cellSize).floor().clamp(0, _gridSize - 1);
    final col = (details.localPosition.dx / _cellSize).floor().clamp(0, _gridSize - 1);
    setState(() {
      _selecting = _cellsAlongDirection(_startCell![0], _startCell![1], row, col);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_selecting.isEmpty) return;
    final selectedWord = _selecting.map((c) => _grid[c[0]][c[1]]).join();
    final reversed = selectedWord.split('').reversed.join();
    String? foundWord;
    for (final word in _words) {
      if (word == selectedWord || word == reversed) {
        foundWord = word;
        break;
      }
    }
    if (foundWord != null && !_found.contains(foundWord)) {
      setState(() {
        _found.add(foundWord!);
      });
      _onWordFound(foundWord);
    }
    setState(() {
      _selecting = [];
      _startCell = null;
    });
  }

  Future<void> _onWordFound(String word) async {
    final storage = sl<StorageService>();
    final current = storage.getInt('total_xp', defaultValue: 0);
    int bonus = 10;
    if (_found.length == _words.length) {
      bonus = 30;
      await storage.saveInt('total_xp', current + bonus);
      _showCelebration();
    } else {
      await storage.saveInt('total_xp', current + bonus);
    }
  }

  void _showCelebration() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('\u{1F389} Excellent!'),
        content: const Text('All words found! You earned 60 XP!'),
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

  @override
  Widget build(BuildContext context) {
    final xpEarned = _found.length * 10;
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Search - $_themeName'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                'XP Earned: $xpEarned',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_gridSize, (r) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(_gridSize, (c) {
                              final isFound = _isCellFound(r, c);
                              final isSelecting = _isCellSelecting(r, c);
                              Color bg = Colors.grey.shade100;
                              Color fg = Colors.black87;
                              if (isFound) {
                                bg = Colors.green.shade300;
                                fg = Colors.white;
                              } else if (isSelecting) {
                                bg = AppColors.primary.withOpacity(0.4);
                                fg = Colors.white;
                              }
                              return Container(
                                width: _cellSize,
                                height: _cellSize,
                                decoration: BoxDecoration(
                                  color: bg,
                                  border: Border.all(color: Colors.grey.shade300, width: 0.5),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _grid[r][c],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: fg,
                                  ),
                                ),
                              );
                            }),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _words.map((word) {
                  final done = _found.contains(word);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: done ? Colors.green.shade100 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: done ? Colors.green : Colors.grey.shade400,
                      ),
                    ),
                    child: Text(
                      word,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: done ? Colors.green.shade800 : Colors.grey.shade700,
                        decoration: done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                '${_found.length} / ${_words.length} words found',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
