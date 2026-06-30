import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/tts_service.dart';
import '../../../../main.dart';
import '../../../../shared/services/storage_service.dart';

class ListeningPage extends StatefulWidget {
  const ListeningPage({super.key});
  @override
  State<ListeningPage> createState() => _ListeningPageState();
}

class _ListeningPageState extends State<ListeningPage> {
  String _filterAccent = 'All';
  Map<String, dynamic>? _active;
  bool _isPlaying = false;
  bool _showTranscript = false;
  int _questionIndex = 0;
  int _selectedAnswer = -1;
  bool _answered = false;
  int _score = 0;
  bool _done = false;
  Timer? _progressTimer;
  double _progress = 0.0;
  int _elapsed = 0;

  Set<String> _completedLessons = {};

  final _accents = ['All', 'British', 'American', 'Australian', 'Canadian', 'New Zealand'];

  final _lessons = <Map<String, dynamic>>[
    {
      'title': 'A Day in London',
      'accent': 'British',
      'accentCode': 'en-GB',
      'level': 'B1',
      'topic': 'Daily Life',
      'text': 'Good morning! Today I am going to tell you about a typical day in London. I usually start my day by taking the underground, which locals call the Tube, to get to work. It is the most efficient way to travel in this busy city. London has one of the oldest metro systems in the world, dating back to eighteen sixty three. After work, I often visit one of the many parks. Hyde Park is my favourite because it is huge and very peaceful. In the evenings, Londoners enjoy going to the pub with friends. The pub is a very important part of British culture and social life.',
      'questions': [
        {'q': 'What do Londoners call the underground?', 'opts': ['The Metro', 'The Tube', 'The Rail', 'The Sub'], 'a': 1},
        {'q': 'When was the London underground built?', 'opts': ['1800', '1840', '1863', '1900'], 'a': 2},
        {'q': 'Which park is the speaker\'s favourite?', 'opts': ['Regent\'s Park', 'Green Park', 'Victoria Park', 'Hyde Park'], 'a': 3},
        {'q': 'What does the speaker say about pubs?', 'opts': ['They are expensive', 'They are dying out', 'They are important in British culture', 'They are only for tourists'], 'a': 2},
      ],
    },
    {
      'title': 'Ordering Coffee in New York',
      'accent': 'American',
      'accentCode': 'en-US',
      'level': 'A2',
      'topic': 'Shopping',
      'text': 'Welcome to Central Perk Coffee! What can I get you today? We have a wide selection of coffees, teas, and pastries. Our most popular drink is the caramel macchiato. It is made with espresso, steamed milk, and a drizzle of caramel syrup on top. We also have a great seasonal special right now, the pumpkin spice latte. It is only available in autumn. Would you like to try a free sample? All of our coffee beans are sourced from small farms in Colombia and Ethiopia. We believe in fair trade and sustainable farming practices.',
      'questions': [
        {'q': 'What is the most popular drink at the cafe?', 'opts': ['Pumpkin spice latte', 'Espresso', 'Caramel macchiato', 'Green tea'], 'a': 2},
        {'q': 'When is the pumpkin spice latte available?', 'opts': ['All year', 'In summer', 'In winter', 'In autumn'], 'a': 3},
        {'q': 'Where do the coffee beans come from?', 'opts': ['Brazil and Vietnam', 'Colombia and Ethiopia', 'Kenya and Peru', 'Indonesia and India'], 'a': 1},
        {'q': 'What does the cafe believe in?', 'opts': ['Mass production', 'Fast delivery', 'Fair trade and sustainable farming', 'Low prices'], 'a': 2},
      ],
    },
    {
      'title': 'The Great Barrier Reef',
      'accent': 'Australian',
      'accentCode': 'en-AU',
      'level': 'B2',
      'topic': 'Nature',
      'text': 'G\'day and welcome to our tour of the Great Barrier Reef. The Great Barrier Reef is the world\'s largest coral reef system. It stretches for over two thousand three hundred kilometres along the Queensland coast of Australia. The reef is home to an extraordinary diversity of marine life, including more than one thousand five hundred species of fish. However, the reef is under serious threat from climate change. Rising ocean temperatures cause a process called coral bleaching, where the coral loses its colour and eventually dies. Scientists estimate that fifty percent of the reef has already been damaged. Conservation efforts are critical to protect this natural wonder for future generations.',
      'questions': [
        {'q': 'How long is the Great Barrier Reef?', 'opts': ['1,200 km', '1,800 km', '2,300 km', '3,000 km'], 'a': 2},
        {'q': 'How many species of fish live in the reef?', 'opts': ['More than 500', 'More than 1,000', 'More than 1,500', 'More than 2,000'], 'a': 2},
        {'q': 'What causes coral bleaching?', 'opts': ['Pollution', 'Rising ocean temperatures', 'Fishing', 'Storms'], 'a': 1},
        {'q': 'What percentage of the reef has been damaged?', 'opts': ['20%', '35%', '50%', '70%'], 'a': 2},
      ],
    },
    {
      'title': 'Job Interview Tips',
      'accent': 'Canadian',
      'accentCode': 'en-CA',
      'level': 'B2',
      'topic': 'Business',
      'text': 'Hi there, and welcome to today\'s career coaching session. Whether you are applying for your first job or looking to change careers, a strong interview performance can make all the difference. First, always research the company thoroughly before your interview. Know their mission, their products, and their recent news. Second, prepare examples of your past achievements using the STAR method, which stands for Situation, Task, Action, and Result. Third, dress professionally and arrive ten to fifteen minutes early. First impressions matter enormously. Finally, prepare thoughtful questions to ask the interviewer. This shows genuine interest and engagement. Remember, an interview is a two-way conversation, not just an assessment.',
      'questions': [
        {'q': 'What does STAR stand for?', 'opts': ['Skills, Talent, Ability, Results', 'Situation, Task, Action, Result', 'Strategy, Timing, Awareness, Resilience', 'Success, Training, Attitude, Resourcefulness'], 'a': 1},
        {'q': 'How early should you arrive for an interview?', 'opts': ['5 minutes', '10-15 minutes', '30 minutes', 'Exactly on time'], 'a': 1},
        {'q': 'What does the speaker say about asking questions?', 'opts': ['Avoid asking questions', 'Only ask about salary', 'It shows genuine interest', 'It is not necessary'], 'a': 2},
        {'q': 'How does the speaker describe an interview?', 'opts': ['A one-way assessment', 'A two-way conversation', 'A written test', 'A group activity'], 'a': 1},
      ],
    },
    {
      'title': 'Healthy Habits for Better Sleep',
      'accent': 'American',
      'accentCode': 'en-US',
      'level': 'A2',
      'topic': 'Health',
      'text': 'Hello everyone, and welcome back to our wellness podcast. Today we are talking about sleep, and why it is so important for your health. Adults need between seven and nine hours of sleep every night. But many people get far less than this. Poor sleep is linked to a higher risk of heart disease, diabetes, and mental health problems. So what can you do to sleep better? First, try to go to bed and wake up at the same time every day, even on weekends. Second, avoid screens for at least one hour before bed. The blue light from phones and computers affects your brain and makes it harder to fall asleep. Third, keep your bedroom cool and dark. These simple changes can make a huge difference.',
      'questions': [
        {'q': 'How many hours of sleep do adults need each night?', 'opts': ['5-6 hours', '6-7 hours', '7-9 hours', '9-10 hours'], 'a': 2},
        {'q': 'What health problems are linked to poor sleep?', 'opts': ['Only mental health problems', 'Only physical problems', 'Heart disease, diabetes and mental health problems', 'No serious problems'], 'a': 2},
        {'q': 'How long before bed should you avoid screens?', 'opts': ['15 minutes', '30 minutes', 'At least 1 hour', '2 hours'], 'a': 2},
        {'q': 'What kind of light from screens affects sleep?', 'opts': ['Red light', 'Green light', 'Yellow light', 'Blue light'], 'a': 3},
      ],
    },
    {
      'title': 'Life in New Zealand',
      'accent': 'New Zealand',
      'accentCode': 'en-NZ',
      'level': 'B1',
      'topic': 'Culture',
      'text': 'Kia ora and welcome! New Zealand is a small island nation in the South Pacific, known for its stunning landscapes and friendly people. The country has two main islands, the North Island and the South Island, with a total population of about five million people. Maori culture is an essential part of New Zealand identity. The haka, a traditional Maori dance, is performed at important ceremonies and by the famous All Blacks rugby team. New Zealand was the first country in the world to give women the right to vote, back in eighteen ninety three. The country is also famous for its outdoor lifestyle, including hiking, called tramping by locals, surfing, and bungee jumping, which was invented here.',
      'questions': [
        {'q': 'What is the population of New Zealand?', 'opts': ['About 2 million', 'About 5 million', 'About 10 million', 'About 20 million'], 'a': 1},
        {'q': 'What is a haka?', 'opts': ['A Maori food', 'A type of weather', 'A traditional Maori dance', 'A New Zealand sport'], 'a': 2},
        {'q': 'When did NZ give women the right to vote?', 'opts': ['1850', '1893', '1920', '1945'], 'a': 1},
        {'q': 'What do New Zealanders call hiking?', 'opts': ['Walking', 'Trekking', 'Tramping', 'Roaming'], 'a': 2},
      ],
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_filterAccent == 'All') return _lessons;
    return _lessons.where((l) => l['accent'] == _filterAccent).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadCompletedLessons();
  }

  void _loadCompletedLessons() {
    final raw = sl<StorageService>().getList('listening_done') ?? [];
    setState(() {
      _completedLessons = raw.cast<String>().toSet();
    });
  }

  Future<void> _markLessonDone() async {
    if (_active == null || _score <= 0) return;
    final title = _active!['title'] as String;
    if (_completedLessons.contains(title)) return;
    setState(() {
      _completedLessons.add(title);
    });
    final storage = sl<StorageService>();
    await storage.saveList('listening_done', _completedLessons.toList());
    final currentXp = storage.getInt('total_xp', defaultValue: 0);
    await storage.saveInt('total_xp', currentXp + 20);
  }

  void _startLesson(Map<String, dynamic> lesson) {
    TtsService.stop();
    setState(() {
      _active = lesson;
      _isPlaying = false;
      _showTranscript = false;
      _questionIndex = 0;
      _selectedAnswer = -1;
      _answered = false;
      _score = 0;
      _done = false;
      _progress = 0.0;
      _elapsed = 0;
    });
  }

  void _togglePlay() {
    if (_isPlaying) {
      TtsService.stop();
      _progressTimer?.cancel();
      setState(() => _isPlaying = false);
    } else {
      final text = _active!['text'] as String;
      final accentCode = _active!['accentCode'] as String;
      TtsService.speak(text, lang: accentCode, rate: 0.82);
      setState(() { _isPlaying = true; _progress = 0.0; _elapsed = 0; });

      final wordCount = text.split(' ').length;
      final estimatedSecs = (wordCount / 2.2).round();

      _progressTimer?.cancel();
      _progressTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() {
          _elapsed++;
          _progress = (_elapsed / estimatedSecs).clamp(0.0, 1.0);
          if (_elapsed >= estimatedSecs) {
            _isPlaying = false;
            _progress = 1.0;
            t.cancel();
          }
        });
      });
    }
  }

  void _checkAnswer() {
    final qs = (_active!['questions'] as List).cast<Map<String, dynamic>>();
    final correct = qs[_questionIndex]['a'] as int;
    setState(() {
      _answered = true;
      if (_selectedAnswer == correct) _score++;
    });
  }

  void _nextQuestion() {
    final qs = (_active!['questions'] as List).cast<Map<String, dynamic>>();
    if (_questionIndex < qs.length - 1) {
      setState(() { _questionIndex++; _selectedAnswer = -1; _answered = false; });
    } else {
      setState(() => _done = true);
      _markLessonDone();
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    TtsService.stop();
    super.dispose();
  }

  String _formatTime(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  String? _continueTitle() {
    for (final lesson in _lessons) {
      if (!_completedLessons.contains(lesson['title'] as String)) {
        return lesson['title'] as String;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_active != null) return _buildPlayer();
    return _buildList();
  }

  Widget _buildList() {
    final filtered = _filtered;
    final continueTitle = _continueTitle();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Listening Practice', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _accents.map((a) {
                final sel = _filterAccent == a;
                return GestureDetector(
                  onTap: () => setState(() => _filterAccent = a),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: sel ? null : Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(a, style: TextStyle(color: sel ? Colors.white : Colors.black87, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(children: [
            Text('${filtered.length} lessons', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const Spacer(),
            const Icon(Icons.volume_up, size: 13, color: Colors.grey),
            const SizedBox(width: 4),
            const Text('Audio powered by your browser', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final lesson = filtered[i];
              final title = lesson['title'] as String;
              final isCompleted = _completedLessons.contains(title);
              final isContinue = continueTitle == title;
              return _LessonCard(
                lesson: lesson,
                onTap: () => _startLesson(lesson),
                isCompleted: isCompleted,
                isContinue: isContinue,
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildPlayer() {
    if (_done) return _buildResults();
    final lesson = _active!;
    final qs = (lesson['questions'] as List).cast<Map<String, dynamic>>();
    final q = qs[_questionIndex];
    final opts = (q['opts'] as List).cast<String>();
    final correctIdx = q['a'] as int;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(lesson['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 15)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () { TtsService.stop(); setState(() => _active = null); }),
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF283593), Color(0xFF5C6BC0)]),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _AccentBadge(lesson['accent'] as String),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                  child: Text(lesson['level'] as String, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                const Spacer(),
                Text(lesson['topic'] as String, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ]),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(_isPlaying ? _formatTime(_elapsed) : '0:00', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                Text(_isPlaying ? 'Playing...' : 'Ready', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ]),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(
                  icon: const Icon(Icons.replay_10, color: Colors.white, size: 28),
                  onPressed: () { TtsService.stop(); _progressTimer?.cancel(); setState(() { _isPlaying = false; _progress = 0.0; _elapsed = 0; }); },
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    width: 60, height: 60,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: const Color(0xFF283593), size: 34),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.forward_10, color: Colors.white, size: 28),
                  onPressed: () {},
                ),
              ]),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => setState(() => _showTranscript = !_showTranscript),
                icon: Icon(_showTranscript ? Icons.visibility_off : Icons.article_outlined, color: Colors.white70, size: 18),
                label: Text(_showTranscript ? 'Hide Transcript' : 'Show Transcript', style: const TextStyle(color: Colors.white70)),
              ),
              if (_showTranscript) Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                child: Text(lesson['text'] as String, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.7)),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Press Play to hear the audio, then answer the questions below.', style: TextStyle(color: Colors.blue[800], fontSize: 13))),
                ]),
              ),
              const SizedBox(height: 20),
              Row(children: [
                const Text('Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                const Spacer(),
                Text('${_questionIndex + 1} / ${qs.length}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 4),
              Row(children: List.generate(qs.length, (i) => Container(
                margin: const EdgeInsets.only(right: 4),
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _questionIndex ? Colors.green : (i == _questionIndex ? AppColors.primary : Colors.grey[300]),
                ),
              ))),
              const SizedBox(height: 16),
              Text(q['q'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.4)),
              const SizedBox(height: 14),
              ...opts.asMap().entries.map((e) {
                Color bg = Colors.white;
                Color border = Colors.grey[300]!;
                Color text = Colors.black87;
                IconData? icon;
                if (_answered) {
                  if (e.key == correctIdx) { bg = Colors.green[50]!; border = Colors.green; text = Colors.green[900]!; icon = Icons.check_circle; }
                  else if (e.key == _selectedAnswer) { bg = Colors.red[50]!; border = Colors.red; text = Colors.red[900]!; icon = Icons.cancel; }
                } else if (e.key == _selectedAnswer) {
                  bg = AppColors.primary.withOpacity(0.07); border = AppColors.primary; text = AppColors.primary;
                }
                return GestureDetector(
                  onTap: _answered ? null : () => setState(() => _selectedAnswer = e.key),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: bg, border: Border.all(color: border, width: 1.5), borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: border.withOpacity(0.15), border: Border.all(color: border)),
                        child: Center(child: Text(String.fromCharCode(65 + e.key), style: TextStyle(fontWeight: FontWeight.bold, color: border == Colors.grey[300] ? Colors.grey : border, fontSize: 13))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(e.value, style: TextStyle(fontSize: 15, color: text))),
                      if (icon != null) Icon(icon, color: border, size: 20),
                    ]),
                  ),
                );
              }),
              if (_answered) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedAnswer == correctIdx ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _selectedAnswer == correctIdx ? Colors.green[200]! : Colors.orange[200]!),
                  ),
                  child: Row(children: [
                    Icon(_selectedAnswer == correctIdx ? Icons.check_circle_outline : Icons.info_outline,
                        color: _selectedAnswer == correctIdx ? Colors.green[700] : Colors.orange[700], size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      _selectedAnswer == correctIdx ? 'Correct! Well done.' : 'The correct answer is: ${opts[correctIdx]}',
                      style: TextStyle(color: _selectedAnswer == correctIdx ? Colors.green[900] : Colors.orange[900], fontWeight: FontWeight.w500),
                    )),
                  ]),
                ),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(_questionIndex < qs.length - 1 ? 'Next Question' : 'See Results'),
                )),
              ] else if (_selectedAnswer >= 0) ...[
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: _checkAnswer,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Check Answer'),
                )),
              ],
              const SizedBox(height: 32),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildResults() {
    final lesson = _active!;
    final total = (lesson['questions'] as List).length;
    final pct = (_score / total * 100).round();
    final Color c = pct >= 75 ? Colors.green : (pct >= 50 ? Colors.orange : Colors.red);
    final String msg = pct >= 75 ? 'Excellent listening comprehension!' : (pct >= 50 ? 'Good effort! Listen again to improve.' : 'Listen to the audio again carefully.');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Results', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 16),
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.withOpacity(0.1), border: Border.all(color: c, width: 4)),
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('$pct%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: c)),
              Text('$_score / $total', style: TextStyle(color: c, fontSize: 13)),
            ])),
          ),
          const SizedBox(height: 16),
          Text(lesson['title'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(msg, style: TextStyle(color: c, fontSize: 15, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          if (_completedLessons.contains(lesson['title'] as String)) ...[
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 18),
              const SizedBox(width: 6),
              const Text('Lesson completed! +20 XP earned', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
            ]),
          ],
          const SizedBox(height: 28),
          _resultRow('Accent', lesson['accent'] as String, Icons.record_voice_over),
          _resultRow('Level', lesson['level'] as String, Icons.bar_chart),
          _resultRow('Topic', lesson['topic'] as String, Icons.category_outlined),
          _resultRow('Score', '$_score correct out of $total', Icons.check_circle_outline),
          const SizedBox(height: 28),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            icon: const Icon(Icons.replay),
            label: const Text('Listen Again'),
            onPressed: () => _startLesson(lesson),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            icon: const Icon(Icons.library_music),
            label: const Text('Try Another Lesson'),
            onPressed: () => setState(() { _active = null; _done = false; }),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )),
        ]),
      ),
    );
  }

  Widget _resultRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
      ]),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Map<String, dynamic> lesson;
  final VoidCallback onTap;
  final bool isCompleted;
  final bool isContinue;

  const _LessonCard({
    required this.lesson,
    required this.onTap,
    this.isCompleted = false,
    this.isContinue = false,
  });

  @override
  Widget build(BuildContext context) {
    final qs = (lesson['questions'] as List).length;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isContinue ? Border.all(color: AppColors.primary, width: 2) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
        ),
        child: Row(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green.withOpacity(0.1)
                  : const Color(0xFF283593).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isCompleted ? Icons.headphones : Icons.headphones,
              color: isCompleted ? Colors.green : const Color(0xFF283593),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(
                  lesson['title'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isCompleted ? Colors.grey.shade600 : Colors.black87,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              _AccentBadge(lesson['accent'] as String),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                child: Text(lesson['level'] as String, style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ),
              if (isContinue) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text('Continue', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ]),
            const SizedBox(height: 4),
            Text('$qs comprehension questions', style: const TextStyle(fontSize: 12, color: AppColors.primary)),
          ])),
          if (isCompleted)
            const Icon(Icons.check_circle, color: Colors.green, size: 28)
          else
            const Icon(Icons.play_circle_filled, color: AppColors.primary, size: 36),
        ]),
      ),
    );
  }
}

class _AccentBadge extends StatelessWidget {
  final String accent;
  const _AccentBadge(this.accent);

  Color get _color {
    switch (accent) {
      case 'British': return Colors.indigo;
      case 'American': return Colors.blue;
      case 'Australian': return Colors.green;
      case 'Canadian': return Colors.red;
      default: return Colors.grey;
    }
  }

  String get _code {
    switch (accent) {
      case 'British': return 'GB';
      case 'American': return 'US';
      case 'Australian': return 'AU';
      case 'Canadian': return 'CA';
      default: return accent.substring(0, 2).toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: _color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
    child: Text('$accent ($_code)', style: TextStyle(fontSize: 11, color: _color, fontWeight: FontWeight.bold)),
  );
}
