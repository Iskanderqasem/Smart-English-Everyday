import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/tts_service.dart';

class ReadingPage extends StatefulWidget {
  const ReadingPage({super.key});
  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  String _filterLevel = 'All';
  Map<String, dynamic>? _activePassage;
  int _questionIndex = 0;
  int _selected = -1;
  bool _answered = false;
  int _score = 0;
  bool _done = false;
  bool _speaking = false;

  final _levels = ['All', 'A1', 'A2', 'B1', 'B2', 'C1'];

  final _passages = [
    {
      'title': 'My Morning Routine',
      'level': 'A1',
      'topic': 'Daily Life',
      'readTime': '2 min',
      'text': 'Every morning, I wake up at seven o\'clock. First, I brush my teeth and wash my face. Then I eat breakfast. I usually have bread, eggs, and orange juice. After breakfast, I get dressed and go to school. I walk to school because it is close to my house. Classes start at eight thirty. My favourite subject is English. I come home at three o\'clock and do my homework.',
      'questions': [
        {'q': 'What time does the person wake up?', 'opts': ['Six o\'clock', 'Seven o\'clock', 'Eight o\'clock', 'Nine o\'clock'], 'a': 1},
        {'q': 'How does the person get to school?', 'opts': ['By bus', 'By car', 'By bicycle', 'On foot'], 'a': 3},
        {'q': 'What is the person\'s favourite subject?', 'opts': ['Maths', 'Science', 'English', 'History'], 'a': 2},
        {'q': 'What time does the person come home?', 'opts': ['Two o\'clock', 'Three o\'clock', 'Four o\'clock', 'Five o\'clock'], 'a': 1},
      ],
    },
    {
      'title': 'My Family',
      'level': 'A1',
      'topic': 'Family',
      'readTime': '2 min',
      'text': 'I have a small family. There are four people in my family: my mother, my father, my sister, and me. My mother is a teacher. She works at a primary school. My father is a doctor. He works at a hospital. My sister is ten years old. She likes drawing and painting. We live in a flat in the city. On weekends, we go to the park together. We are a happy family.',
      'questions': [
        {'q': 'How many people are in the family?', 'opts': ['Two', 'Three', 'Four', 'Five'], 'a': 2},
        {'q': 'What does the mother do?', 'opts': ['She is a doctor', 'She is a teacher', 'She is a nurse', 'She is an engineer'], 'a': 1},
        {'q': 'What does the sister enjoy doing?', 'opts': ['Reading books', 'Playing sports', 'Drawing and painting', 'Cooking'], 'a': 2},
        {'q': 'Where do they go on weekends?', 'opts': ['To the cinema', 'To the park', 'To the beach', 'To the library'], 'a': 1},
      ],
    },
    {
      'title': 'A Trip to London',
      'level': 'A2',
      'topic': 'Travel',
      'readTime': '3 min',
      'text': 'Last summer, I visited London for the first time. I stayed in a small hotel near the city centre. On my first day, I went to Buckingham Palace and saw the Changing of the Guard ceremony. It was very exciting! The next day, I visited the British Museum. There were thousands of historical objects from all over the world. I also took a boat trip on the River Thames. The boat ride was a great way to see the city from the water. London is a very expensive city, but there are many free attractions.',
      'questions': [
        {'q': 'When did the writer visit London?', 'opts': ['Last winter', 'Last spring', 'Last summer', 'Last autumn'], 'a': 2},
        {'q': 'What did the writer see at Buckingham Palace?', 'opts': ['The Queen', 'The Changing of the Guard', 'A concert', 'An art exhibition'], 'a': 1},
        {'q': 'What can you find at the British Museum?', 'opts': ['Modern art', 'Historical objects from the world', 'Technology exhibits', 'Natural history'], 'a': 1},
        {'q': 'What does the writer say about London\'s prices?', 'opts': ['It is very cheap', 'It is affordable', 'It is very expensive', 'It is free to visit'], 'a': 2},
      ],
    },
    {
      'title': 'Healthy Eating Habits',
      'level': 'A2',
      'topic': 'Health',
      'readTime': '3 min',
      'text': 'Eating well is important for good health. Doctors recommend eating five portions of fruit and vegetables every day. You should also drink at least eight glasses of water. It is a good idea to eat less sugar and less fast food. Breakfast is the most important meal of the day because it gives you energy for school or work. Skipping breakfast can make it difficult to concentrate. Cooking at home is usually healthier than eating in restaurants because you can control what goes into your food.',
      'questions': [
        {'q': 'How many portions of fruit and vegetables do doctors recommend daily?', 'opts': ['Three', 'Four', 'Five', 'Six'], 'a': 2},
        {'q': 'Why is breakfast considered the most important meal?', 'opts': ['It is the largest meal', 'It gives energy for the day', 'It is the cheapest meal', 'It is easiest to prepare'], 'a': 1},
        {'q': 'What happens if you skip breakfast?', 'opts': ['You lose weight', 'You save time', 'You feel more energetic', 'You find it hard to concentrate'], 'a': 3},
        {'q': 'Why is cooking at home healthier than eating in restaurants?', 'opts': ['It is faster', 'It is cheaper', 'You control what goes into your food', 'The food tastes better'], 'a': 2},
      ],
    },
    {
      'title': 'The Power of Habit',
      'level': 'B1',
      'topic': 'Science',
      'readTime': '4 min',
      'text': 'Habits are powerful forces in our daily lives. Scientists estimate that nearly 40 percent of our daily actions are habitual — performed automatically without much conscious thought. The brain develops habits as a way to conserve mental energy. Once a behaviour becomes habitual, it is stored in a part of the brain called the basal ganglia, which operates on autopilot. Breaking a bad habit requires conscious effort and replacement. Research by Dr. Phillippa Lally at University College London found that it takes an average of 66 days — not 21 as commonly believed — to form a new habit. Understanding how habits work gives us the power to reshape our behaviour.',
      'questions': [
        {'q': 'What percentage of our daily actions are habitual?', 'opts': ['About 20%', 'About 30%', 'About 40%', 'About 50%'], 'a': 2},
        {'q': 'Why does the brain develop habits?', 'opts': ['To make life more exciting', 'To conserve mental energy', 'To improve physical health', 'To enhance creativity'], 'a': 1},
        {'q': 'According to Dr. Lally\'s research, how many days does it take to form a new habit?', 'opts': ['21 days', '30 days', '66 days', '100 days'], 'a': 2},
        {'q': 'Where in the brain are habits stored?', 'opts': ['The frontal lobe', 'The cerebellum', 'The basal ganglia', 'The hippocampus'], 'a': 2},
      ],
    },
    {
      'title': 'Social Media and Young People',
      'level': 'B1',
      'topic': 'Technology',
      'readTime': '4 min',
      'text': 'Social media has become an integral part of young people\'s lives. Platforms such as Instagram, TikTok, and Snapchat are used by millions of teenagers every day. While social media offers benefits such as staying connected with friends and accessing information, it also presents several challenges. Research suggests that excessive use of social media is linked to increased anxiety and lower self-esteem, particularly among teenage girls. Cyberbullying is another significant concern. Many schools are now introducing digital literacy programmes to help students use social media responsibly. Experts recommend limiting screen time to two hours per day for teenagers.',
      'questions': [
        {'q': 'Which group is most affected by lower self-esteem due to social media?', 'opts': ['Teenage boys', 'Teenage girls', 'Young adults', 'Children under ten'], 'a': 1},
        {'q': 'What do schools do to help students use social media better?', 'opts': ['Ban social media', 'Introduce digital literacy programmes', 'Limit internet access', 'Teach coding'], 'a': 1},
        {'q': 'How many hours of screen time per day do experts recommend for teenagers?', 'opts': ['One hour', 'Two hours', 'Three hours', 'Four hours'], 'a': 1},
        {'q': 'What is cyberbullying described as in the text?', 'opts': ['A minor problem', 'A significant concern', 'A solved issue', 'An overrated topic'], 'a': 1},
      ],
    },
    {
      'title': 'Climate Change: Causes and Effects',
      'level': 'B2',
      'topic': 'Environment',
      'readTime': '5 min',
      'text': 'Climate change refers to long-term shifts in global temperatures and weather patterns. While some variation is natural, the scientific consensus is overwhelming: human activities have been the dominant driver of climate change since the Industrial Revolution. The primary cause is the burning of fossil fuels — coal, oil, and natural gas — which releases carbon dioxide and other greenhouse gases into the atmosphere. These gases trap heat, causing global temperatures to rise. The consequences are far-reaching: rising sea levels threaten coastal communities, extreme weather events are becoming more frequent, and biodiversity is under unprecedented pressure. The Paris Agreement of 2015 committed nations to limiting global warming to 1.5°C above pre-industrial levels, yet current pledges remain insufficient to achieve this target.',
      'questions': [
        {'q': 'What does the scientific consensus say about climate change?', 'opts': ['It is entirely natural', 'Human activities are the dominant driver', 'It is not a real concern', 'Only developing countries cause it'], 'a': 1},
        {'q': 'What do greenhouse gases do when released into the atmosphere?', 'opts': ['Cool the planet', 'Trap heat', 'Create rainfall', 'Protect from UV rays'], 'a': 1},
        {'q': 'What temperature limit did the Paris Agreement set?', 'opts': ['1°C', '1.5°C', '2°C', '2.5°C'], 'a': 1},
        {'q': 'Which of the following is NOT mentioned as a consequence of climate change?', 'opts': ['Rising sea levels', 'More frequent extreme weather', 'Improved biodiversity', 'Pressure on coastal communities'], 'a': 2},
      ],
    },
    {
      'title': 'Artificial Intelligence in Modern Life',
      'level': 'B2',
      'topic': 'Technology',
      'readTime': '5 min',
      'text': 'Artificial intelligence (AI) is no longer the preserve of science fiction. It is embedded in everyday life — from the algorithms that recommend what we watch on streaming platforms to the chatbots that handle customer service queries. AI systems learn by processing vast amounts of data, identifying patterns that humans might miss. In healthcare, AI can analyse medical images with accuracy that rivals experienced doctors. In finance, machine learning models detect fraudulent transactions in milliseconds. However, AI also raises profound ethical questions. Who is responsible when an AI system makes an error? How do we prevent algorithmic bias from perpetuating social inequalities? As AI capabilities accelerate, society must engage with these questions thoughtfully and urgently.',
      'questions': [
        {'q': 'How do AI systems learn?', 'opts': ['Through human instruction only', 'By processing vast amounts of data', 'Through trial and error games', 'By reading textbooks'], 'a': 1},
        {'q': 'What can AI do in healthcare according to the text?', 'opts': ['Perform surgery autonomously', 'Replace all doctors', 'Analyse medical images accurately', 'Prescribe medication'], 'a': 2},
        {'q': 'What is algorithmic bias a risk of causing?', 'opts': ['Economic growth', 'Perpetuating social inequalities', 'Improved accuracy', 'Faster computing'], 'a': 1},
        {'q': 'What is the tone of the text towards AI?', 'opts': ['Entirely positive', 'Entirely negative', 'Balanced — showing benefits and concerns', 'Indifferent'], 'a': 2},
      ],
    },
    {
      'title': 'The Philosophy of Language',
      'level': 'C1',
      'topic': 'Philosophy',
      'readTime': '6 min',
      'text': 'Language is not merely a tool for communication — it shapes the way we perceive and conceptualise the world. The Sapir-Whorf hypothesis, also known as linguistic relativity, posits that the language we speak influences our cognitive processes and world view. Proponents point to studies showing that speakers of languages with more precise colour terminology can distinguish between hues more readily than speakers whose languages conflate those colours. Critics, however, argue that the evidence for strong linguistic determinism — the idea that language rigidly determines thought — is inconclusive. A more nuanced position acknowledges that language and thought exist in a dynamic, bidirectional relationship: language shapes thought while thought continually reshapes language. The emergence of new vocabulary around concepts such as climate anxiety or the attention economy illustrates how language evolves to accommodate shifting human experiences.',
      'questions': [
        {'q': 'What does the Sapir-Whorf hypothesis propose?', 'opts': ['Language has no effect on thought', 'Language shapes our perception of the world', 'Thought determines the structure of language', 'All languages are fundamentally the same'], 'a': 1},
        {'q': 'What evidence do proponents of linguistic relativity use?', 'opts': ['Grammar structure studies', 'Mathematical reasoning tests', 'Colour terminology and perception studies', 'Cross-cultural emotion studies'], 'a': 2},
        {'q': 'What does the text say about strong linguistic determinism?', 'opts': ['It is well-proven', 'The evidence is conclusive', 'The evidence is inconclusive', 'It has been completely disproven'], 'a': 2},
        {'q': 'What does the author\'s "more nuanced position" suggest?', 'opts': ['Language and thought have no relationship', 'Language fully controls thought', 'Language and thought influence each other bidirectionally', 'Thought is independent of language'], 'a': 2},
      ],
    },
    {
      'title': 'Economic Inequality in the 21st Century',
      'level': 'C1',
      'topic': 'Economics',
      'readTime': '6 min',
      'text': 'Economic inequality — the uneven distribution of income and wealth across a population — has intensified markedly in recent decades. According to Oxfam, the world\'s eight richest individuals hold as much wealth as the bottom half of the global population combined. Thomas Piketty\'s influential work "Capital in the Twenty-First Century" argues that when the rate of return on capital exceeds economic growth, wealth naturally concentrates among those who already hold it, creating a self-perpetuating cycle of inequality. Critics of redistributive policies contend that taxation stifles investment and innovation. Proponents argue that extreme inequality undermines social cohesion, reduces intergenerational mobility, and corrodes democratic institutions. The debate ultimately centres on a fundamental tension between efficiency and equity — a tension that defines much of contemporary political discourse.',
      'questions': [
        {'q': 'According to Oxfam, how many individuals hold as much wealth as the bottom half of the global population?', 'opts': ['Four', 'Six', 'Eight', 'Ten'], 'a': 2},
        {'q': 'What is Piketty\'s main argument about wealth concentration?', 'opts': ['Inequality naturally decreases over time', 'When return on capital exceeds growth, wealth concentrates', 'Taxation always solves inequality', 'Economic growth eliminates inequality'], 'a': 1},
        {'q': 'What do critics of redistributive policies argue?', 'opts': ['Taxation improves innovation', 'Redistribution is too slow', 'Taxation stifles investment and innovation', 'Inequality is beneficial'], 'a': 2},
        {'q': 'What fundamental tension does the text identify in the debate about inequality?', 'opts': ['Freedom vs security', 'Efficiency vs equity', 'Growth vs stability', 'Capital vs labour'], 'a': 1},
      ],
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_filterLevel == 'All') return _passages;
    return _passages.where((p) => p['level'] == _filterLevel).toList();
  }

  void _startPassage(Map<String, dynamic> p) {
    setState(() {
      _activePassage = p;
      _questionIndex = 0;
      _selected = -1;
      _answered = false;
      _score = 0;
      _done = false;
    });
  }

  void _checkAnswer() {
    setState(() => _answered = true);
    if (_selected == (_activePassage!['questions'] as List)[_questionIndex]['a']) {
      _score++;
    }
  }

  void _nextQuestion() {
    final qs = (_activePassage!['questions'] as List);
    if (_questionIndex < qs.length - 1) {
      setState(() { _questionIndex++; _selected = -1; _answered = false; });
    } else {
      setState(() => _done = true);
    }
  }

  void _speak(String text) {
    setState(() => _speaking = true);
    TtsService.speak(text, lang: 'en-US', rate: 0.8, onEnd: () {
      if (mounted) setState(() => _speaking = false);
    });
  }

  void _stopSpeaking() {
    TtsService.stop();
    setState(() => _speaking = false);
  }

  @override
  void dispose() {
    TtsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_activePassage != null) return _buildPassageView();
    return _buildList();
  }

  Widget _buildList() {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Reading', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _levels.map((l) {
                  final selected = _filterLevel == l;
                  return GestureDetector(
                    onTap: () => setState(() => _filterLevel = l),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: selected ? null : Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(l, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(children: [
              Text('${filtered.length} passages', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const Spacer(),
              const Icon(Icons.volume_up, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              const Text('Tap any passage for audio', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (_, i) => _PassageCard(passage: filtered[i], onTap: () => _startPassage(filtered[i])),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassageView() {
    if (_done) return _buildResults();

    final p = _activePassage!;
    final qs = (p['questions'] as List).cast<Map<String, dynamic>>();
    final q = qs[_questionIndex];
    final opts = (q['opts'] as List).cast<String>();
    final correctIdx = q['a'] as int;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(p['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () { TtsService.stop(); setState(() => _activePassage = null); }),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _LevelBadge(p['level'] as String),
            const SizedBox(width: 8),
            _TopicBadge(p['topic'] as String),
            const Spacer(),
            Icon(Icons.timer_outlined, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(p['readTime'] as String, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ]),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Expanded(child: Text('Passage', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 12, letterSpacing: 1))),
                GestureDetector(
                  onTap: _speaking ? _stopSpeaking : () => _speak(p['text'] as String),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: _speaking ? Colors.red[50] : AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_speaking ? Icons.stop_rounded : Icons.volume_up, size: 16, color: _speaking ? Colors.red : AppColors.primary),
                      const SizedBox(width: 4),
                      Text(_speaking ? 'Stop' : 'Listen', style: TextStyle(fontSize: 12, color: _speaking ? Colors.red : AppColors.primary, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Text(p['text'] as String, style: const TextStyle(fontSize: 16, height: 1.9, color: Colors.black87)),
            ]),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Text('Question ${_questionIndex + 1} of ${qs.length}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
              const Spacer(),
              ...List.generate(qs.length, (i) => Container(
                margin: const EdgeInsets.only(left: 4),
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _questionIndex ? Colors.green : (i == _questionIndex ? AppColors.primary : Colors.grey[300]),
                ),
              )),
            ]),
          ),
          const SizedBox(height: 12),
          Text(q['q'] as String, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.4)),
          const SizedBox(height: 16),
          ...opts.asMap().entries.map((e) {
            Color bg = Colors.white;
            Color borderColor = Colors.grey[300]!;
            Color textColor = Colors.black87;
            IconData? trailingIcon;

            if (_answered) {
              if (e.key == correctIdx) {
                bg = Colors.green[50]!; borderColor = Colors.green; textColor = Colors.green[900]!; trailingIcon = Icons.check_circle;
              } else if (e.key == _selected) {
                bg = Colors.red[50]!; borderColor = Colors.red; textColor = Colors.red[900]!; trailingIcon = Icons.cancel;
              }
            } else if (e.key == _selected) {
              bg = AppColors.primary.withOpacity(0.07); borderColor = AppColors.primary; textColor = AppColors.primary;
            }

            return GestureDetector(
              onTap: _answered ? null : () => setState(() => _selected = e.key),
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
                  Expanded(child: Text(e.value, style: TextStyle(fontSize: 15, color: textColor))),
                  if (trailingIcon != null) Icon(trailingIcon, color: borderColor, size: 20),
                ]),
              ),
            );
          }),

          if (_answered) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _selected == correctIdx ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _selected == correctIdx ? Colors.green[200]! : Colors.orange[200]!),
              ),
              child: Row(children: [
                Icon(_selected == correctIdx ? Icons.lightbulb : Icons.info_outline,
                    color: _selected == correctIdx ? Colors.green[700] : Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  _selected == correctIdx
                      ? 'Correct! Well done.'
                      : 'The correct answer is: ${opts[correctIdx]}',
                  style: TextStyle(color: _selected == correctIdx ? Colors.green[900] : Colors.orange[900], fontWeight: FontWeight.w500),
                )),
              ]),
            ),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(_questionIndex < qs.length - 1 ? 'Next Question' : 'See Results'),
            )),
          ] else if (_selected >= 0) ...[
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
    );
  }

  Widget _buildResults() {
    final p = _activePassage!;
    final total = (p['questions'] as List).length;
    final pct = (_score / total * 100).round();
    final Color resultColor = pct >= 75 ? Colors.green : (pct >= 50 ? Colors.orange : Colors.red);
    final String message = pct >= 75 ? 'Excellent reading comprehension!' : (pct >= 50 ? 'Good effort! Keep practising.' : 'Keep reading — you\'ll improve!');

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
            decoration: BoxDecoration(shape: BoxShape.circle, color: resultColor.withOpacity(0.1), border: Border.all(color: resultColor, width: 4)),
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('$pct%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: resultColor)),
              Text('$_score / $total', style: TextStyle(color: resultColor, fontSize: 13)),
            ])),
          ),
          const SizedBox(height: 20),
          Text(p['title'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: resultColor, fontSize: 15, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          _resultRow('Passage Level', p['level'] as String, Icons.bar_chart),
          _resultRow('Topic', p['topic'] as String, Icons.category_outlined),
          _resultRow('Score', '$_score correct out of $total', Icons.check_circle_outline),
          _resultRow('Performance', pct >= 75 ? 'Strong' : (pct >= 50 ? 'Average' : 'Needs practice'), Icons.trending_up),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Try Another Passage'),
            onPressed: () => setState(() { _activePassage = null; _done = false; }),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            icon: const Icon(Icons.replay),
            label: const Text('Retry This Passage'),
            onPressed: () => _startPassage(p),
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

class _PassageCard extends StatelessWidget {
  final Map<String, dynamic> passage;
  final VoidCallback onTap;
  const _PassageCard({required this.passage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final qs = (passage['questions'] as List).length;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _LevelBadge(passage['level'] as String),
            const SizedBox(width: 8),
            _TopicBadge(passage['topic'] as String),
            const Spacer(),
            const Icon(Icons.volume_up, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(passage['readTime'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
          const SizedBox(height: 10),
          Text(passage['title'] as String, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 6),
          Text((passage['text'] as String).substring(0, 80) + '…', style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.quiz_outlined, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text('$qs comprehension questions', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
          ]),
        ]),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String level;
  const _LevelBadge(this.level);

  Color get _color {
    switch (level) {
      case 'A1': return Colors.green;
      case 'A2': return Colors.teal;
      case 'B1': return Colors.blue;
      case 'B2': return Colors.orange;
      case 'C1': return Colors.purple;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: _color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
    child: Text(level, style: TextStyle(color: _color, fontWeight: FontWeight.bold, fontSize: 12)),
  );
}

class _TopicBadge extends StatelessWidget {
  final String topic;
  const _TopicBadge(this.topic);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
    child: Text(topic, style: const TextStyle(color: Colors.black54, fontSize: 12)),
  );
}
