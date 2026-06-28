import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WordSearchGame extends StatefulWidget {
  const WordSearchGame({super.key});
  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  final _words = ['HAPPY', 'SMART', 'LEARN', 'SPEAK', 'WRITE', 'READ'];
  final Set<String> _found = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Word Search'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Text('Find ${_words.length} words hidden in the grid', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Column(children: _buildGrid()),
          ),
          const SizedBox(height: 20),
          Wrap(spacing: 10, runSpacing: 8, children: _words.map((w) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _found.contains(w) ? Colors.green[100] : Colors.white,
              border: Border.all(color: _found.contains(w) ? Colors.green : Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(w, style: TextStyle(fontWeight: FontWeight.bold, decoration: _found.contains(w) ? TextDecoration.lineThrough : null, color: _found.contains(w) ? Colors.green[800] : Colors.black87)),
          )).toList()),
          const SizedBox(height: 16),
          Text('Found: ${_found.length}/${_words.length}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  List<Widget> _buildGrid() {
    final grid = [
      ['H','A','P','P','Y','X','Z','Q'],
      ['S','M','A','R','T','W','R','A'],
      ['P','X','L','E','A','R','N','B'],
      ['E','Y','Q','A','S','I','T','C'],
      ['A','Z','R','D','P','T','E','D'],
      ['K','W','R','I','T','E','M','E'],
      ['X','R','E','A','D','Z','Q','F'],
      ['B','C','D','E','F','G','H','I'],
    ];
    return grid.map((row) => Row(mainAxisAlignment: MainAxisAlignment.center,
      children: row.map((c) => GestureDetector(
        onTap: () {},
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
          child: Center(child: Text(c, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
        ),
      )).toList(),
    )).toList();
  }
}
