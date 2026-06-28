import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/tts_service.dart';

class VocabularyPage extends StatefulWidget {
  const VocabularyPage({super.key});
  @override
  State<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends State<VocabularyPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  int _selectedTopic = 0;
  int _currentCard = 0;
  bool _cardFlipped = false;
  String? _speakingWord;

  // Quiz state
  int _quizIndex = 0;
  int _quizSelected = -1;
  bool _quizAnswered = false;
  int _quizScore = 0;
  bool _quizDone = false;
  List<Map<String, dynamic>>? _quizWords;

  final _topics = ['All', 'Business', 'Travel', 'Technology', 'Health', 'Food', 'Education', 'Sports', 'Nature', 'Society'];

  final _words = <Map<String, dynamic>>[
    // Business
    {'word': 'Perseverance', 'pronunciation': '/pəˌsɪvɪərəns/', 'definition': 'Continued effort to achieve something despite difficulty', 'example': 'Her perseverance finally paid off after years of hard work.', 'topic': 'Business', 'level': 'B2'},
    {'word': 'Negotiate', 'pronunciation': '/nɪˈɡəʊʃieɪt/', 'definition': 'To discuss something to reach an agreement', 'example': 'We need to negotiate the terms of the contract.', 'topic': 'Business', 'level': 'B1'},
    {'word': 'Entrepreneur', 'pronunciation': '/ˌɒntrəprəˈnɜːr/', 'definition': 'A person who starts and runs their own business', 'example': 'She became a successful entrepreneur at age 25.', 'topic': 'Business', 'level': 'B2'},
    {'word': 'Revenue', 'pronunciation': '/ˈrevənjuː/', 'definition': 'The income that a business receives', 'example': 'The company\'s annual revenue increased by 20%.', 'topic': 'Business', 'level': 'B2'},
    {'word': 'Deadline', 'pronunciation': '/ˈdedlaɪn/', 'definition': 'The latest time by which something must be done', 'example': 'We must submit the report before the deadline.', 'topic': 'Business', 'level': 'A2'},
    // Travel
    {'word': 'Itinerary', 'pronunciation': '/aɪˈtɪnərəri/', 'definition': 'A planned route or journey schedule', 'example': 'We followed our itinerary throughout the trip.', 'topic': 'Travel', 'level': 'B1'},
    {'word': 'Destination', 'pronunciation': '/ˌdestɪˈneɪʃən/', 'definition': 'The place to which someone is travelling', 'example': 'Paris was our final destination.', 'topic': 'Travel', 'level': 'A2'},
    {'word': 'Accommodation', 'pronunciation': '/əˌkɒməˈdeɪʃən/', 'definition': 'A place where someone lives or stays temporarily', 'example': 'We booked accommodation near the city centre.', 'topic': 'Travel', 'level': 'B1'},
    {'word': 'Passport', 'pronunciation': '/ˈpɑːspɔːrt/', 'definition': 'An official document that proves your identity when travelling', 'example': 'Don\'t forget to bring your passport to the airport.', 'topic': 'Travel', 'level': 'A1'},
    {'word': 'Excursion', 'pronunciation': '/ɪkˈskɜːʃən/', 'definition': 'A short journey or trip, especially as part of a holiday', 'example': 'We went on an excursion to the ancient ruins.', 'topic': 'Travel', 'level': 'B1'},
    // Technology
    {'word': 'Algorithm', 'pronunciation': '/ˈælɡərɪðəm/', 'definition': 'A step-by-step procedure for solving a problem', 'example': 'The algorithm sorts data in milliseconds.', 'topic': 'Technology', 'level': 'B2'},
    {'word': 'Bandwidth', 'pronunciation': '/ˈbændwɪdθ/', 'definition': 'The amount of data that can be transmitted over a network', 'example': 'Streaming videos requires a lot of bandwidth.', 'topic': 'Technology', 'level': 'B2'},
    {'word': 'Encryption', 'pronunciation': '/ɪnˈkrɪpʃən/', 'definition': 'Converting data into a code to prevent unauthorised access', 'example': 'All messages are protected by end-to-end encryption.', 'topic': 'Technology', 'level': 'C1'},
    {'word': 'Interface', 'pronunciation': '/ˈɪntəfeɪs/', 'definition': 'A point where two systems or subjects meet and interact', 'example': 'The user interface is very easy to navigate.', 'topic': 'Technology', 'level': 'B1'},
    // Health
    {'word': 'Convalescence', 'pronunciation': '/ˌkɒnvəˈlesəns/', 'definition': 'The process of recovering gradually from illness', 'example': 'She needed three weeks of convalescence after surgery.', 'topic': 'Health', 'level': 'C1'},
    {'word': 'Symptom', 'pronunciation': '/ˈsɪmptəm/', 'definition': 'A physical or mental feature indicating a condition', 'example': 'Fever is a common symptom of infection.', 'topic': 'Health', 'level': 'B1'},
    {'word': 'Immunity', 'pronunciation': '/ɪˈmjuːnɪti/', 'definition': 'The ability to resist infection or disease', 'example': 'Vaccines help build immunity against diseases.', 'topic': 'Health', 'level': 'B2'},
    {'word': 'Diagnosis', 'pronunciation': '/ˌdaɪəɡˈnəʊsɪs/', 'definition': 'Identification of a disease from its signs and symptoms', 'example': 'The doctor gave a diagnosis of high blood pressure.', 'topic': 'Health', 'level': 'B2'},
    // Food
    {'word': 'Culinary', 'pronunciation': '/ˈkʌlɪnəri/', 'definition': 'Relating to cooking or the kitchen', 'example': 'She has excellent culinary skills.', 'topic': 'Food', 'level': 'B2'},
    {'word': 'Appetiser', 'pronunciation': '/ˈæpɪtaɪzər/', 'definition': 'A small dish served before a main meal', 'example': 'We ordered soup as an appetiser.', 'topic': 'Food', 'level': 'B1'},
    {'word': 'Nutritious', 'pronunciation': '/njuːˈtrɪʃəs/', 'definition': 'Providing essential nutrients for health', 'example': 'A nutritious diet includes plenty of vegetables.', 'topic': 'Food', 'level': 'B1'},
    // Education
    {'word': 'Curriculum', 'pronunciation': '/kəˈrɪkjʊləm/', 'definition': 'The subjects comprising a course of study in school', 'example': 'The school updated its curriculum this year.', 'topic': 'Education', 'level': 'B2'},
    {'word': 'Dissertation', 'pronunciation': '/ˌdɪsəˈteɪʃən/', 'definition': 'A long essay on a particular subject, especially for a degree', 'example': 'She spent a year writing her dissertation on linguistics.', 'topic': 'Education', 'level': 'C1'},
    {'word': 'Scholarship', 'pronunciation': '/ˈskɒlərʃɪp/', 'definition': 'A grant of money to support a student\'s education', 'example': 'She received a scholarship to study at Oxford.', 'topic': 'Education', 'level': 'B1'},
    // Sports
    {'word': 'Endurance', 'pronunciation': '/ɪnˈdjʊərəns/', 'definition': 'The ability to sustain prolonged effort or difficulty', 'example': 'Marathon runners need great endurance.', 'topic': 'Sports', 'level': 'B2'},
    {'word': 'Tournament', 'pronunciation': '/ˈtʊənəmənt/', 'definition': 'A series of contests between competitors', 'example': 'She won the regional tennis tournament.', 'topic': 'Sports', 'level': 'B1'},
    // Nature
    {'word': 'Biodiversity', 'pronunciation': '/ˌbaɪəʊdaɪˈvɜːsɪti/', 'definition': 'The variety of plant and animal life in a habitat', 'example': 'The Amazon rainforest has incredible biodiversity.', 'topic': 'Nature', 'level': 'B2'},
    {'word': 'Sustainable', 'pronunciation': '/səˈsteɪnəbəl/', 'definition': 'Able to be maintained without damaging the environment', 'example': 'We need more sustainable farming practices.', 'topic': 'Nature', 'level': 'B1'},
    // Society
    {'word': 'Inequality', 'pronunciation': '/ˌɪnɪˈkwɒlɪti/', 'definition': 'Difference in social status, wealth, or opportunity', 'example': 'Income inequality is a major challenge worldwide.', 'topic': 'Society', 'level': 'B2'},
    {'word': 'Empathy', 'pronunciation': '/ˈempəθi/', 'definition': 'The ability to understand and share another\'s feelings', 'example': 'Good doctors show empathy towards their patients.', 'topic': 'Society', 'level': 'B1'},
    {'word': 'Sovereignty', 'pronunciation': '/ˈsɒvrənti/', 'definition': 'Supreme power or authority over a state', 'example': 'The nation defended its sovereignty.', 'topic': 'Society', 'level': 'C1'},
  ];

  List<Map<String, dynamic>> get _filteredWords {
    final topic = _topics[_selectedTopic];
    final query = _searchCtrl.text.toLowerCase();
    return _words.where((w) {
      final matchesTopic = topic == 'All' || w['topic'] == topic;
      final matchesSearch = query.isEmpty || w['word'].toString().toLowerCase().contains(query) || w['definition'].toString().toLowerCase().contains(query);
      return matchesTopic && matchesSearch;
    }).toList();
  }

  List<Map<String, dynamic>> get _flashcardWords {
    final topic = _topics[_selectedTopic];
    if (topic == 'All') return _words;
    return _words.where((w) => w['topic'] == topic).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() { if (_tabController.indexIsChanging) setState(() {}); });
    _initQuiz();
  }

  void _initQuiz() {
    final shuffled = List<Map<String, dynamic>>.from(_words)..shuffle();
    _quizWords = shuffled.take(10).toList();
    _quizIndex = 0; _quizSelected = -1; _quizAnswered = false; _quizScore = 0; _quizDone = false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    TtsService.stop();
    super.dispose();
  }

  void _speak(String word) {
    setState(() => _speakingWord = word);
    TtsService.speak(word, lang: 'en-US', rate: 0.75);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _speakingWord = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'Words'), Tab(text: 'Flashcards'), Tab(text: 'Quiz')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildWordList(), _buildFlashcards(), _buildQuiz()],
      ),
    );
  }

  Widget _buildWordList() {
    final filtered = _filteredWords;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search words or definitions...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true, fillColor: Colors.grey[100],
            ),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedTopic == i ? AppColors.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_topics[i], style: TextStyle(color: _selectedTopic == i ? Colors.white : Colors.black87, fontSize: 13)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(children: [
            Text('${filtered.length} words', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const Spacer(),
            const Icon(Icons.volume_up, size: 13, color: Colors.grey),
            const SizedBox(width: 4),
            const Text('Tap speaker to hear pronunciation', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No words found.', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _WordCard(word: filtered[i], onSpeak: _speak, speakingWord: _speakingWord),
                ),
        ),
      ],
    );
  }

  Widget _buildFlashcards() {
    final words = _flashcardWords;
    if (words.isEmpty) return const Center(child: Text('No words in this topic.', style: TextStyle(color: Colors.grey)));
    final idx = _currentCard % words.length;
    final w = words[idx];

    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(children: [
            Text('${idx + 1} / ${words.length}', style: const TextStyle(color: Colors.grey)),
            const Spacer(),
            Row(children: [
              Icon(Icons.volume_up, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text('Tap card to flip', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            ]),
          ]),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: LinearProgressIndicator(value: (idx + 1) / words.length, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation(AppColors.primary), borderRadius: BorderRadius.circular(4), minHeight: 6),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: () => setState(() => _cardFlipped = !_cardFlipped),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                child: _cardFlipped
                    ? _FlashCardBack(key: const ValueKey('back'), word: w)
                    : _FlashCardFront(key: const ValueKey('front'), word: w, onSpeak: _speak, speakingWord: _speakingWord),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: _cardFlipped
              ? Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('Hard', style: TextStyle(color: Colors.red)),
                    onPressed: () => setState(() { _cardFlipped = false; _currentCard = (idx + 1) % words.length; }),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Got it!'),
                    onPressed: () => setState(() { _cardFlipped = false; _currentCard = (idx + 1) % words.length; }),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  )),
                ])
              : SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  icon: const Icon(Icons.flip),
                  label: const Text('Flip to see definition'),
                  onPressed: () => setState(() => _cardFlipped = true),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                )),
        ),
      ],
    );
  }

  Widget _buildQuiz() {
    if (_quizDone) return _buildQuizResults();
    final words = _quizWords!;
    final w = words[_quizIndex];

    // Build 4 options: correct + 3 random wrong
    final correctDef = w['definition'] as String;
    final wrongWords = List<Map<String, dynamic>>.from(_words)
      ..removeWhere((x) => x['word'] == w['word'])
      ..shuffle();
    final options = <String>[correctDef, ...wrongWords.take(3).map((x) => x['definition'] as String)]..shuffle();
    final correctIndex = options.indexOf(correctDef);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        Row(children: [
          Text('Question ${_quizIndex + 1} of ${words.length}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(20)),
            child: Text('Score: $_quizScore', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: (_quizIndex + 1) / words.length, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation(AppColors.primary), borderRadius: BorderRadius.circular(4), minHeight: 6),
        const SizedBox(height: 24),
        const Text('What is the definition of:', style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            Text(w['word'] as String, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(w['pronunciation'] as String, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _speak(w['word'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.volume_up, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text('Hear it', style: TextStyle(color: Colors.white, fontSize: 14)),
                ]),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 24),
        const Text('Choose the correct definition:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 12),
        ...options.asMap().entries.map((e) {
          Color bg = Colors.white;
          Color borderColor = Colors.grey[300]!;
          Color textColor = Colors.black87;

          if (_quizAnswered) {
            if (e.key == correctIndex) { bg = Colors.green[50]!; borderColor = Colors.green; textColor = Colors.green[900]!; }
            else if (e.key == _quizSelected) { bg = Colors.red[50]!; borderColor = Colors.red; textColor = Colors.red[900]!; }
          } else if (e.key == _quizSelected) {
            bg = AppColors.primary.withOpacity(0.07); borderColor = AppColors.primary; textColor = AppColors.primary;
          }

          return GestureDetector(
            onTap: _quizAnswered ? null : () => setState(() => _quizSelected = e.key),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: bg, border: Border.all(color: borderColor, width: 1.5), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: borderColor.withOpacity(0.15), border: Border.all(color: borderColor)),
                  child: Center(child: Text(String.fromCharCode(65 + e.key), style: TextStyle(fontWeight: FontWeight.bold, color: borderColor == Colors.grey[300] ? Colors.grey : borderColor, fontSize: 13))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(e.value, style: TextStyle(fontSize: 14, color: textColor, height: 1.4))),
              ]),
            ),
          );
        }),

        if (_quizAnswered) ...[
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _quizSelected == correctIndex ? Colors.green[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _quizSelected == correctIndex ? Colors.green[200]! : Colors.orange[200]!),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(_quizSelected == correctIndex ? Icons.check_circle : Icons.info_outline, color: _quizSelected == correctIndex ? Colors.green[700] : Colors.orange[700], size: 18),
                const SizedBox(width: 8),
                Text(_quizSelected == correctIndex ? 'Correct!' : 'Not quite.', style: TextStyle(fontWeight: FontWeight.bold, color: _quizSelected == correctIndex ? Colors.green[800] : Colors.orange[800])),
              ]),
              const SizedBox(height: 6),
              Text('"${w['example']}"', style: TextStyle(color: _quizSelected == correctIndex ? Colors.green[900] : Colors.orange[900], fontStyle: FontStyle.italic, fontSize: 13)),
            ]),
          ),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              if (_quizIndex < words.length - 1) {
                setState(() { _quizIndex++; _quizSelected = -1; _quizAnswered = false; });
              } else {
                setState(() => _quizDone = true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(_quizIndex < words.length - 1 ? 'Next Question' : 'See Results'),
          )),
        ] else if (_quizSelected >= 0)
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              if (_quizSelected == correctIndex) _quizScore++;
              setState(() => _quizAnswered = true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Check Answer'),
          )),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _buildQuizResults() {
    final total = _quizWords!.length;
    final pct = (_quizScore / total * 100).round();
    final Color c = pct >= 70 ? Colors.green : (pct >= 50 ? Colors.orange : Colors.red);
    final String msg = pct >= 70 ? 'Great vocabulary knowledge!' : (pct >= 50 ? 'Good effort! Keep studying.' : 'Keep practising — you\'ll improve!');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.withOpacity(0.1), border: Border.all(color: c, width: 4)),
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('$pct%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: c)),
              Text('$_quizScore/$total', style: TextStyle(color: c, fontSize: 13)),
            ])),
          ),
          const SizedBox(height: 24),
          Text('Vocabulary Quiz Complete!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(msg, style: TextStyle(color: c, fontSize: 15), textAlign: TextAlign.center),
          const SizedBox(height: 40),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            onPressed: () => setState(() => _initQuiz()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            icon: const Icon(Icons.menu_book),
            label: const Text('Study Words'),
            onPressed: () => setState(() { _tabController.animateTo(0); _quizDone = false; }),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )),
        ]),
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final Map<String, dynamic> word;
  final void Function(String) onSpeak;
  final String? speakingWord;
  const _WordCard({required this.word, required this.onSpeak, this.speakingWord});

  Color get _levelColor {
    switch (word['level'] as String) {
      case 'A1': return Colors.green;
      case 'A2': return Colors.teal;
      case 'B1': return Colors.blue;
      case 'B2': return Colors.orange;
      case 'C1': return Colors.purple;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSpeaking = speakingWord == word['word'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(word['word'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: _levelColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(word['level'] as String, style: TextStyle(fontSize: 11, color: _levelColor, fontWeight: FontWeight.bold)),
                ),
              ]),
              const SizedBox(height: 3),
              Text(word['pronunciation'] as String, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ])),
            GestureDetector(
              onTap: () => onSpeak(word['word'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: isSpeaking ? AppColors.primary : AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(isSpeaking ? Icons.stop_rounded : Icons.volume_up, color: isSpeaking ? Colors.white : AppColors.primary, size: 20),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Text(word['definition'] as String, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
          const SizedBox(height: 6),
          Text('"${word['example']}"', style: const TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic, height: 1.4)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(8)),
            child: Text(word['topic'] as String, style: TextStyle(fontSize: 11, color: Colors.teal[700], fontWeight: FontWeight.w500)),
          ),
        ]),
      ),
    );
  }
}

class _FlashCardFront extends StatelessWidget {
  final Map<String, dynamic> word;
  final void Function(String) onSpeak;
  final String? speakingWord;
  const _FlashCardFront({super.key, required this.word, required this.onSpeak, this.speakingWord});

  @override
  Widget build(BuildContext context) {
    final isSpeaking = speakingWord == word['word'];
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(word['level'] as String, style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 2)),
        const SizedBox(height: 12),
        Text(word['word'] as String, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(word['pronunciation'] as String, style: const TextStyle(color: Colors.white70, fontSize: 17)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => onSpeak(word['word'] as String),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(30)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(isSpeaking ? Icons.stop_rounded : Icons.volume_up, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(isSpeaking ? 'Stop' : 'Hear pronunciation', style: const TextStyle(color: Colors.white, fontSize: 14)),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Tap card to see definition', style: TextStyle(color: Colors.white38, fontSize: 12)),
      ]),
    );
  }
}

class _FlashCardBack extends StatelessWidget {
  final Map<String, dynamic> word;
  const _FlashCardBack({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green[400]!, Colors.teal[600]!]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('Definition', style: TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 1)),
        const SizedBox(height: 12),
        Text(word['definition'] as String, style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.6), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
          child: Text('"${word['example']}"', style: const TextStyle(color: Colors.white80, fontStyle: FontStyle.italic, fontSize: 14, height: 1.5), textAlign: TextAlign.center),
        ),
        const SizedBox(height: 16),
        const Text('Tap card to flip back', style: TextStyle(color: Colors.white38, fontSize: 12)),
      ]),
    );
  }
}
