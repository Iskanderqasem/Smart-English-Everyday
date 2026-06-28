import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class VocabularyPage extends StatefulWidget {
  const VocabularyPage({super.key});
  @override
  State<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends State<VocabularyPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  int _selectedTopic = 0;
  bool _showFlashcard = false;
  int _currentCard = 0;
  bool _cardFlipped = false;

  final _topics = ['All', 'Travel', 'Business', 'Technology', 'Health', 'Food', 'Education', 'Sports', 'Shopping'];

  final _words = [
    {'word': 'Perseverance', 'pronunciation': '/pəˌsɪvɪərəns/', 'definition': 'Continued effort to do or achieve something despite difficulty', 'example': 'Her perseverance finally paid off after years of hard work.', 'topic': 'Business', 'level': 'B2'},
    {'word': 'Itinerary', 'pronunciation': '/aɪˈtɪnərəri/', 'definition': 'A planned route or journey', 'example': 'We followed our itinerary throughout the trip.', 'topic': 'Travel', 'level': 'B1'},
    {'word': 'Algorithm', 'pronunciation': '/ˈælɡərɪðəm/', 'definition': 'A step-by-step procedure for solving a problem', 'example': 'The algorithm sorts data in milliseconds.', 'topic': 'Technology', 'level': 'B2'},
    {'word': 'Convalescence', 'pronunciation': '/ˌkɒnvəˈlesəns/', 'definition': 'The process of recovering from illness', 'example': 'She needed three weeks of convalescence after surgery.', 'topic': 'Health', 'level': 'C1'},
    {'word': 'Culinary', 'pronunciation': '/ˈkʌlɪnəri/', 'definition': 'Relating to cooking or the kitchen', 'example': 'She has excellent culinary skills.', 'topic': 'Food', 'level': 'B2'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'Words'), Tab(text: 'Flashcards'), Tab(text: 'Review')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildWordList(), _buildFlashcards(), _buildReview()],
      ),
    );
  }

  Widget _buildWordList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search words...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true, fillColor: Colors.grey[100],
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _topics.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => setState(() => _selectedTopic = i),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedTopic == i ? AppColors.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_topics[i], style: TextStyle(color: _selectedTopic == i ? Colors.white : Colors.black87)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _words.length,
            itemBuilder: (_, i) {
              final w = _words[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Row(children: [
                    Text(w['word']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(w['level']!, style: const TextStyle(fontSize: 11, color: AppColors.primary))),
                  ]),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(w['pronunciation']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(w['definition']!, style: const TextStyle(fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ]),
                  trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.volume_up, color: AppColors.primary),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(8)),
                      child: Text(w['topic']!, style: TextStyle(fontSize: 10, color: Colors.teal[700]))),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFlashcards() {
    final w = _words[_currentCard];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${_currentCard + 1} / ${_words.length}', style: const TextStyle(color: Colors.grey)),
            Text('Tap to flip', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: (_currentCard + 1) / _words.length, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation(AppColors.primary), borderRadius: BorderRadius.circular(4), minHeight: 6),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => setState(() => _cardFlipped = !_cardFlipped),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: _cardFlipped ? [Colors.green[400]!, Colors.teal[600]!] : [AppColors.primary, AppColors.secondary]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: (_cardFlipped ? Colors.green : AppColors.primary).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _cardFlipped
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(w['definition']!, style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.5), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Text('"${w['example']}"', style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 14), textAlign: TextAlign.center),
                      ])
                    : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(w['word']!, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(w['pronunciation']!, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 16),
                        const Icon(Icons.volume_up, color: Colors.white, size: 32),
                      ]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (_cardFlipped) Row(children: [
            Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.close, color: Colors.red), label: const Text('Hard', style: TextStyle(color: Colors.red)), onPressed: _nextCard, style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.check), label: const Text('Easy'), onPressed: _nextCard, style: ElevatedButton.styleFrom(backgroundColor: Colors.green))),
          ]) else Center(child: TextButton.icon(icon: const Icon(Icons.flip), label: const Text('Flip Card'), onPressed: () => setState(() => _cardFlipped = true))),
        ],
      ),
    );
  }

  Widget _buildReview() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Daily Review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Text('Words due for review based on spaced repetition', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        ..._words.take(3).map((w) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(w['word']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(w['pronunciation']!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('What does this word mean?', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(decoration: InputDecoration(hintText: 'Type the definition...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8))),
          ]),
        )),
      ],
    );
  }

  void _nextCard() {
    setState(() {
      _cardFlipped = false;
      _currentCard = (_currentCard + 1) % _words.length;
    });
  }
}
