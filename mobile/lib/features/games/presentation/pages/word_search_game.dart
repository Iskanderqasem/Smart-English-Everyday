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
  static const int _size = 10;
  static const double _cellSize = 34.0;

  final _gridKey = GlobalKey();
  final _rng = Random();

  static const _themes = [
    {'name': 'Emotions',  'words': ['HAPPY', 'BRAVE', 'CALM', 'PROUD', 'EAGER', 'KIND']},
    {'name': 'English',   'words': ['SPEAK', 'WRITE', 'LEARN', 'STUDY', 'SPELL', 'WORDS']},
    {'name': 'Nature',    'words': ['OCEAN', 'RIVER', 'CLOUD', 'EARTH', 'GRASS', 'STORM']},
    {'name': 'Animals',   'words': ['EAGLE', 'TIGER', 'WHALE', 'SNAKE', 'HORSE', 'SHEEP']},
    {'name': 'Travel',    'words': ['HOTEL', 'BEACH', 'TRAIN', 'PLANE', 'GUIDE', 'MONEY']},
  ];

  late List<List<String>> _grid;
  late List<String> _words;
  late String _themeName;
  late Map<String, List<List<int>>> _wordCells;
  final Set<String> _found = {};
  List<List<int>> _selecting = [];
  bool _showCelebration = false;
  List<int>? _dragStart;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    final theme = _themes[_rng.nextInt(_themes.length)];
    _themeName = theme['name'] as String;
    _words = List<String>.from(theme['words'] as List);
    _found.clear();
    _selecting = [];
    _showCelebration = false;
    _wordCells = {};
    _dragStart = null;
    _grid = _makeGrid();
  }

  List<List<String>> _makeGrid() {
    final g = List.generate(_size, (_) => List.filled(_size, ''));
    const dirs = [[0,1],[1,0],[1,1],[1,-1]];
    for (final word in _words) {
      for (var attempt = 0; attempt < 300; attempt++) {
        final d = dirs[_rng.nextInt(dirs.length)];
        final r0 = _rng.nextInt(_size);
        final c0 = _rng.nextInt(_size);
        final cells = <List<int>>[];
        bool ok = true;
        for (var i = 0; i < word.length; i++) {
          final r = r0 + d[0] * i;
          final c = c0 + d[1] * i;
          if (r < 0 || r >= _size || c < 0 || c >= _size) { ok = false; break; }
          if (g[r][c] != '' && g[r][c] != word[i]) { ok = false; break; }
          cells.add([r, c]);
        }
        if (ok) {
          for (var i = 0; i < word.length; i++) g[cells[i][0]][cells[i][1]] = word[i];
          _wordCells[word] = cells;
          break;
        }
      }
    }
    const abc = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (var r = 0; r < _size; r++) {
      for (var c = 0; c < _size; c++) {
        if (g[r][c] == '') g[r][c] = abc[_rng.nextInt(26)];
      }
    }
    return g;
  }

  List<int>? _globalToCell(Offset global) {
    final box = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final local = box.globalToLocal(global);
    final r = (local.dy / _cellSize).floor();
    final c = (local.dx / _cellSize).floor();
    if (r < 0 || r >= _size || c < 0 || c >= _size) return null;
    return [r, c];
  }

  List<List<int>> _line(List<int> start, List<int> end) {
    final dr = end[0] - start[0];
    final dc = end[1] - start[1];
    if (dr == 0 && dc == 0) return [start];
    final absDr = dr.abs();
    final absDc = dc.abs();
    int dirR, dirC;
    if (absDr == 0) {
      dirR = 0; dirC = dc.sign;
    } else if (absDc == 0) {
      dirR = dr.sign; dirC = 0;
    } else if ((absDr - absDc).abs() * 2 <= (absDr > absDc ? absDr : absDc)) {
      dirR = dr.sign; dirC = dc.sign;
    } else if (absDr > absDc) {
      dirR = dr.sign; dirC = 0;
    } else {
      dirR = 0; dirC = dc.sign;
    }
    final steps = (dirR != 0 && dirC != 0)
        ? (absDr > absDc ? absDr : absDc)
        : (dirR != 0 ? absDr : absDc);
    return List.generate(steps + 1, (i) {
      final r = (start[0] + dirR * i).clamp(0, _size - 1);
      final c = (start[1] + dirC * i).clamp(0, _size - 1);
      return [r, c];
    });
  }

  void _onPointerDown(PointerDownEvent e) {
    final cell = _globalToCell(e.position);
    if (cell == null) return;
    setState(() { _dragStart = cell; _selecting = [cell]; });
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (_dragStart == null) return;
    final cell = _globalToCell(e.position);
    if (cell == null) return;
    setState(() => _selecting = _line(_dragStart!, cell));
  }

  void _onPointerUp(PointerUpEvent e) {
    if (_selecting.length >= 2) {
      final forward = _selecting.map((c) => _grid[c[0]][c[1]]).join();
      final backward = forward.split('').reversed.join();
      for (final w in _words) {
        if (!_found.contains(w) && (w == forward || w == backward)) {
          setState(() => _found.add(w));
          _awardXp(10);
          if (_found.length == _words.length) {
            _awardXp(20);
            Future.delayed(const Duration(milliseconds: 300),
                () { if (mounted) setState(() => _showCelebration = true); });
          }
          break;
        }
      }
    }
    setState(() { _selecting = []; _dragStart = null; });
  }

  Future<void> _awardXp(int amount) async {
    final s = sl<StorageService>();
    await s.saveInt('total_xp', s.getInt('total_xp', defaultValue: 0) + amount);
  }

  bool _isFound(int r, int c) => _found.any(
      (w) => _wordCells[w]?.any((cell) => cell[0] == r && cell[1] == c) ?? false);

  bool _isSel(int r, int c) => _selecting.any((cell) => cell[0] == r && cell[1] == c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Search — $_themeName'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'New Game',
              onPressed: () => setState(_newGame)),
        ],
      ),
      body: SafeArea(child: _showCelebration ? _buildWin() : _buildGame()),
    );
  }

  Widget _buildGame() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          'Drag across letters to find the words',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          '${_found.length}/${_words.length} found  •  XP: ${_found.length * 10}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Center(
          child: Listener(
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            child: Container(
              key: _gridKey,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_size, (r) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_size, (c) {
                    final found = _isFound(r, c);
                    final sel = _isSel(r, c);
                    Color bg = r.isEven == c.isEven ? Colors.white : Colors.grey.shade50;
                    Color fg = Colors.black87;
                    if (found) { bg = Colors.green.shade400; fg = Colors.white; }
                    else if (sel) { bg = Colors.blue.shade400; fg = Colors.white; }
                    return Container(
                      width: _cellSize, height: _cellSize,
                      decoration: BoxDecoration(
                        color: bg,
                        border: Border.all(color: Colors.grey.shade200, width: 0.3),
                      ),
                      alignment: Alignment.center,
                      child: Text(_grid[r][c],
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: fg)),
                    );
                  }),
                )),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
            children: _words.map((w) {
              final done = _found.contains(w);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: done ? Colors.green.shade100 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: done ? Colors.green : Colors.grey.shade400),
                ),
                child: Text(w, style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: done ? Colors.green.shade800 : Colors.black87,
                  decoration: done ? TextDecoration.lineThrough : null,
                )),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWin() {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🎉', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        const Text('All words found!',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('You earned ${_words.length * 10 + 20} XP!',
            style: const TextStyle(fontSize: 18, color: Colors.green)),
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
        TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Back to Games')),
      ]),
    ));
  }
}
