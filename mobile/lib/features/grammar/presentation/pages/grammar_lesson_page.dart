import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../main.dart';
import '../../../../shared/services/storage_service.dart';

class GrammarLessonPage extends StatefulWidget {
  final Map<String, dynamic> topic;
  const GrammarLessonPage({super.key, required this.topic});
  @override
  State<GrammarLessonPage> createState() => _GrammarLessonPageState();
}

class _GrammarLessonPageState extends State<GrammarLessonPage> {
  int _step = 0; // 0 = explanation, 1 = quiz
  int _quizIndex = 0;
  int? _selected;
  bool _answered = false;
  int _correct = 0;
  bool _done = false;

  List<_GQ> get _questions => _getQuestions(widget.topic['title'] as String);

  void _startQuiz() => setState(() { _step = 1; _quizIndex = 0; _selected = null; _answered = false; _correct = 0; });

  void _submitAnswer() {
    if (_selected == null) return;
    final isCorrect = _selected == _questions[_quizIndex].answer;
    setState(() {
      _answered = true;
      if (isCorrect) _correct++;
    });
  }

  Future<void> _next() async {
    if (_quizIndex < _questions.length - 1) {
      setState(() { _quizIndex++; _selected = null; _answered = false; });
    } else {
      // Save progress
      final key = 'grammar_done_${widget.topic['title']}';
      final lessons = widget.topic['lessons'] as int;
      final earned = (_correct / _questions.length * lessons).round().clamp(1, lessons);
      try {
        final storage = sl<StorageService>();
        final prev = storage.getInt(key) ?? 0;
        if (earned > prev) await storage.saveInt(key, earned);
      } catch (_) {}
      setState(() { _done = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.topic['title'] as String;
    final icon = widget.topic['icon'] as String;
    final level = widget.topic['level'] as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
            child: Text(level, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _done ? _buildDone() : (_step == 0 ? _buildExplanation(title, icon) : _buildQuiz()),
    );
  }

  // ── Explanation ────────────────────────────────────────────────────────────

  Widget _buildExplanation(String title, String icon) {
    final content = _getExplanation(title);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(22)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 38))),
        ),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ...content.map((block) => _buildBlock(block)),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startQuiz,
            icon: const Icon(Icons.quiz_outlined),
            label: const Text('Start Practice Questions', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }

  Widget _buildBlock(_Block b) {
    if (b.isHeader) {
      return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(b.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
      );
    }
    if (b.isExample) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('✦ ', style: TextStyle(color: AppColors.primary)),
          Expanded(child: Text(b.text, style: const TextStyle(fontSize: 14, height: 1.5, fontStyle: FontStyle.italic))),
        ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(b.text, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.6)),
    );
  }

  // ── Quiz ──────────────────────────────────────────────────────────────────

  Widget _buildQuiz() {
    final q = _questions[_quizIndex];
    final total = _questions.length;
    final progress = (_quizIndex + 1) / total;

    return Column(children: [
      // Progress bar
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        color: Colors.white,
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Question ${_quizIndex + 1} of $total', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text('$_correct correct', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation(AppColors.primary), borderRadius: BorderRadius.circular(4), minHeight: 6),
        ]),
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(q.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5, color: Colors.black87)),
            const SizedBox(height: 24),
            ...q.options.asMap().entries.map((e) {
              final idx = e.key;
              final opt = e.value;
              Color? bg, border;
              if (_answered) {
                if (idx == q.answer) { bg = Colors.green[50]; border = Colors.green; }
                else if (idx == _selected) { bg = Colors.red[50]; border = Colors.red; }
                else { bg = Colors.white; border = Colors.grey[300]; }
              } else {
                bg = _selected == idx ? AppColors.primary.withOpacity(0.08) : Colors.white;
                border = _selected == idx ? AppColors.primary : Colors.grey[300];
              }
              return GestureDetector(
                onTap: _answered ? null : () => setState(() => _selected = idx),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: bg, border: Border.all(color: border!, width: _selected == idx && !_answered ? 2 : 1), borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: _answered
                            ? (idx == q.answer ? Colors.green : (idx == _selected ? Colors.red : Colors.grey[200]))
                            : (_selected == idx ? AppColors.primary : Colors.grey[200]),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: _answered && idx == q.answer
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : (_answered && idx == _selected
                              ? const Icon(Icons.close, color: Colors.white, size: 16)
                              : Text(String.fromCharCode(65 + idx), style: TextStyle(fontWeight: FontWeight.bold, color: _selected == idx ? Colors.white : Colors.grey[600], fontSize: 13)))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(opt, style: TextStyle(fontSize: 15, color: _answered && idx == q.answer ? Colors.green[700] : Colors.black87))),
                  ]),
                ),
              );
            }),
            if (_answered && q.explanation != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue[200]!)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(q.explanation!, style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4))),
                ]),
              ),
          ]),
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4))]),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _answered ? _next : (_selected != null ? _submitAnswer : null),
            style: ElevatedButton.styleFrom(
              backgroundColor: _answered ? Colors.green : AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(_answered ? (_quizIndex < _questions.length - 1 ? 'Next Question →' : 'See Results') : 'Check Answer',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    ]);
  }

  // ── Done ─────────────────────────────────────────────────────────────────

  Widget _buildDone() {
    final total = _questions.length;
    final pct = _correct / total;
    final passed = pct >= 0.6;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            color: (passed ? Colors.green : Colors.orange).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(passed ? Icons.emoji_events : Icons.refresh, size: 52, color: passed ? Colors.green : Colors.orange),
        ),
        const SizedBox(height: 24),
        Text(passed ? 'Well done! 🎉' : 'Keep practising!', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('$_correct out of $total correct  (${(pct * 100).round()}%)',
            style: TextStyle(fontSize: 18, color: passed ? Colors.green[700] : Colors.orange[700], fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(passed ? 'Your progress has been saved!' : 'Try again to improve your score and unlock more progress.',
            style: const TextStyle(color: Colors.grey, height: 1.5), textAlign: TextAlign.center),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Grammar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (!passed) TextButton.icon(
          onPressed: _startQuiz,
          icon: const Icon(Icons.refresh),
          label: const Text('Try Again'),
        ),
      ]),
    );
  }
}

// ─── Data ────────────────────────────────────────────────────────────────────

class _Block {
  final String text;
  final bool isHeader;
  final bool isExample;
  const _Block(this.text, {this.isHeader = false, this.isExample = false});
}

class _GQ {
  final String question;
  final List<String> options;
  final int answer;
  final String? explanation;
  const _GQ(this.question, this.options, this.answer, [this.explanation]);
}

List<_Block> _getExplanation(String title) {
  switch (title) {
    case 'Simple Present':
      return [
        _Block('When do we use it?', isHeader: true),
        _Block('The Simple Present describes habits, facts, and repeated actions.'),
        _Block('Structure: Subject + base verb (+ s/es for he/she/it)', isHeader: true),
        _Block('"I play football every Saturday."', isExample: true),
        _Block('"She works in a hospital."', isExample: true),
        _Block('"Water boils at 100 degrees Celsius."', isExample: true),
        _Block('Key signal words', isHeader: true),
        _Block('always, usually, often, sometimes, rarely, never, every day/week/year'),
        _Block('⚠️ Remember: he/she/it → add -s or -es: "He goes", "She teaches", "It works"'),
        _Block('Negatives & Questions', isHeader: true),
        _Block('"I don\'t like coffee." / "Does she work here?" / "He doesn\'t know."'),
      ];
    case 'Simple Past':
      return [
        _Block('When do we use it?', isHeader: true),
        _Block('The Simple Past describes completed actions at a specific time in the past.'),
        _Block('Structure: Subject + past form of verb', isHeader: true),
        _Block('"I visited Paris last year."', isExample: true),
        _Block('"She didn\'t come to the party."', isExample: true),
        _Block('"Did you see that film?"', isExample: true),
        _Block('Regular verbs: add -ed', isHeader: true),
        _Block('walk → walked, work → worked, play → played, visit → visited'),
        _Block('Irregular verbs (must memorise)', isHeader: true),
        _Block('go → went, buy → bought, see → saw, have → had, come → came, eat → ate'),
        _Block('Signal words', isHeader: true),
        _Block('yesterday, last week/month/year, in 2020, ago, then, when'),
      ];
    case 'Present Continuous':
      return [
        _Block('When do we use it?', isHeader: true),
        _Block('Actions happening RIGHT NOW, temporary situations, and future arrangements.'),
        _Block('Structure: Subject + am/is/are + verb-ing', isHeader: true),
        _Block('"I am studying English right now."', isExample: true),
        _Block('"She is living in London this year." (temporary)', isExample: true),
        _Block('"We are meeting at 6pm tonight." (future plan)', isExample: true),
        _Block('⚠️ Stative verbs do NOT use continuous form', isHeader: true),
        _Block('know, want, like, love, hate, need, prefer, understand, believe, remember'),
        _Block('"I know the answer." (NOT "I am knowing")'),
        _Block('Signal words', isHeader: true),
        _Block('now, right now, at the moment, currently, today, this week'),
      ];
    case 'Present Perfect':
      return [
        _Block('Three main uses', isHeader: true),
        _Block('1. Life experience (at some unspecified time)'),
        _Block('"I have visited Japan." (at some point in my life)', isExample: true),
        _Block('2. Recent past with present effect'),
        _Block('"She has lost her keys." (she can\'t find them now)', isExample: true),
        _Block('3. Duration up to now (with for/since)'),
        _Block('"He has worked here since 2020." / "I have waited for an hour."', isExample: true),
        _Block('Structure: Subject + have/has + past participle', isHeader: true),
        _Block('Signal words', isHeader: true),
        _Block('ever, never, already, yet, just, for, since, recently, lately'),
        _Block('⚠️ Use simple past for specific times:', isHeader: true),
        _Block('"I visited Japan in 2019." (specific year → simple past)'),
      ];
    case 'Future with Will':
      return [
        _Block('Uses of "will"', isHeader: true),
        _Block('1. Predictions about the future'),
        _Block('"It will rain tomorrow." / "I think she will win."', isExample: true),
        _Block('2. Spontaneous decisions (made at the moment of speaking)'),
        _Block('"I\'ll have the chicken, please." / "I\'ll help you with that!"', isExample: true),
        _Block('3. Promises and offers'),
        _Block('"I will call you back." / "Will you help me?"', isExample: true),
        _Block('Structure: Subject + will + base verb', isHeader: true),
        _Block('Signal words', isHeader: true),
        _Block('tomorrow, next week/month/year, in the future, soon, probably, I think'),
        _Block('Negatives: won\'t (will not)', isHeader: true),
        _Block('"She won\'t be at the meeting." / "They won\'t accept the offer."'),
      ];
    case 'Zero Conditional':
      return [
        _Block('Used for general truths and scientific facts', isHeader: true),
        _Block('If + simple present → simple present'),
        _Block('"If you heat water to 100°C, it boils."', isExample: true),
        _Block('"If it rains, the ground gets wet."', isExample: true),
        _Block('"If you don\'t eat, you feel hungry."', isExample: true),
        _Block('Key point', isHeader: true),
        _Block('The result is ALWAYS true when the condition is met. You can replace "if" with "when" and the meaning stays the same.'),
        _Block('"When you heat water to 100°C, it boils."'),
      ];
    case 'First Conditional':
      return [
        _Block('Used for real / possible future situations', isHeader: true),
        _Block('If + simple present → will + base verb'),
        _Block('"If it rains tomorrow, I will stay home."', isExample: true),
        _Block('"If you study hard, you will pass the exam."', isExample: true),
        _Block('"She will miss the bus if she doesn\'t hurry."', isExample: true),
        _Block('The "if" clause can come first or second', isHeader: true),
        _Block('When "if" comes first → use a comma between clauses.'),
        _Block('When "if" comes second → no comma needed.'),
        _Block('Other modals instead of "will"', isHeader: true),
        _Block('"If you come early, you can get a good seat." (can)'),
        _Block('"If she calls, you should answer." (should)'),
      ];
    case 'Second Conditional':
      return [
        _Block('Used for imaginary / hypothetical present situations', isHeader: true),
        _Block('If + simple past → would + base verb'),
        _Block('"If I had a million dollars, I would travel the world."', isExample: true),
        _Block('"If she were taller, she would be a model."', isExample: true),
        _Block('"What would you do if you lost your job?"', isExample: true),
        _Block('Important: use "were" for all subjects', isHeader: true),
        _Block('"If I were you, I would apologise." (NOT "If I was you")'),
        _Block('"If she were here, she would know what to do."'),
        _Block('Difference from First Conditional', isHeader: true),
        _Block('1st: "If it rains, I will stay home." (real possibility)'),
        _Block('2nd: "If it snowed in summer, I would be amazed." (very unlikely/impossible)'),
      ];
    case 'Passive: Present':
      return [
        _Block('Why use passive voice?', isHeader: true),
        _Block('When the action is more important than who does it, or when the doer is unknown.'),
        _Block('Structure: Subject + am/is/are + past participle', isHeader: true),
        _Block('"English is spoken in many countries."', isExample: true),
        _Block('"The results are published every year."', isExample: true),
        _Block('"The office is cleaned every morning."', isExample: true),
        _Block('Active → Passive transformation', isHeader: true),
        _Block('Active: "Scientists study climate change."'),
        _Block('Passive: "Climate change is studied by scientists."'),
        _Block('⚠️ The "by + agent" is optional — omit when the doer is obvious or unknown.'),
      ];
    case 'Can & Could':
      return [
        _Block('"Can" — present ability & permission', isHeader: true),
        _Block('"She can speak three languages." (ability)', isExample: true),
        _Block('"Can I open the window?" (permission)', isExample: true),
        _Block('"The new software can process data faster." (possibility)', isExample: true),
        _Block('"Could" — past ability, polite requests, possibility', isHeader: true),
        _Block('"When I was young, I could run very fast." (past ability)', isExample: true),
        _Block('"Could you help me with this?" (polite request)', isExample: true),
        _Block('"It could rain later." (possibility)', isExample: true),
        _Block('Key rule', isHeader: true),
        _Block('Both can and could are ALWAYS followed by the base form of the verb (no "to").'),
        _Block('"She can swim." (NOT "She can to swim.")'),
      ];
    case 'A & An (Indefinite)':
      return [
        _Block('Rule: Use "a" before consonant SOUNDS, "an" before vowel SOUNDS', isHeader: true),
        _Block('"a book", "a car", "a university" (yu-sound)', isExample: true),
        _Block('"an apple", "an egg", "an hour" (silent h)', isExample: true),
        _Block('"an honest man" (silent h), "a European country" (yu-sound)', isExample: true),
        _Block('When to use a/an', isHeader: true),
        _Block('1. Introducing something for the first time: "I saw a dog."'),
        _Block('2. Jobs and roles: "She is a teacher." / "He is an engineer."'),
        _Block('3. One of many: "Can I borrow a pen?" (any pen)'),
        _Block('⚠️ Common mistakes', isHeader: true),
        _Block('"a uniform" → correct (u makes a "yu" sound)'),
        _Block('"an hour" → correct (h is silent, starts with "ow" sound)'),
      ];
    case 'Prepositions of Place':
      return [
        _Block('The three main prepositions of place', isHeader: true),
        _Block('"in" — inside a space/area: "in the room", "in London", "in the box"', isExample: true),
        _Block('"on" — on a surface: "on the table", "on the wall", "on the bus"', isExample: true),
        _Block('"at" — a specific point: "at the door", "at the station", "at school"', isExample: true),
        _Block('Other useful prepositions', isHeader: true),
        _Block('above / below, in front of / behind, next to / beside, between / among, under / over'),
        _Block('"The cat is under the table."', isExample: true),
        _Block('"The bank is next to the supermarket."', isExample: true),
        _Block('⚠️ Tricky cases', isHeader: true),
        _Block('"in the corner" (inside a room) but "at the corner" (of a street)'),
        _Block('"on the bus/train/plane" but "in the car/taxi"'),
      ];
    default:
      return [
        _Block('About ${title}', isHeader: true),
        _Block('This is an important grammar topic in English. Let\'s explore the key rules and how to use it correctly.'),
        _Block('Key principle', isHeader: true),
        _Block('English grammar follows specific patterns. Learning the rule + seeing examples is the fastest way to master it.'),
        _Block('Example sentences', isHeader: true),
        _Block('Complete the practice questions below to test your understanding.', isExample: true),
      ];
  }
}

List<_GQ> _getQuestions(String title) {
  switch (title) {
    case 'Simple Present':
      return [
        _GQ('She ___ to work by bus every day.', ['go', 'goes', 'going', 'is go'], 1, '"She" = he/she/it → add -s to the verb.'),
        _GQ('___ your brother speak English?', ['Do', 'Does', 'Is', 'Are'], 1, 'With he/she/it in questions, use "Does".'),
        _GQ('Water ___ at 100 degrees Celsius.', ['boil', 'boils', 'is boiling', 'boiled'], 1, 'Scientific facts use the Simple Present.'),
        _GQ('I ___ usually have lunch at home.', ['don\'t', 'doesn\'t', 'am not', 'isn\'t'], 0, '"I" uses "don\'t" for negatives.'),
        _GQ('He ___ at the hospital every morning.', ['work', 'works', 'working', 'is work'], 1, '"He" requires the -s form: works.'),
      ];
    case 'Simple Past':
      return [
        _GQ('She ___ to Paris last summer.', ['go', 'goes', 'went', 'has gone'], 2, '"go" is irregular: go → went.'),
        _GQ('I ___ see the film yesterday because I was busy.', ['don\'t', 'didn\'t', 'wasn\'t', 'haven\'t'], 1, 'Past tense negative: didn\'t + base verb.'),
        _GQ('"___ you enjoy the party?" "Yes, I did!"', ['Did', 'Do', 'Were', 'Have'], 0, 'Past tense questions start with "Did".'),
        _GQ('They ___ all the food at the party.', ['eat', 'eaten', 'eated', 'ate'], 3, '"eat" is irregular: eat → ate.'),
        _GQ('She ___ (not) know the answer.', ['don\'t', 'didn\'t', 'wasn\'t', 'isn\'t'], 1, 'Negative past simple: didn\'t + base verb.'),
      ];
    case 'Present Continuous':
      return [
        _GQ('Listen! The baby ___.', ['cries', 'is crying', 'cry', 'cried'], 1, '"Listen!" signals something happening right now → present continuous.'),
        _GQ('I ___ understand what you mean. (stative verb)', ['am not', 'don\'t', 'not', 'isn\'t'], 1, '"understand" is a stative verb — cannot use continuous form.'),
        _GQ('"___ you working from home today?" "Yes, just for this week."', ['Do', 'Are', 'Is', 'Have'], 1, 'Present continuous question: Are + subject + verb-ing.'),
        _GQ('She ___ (study) for her exam right now.', ['study', 'studies', 'is studying', 'studied'], 2, '"right now" → present continuous.'),
        _GQ('We ___ (meet) the clients tomorrow at 3pm.', ['meet', 'will meet', 'are meeting', 'met'], 2, 'Present continuous can express future arrangements.'),
      ];
    case 'Present Perfect':
      return [
        _GQ('She ___ never been to Australia.', ['has', 'have', 'had', 'is'], 0, '"She" uses "has" in present perfect.'),
        _GQ('___ you ever eaten sushi?', ['Did', 'Have', 'Has', 'Do'], 1, '"you" uses "have" in present perfect.'),
        _GQ('I have lived here ___ 2015.', ['for', 'since', 'from', 'during'], 1, '"since" + a starting point in time.'),
        _GQ('They have worked on the project ___ three months.', ['since', 'for', 'during', 'from'], 1, '"for" + a duration of time.'),
        _GQ('He ___ just finished his report.', ['is', 'has', 'had', 'have'], 1, '"He" = he/she/it → use "has".'),
      ];
    case 'Zero Conditional':
      return [
        _GQ('If you mix blue and yellow, you ___ green.', ['get', 'will get', 'would get', 'got'], 0, 'Zero conditional: If + present → present (scientific fact).'),
        _GQ('Plants die if they ___ enough water.', ['don\'t get', 'won\'t get', 'wouldn\'t get', 'didn\'t get'], 0, 'Both clauses use simple present in zero conditional.'),
        _GQ('"If you ___ ice, it melts." Which tense is correct?', ['heat', 'will heat', 'heated', 'would heat'], 0, 'Zero conditional: if + simple present.'),
        _GQ('In zero conditional, you can replace "if" with ___.', ['"unless"', '"when"', '"although"', '"because"'], 1, 'You can replace "if" with "when" in zero conditional without changing meaning.'),
      ];
    case 'First Conditional':
      return [
        _GQ('If it rains tomorrow, we ___ the match.', ['cancel', 'will cancel', 'cancelled', 'would cancel'], 1, 'First conditional: if + present → will + base verb.'),
        _GQ('She will miss the bus if she ___ now.', ['doesn\'t leave', 'won\'t leave', 'wouldn\'t leave', 'didn\'t leave'], 0, 'The "if" clause uses simple present, not will.'),
        _GQ('"If you ___ hard, you will succeed."', ['study', 'will study', 'studied', 'would study'], 0, 'After "if" in first conditional: use simple present.'),
        _GQ('If I see him, I ___ him your message.', ['give', 'will give', 'gave', 'would give'], 1, 'First conditional result clause: will + base verb.'),
      ];
    case 'Second Conditional':
      return [
        _GQ('If I ___ a car, I would drive to work.', ['have', 'had', 'will have', 'would have'], 1, 'Second conditional: if + past simple.'),
        _GQ('"If I ___ you, I would apologise." Which is correct?', ['am', 'was', 'were', 'be'], 2, 'Use "were" for all subjects in second conditional: "If I were you..."'),
        _GQ('She would travel more if she ___ more money.', ['has', 'had', 'would have', 'will have'], 1, 'Second conditional "if" clause: past simple.'),
        _GQ('"What ___ you do if you won the lottery?"', ['will', 'would', 'do', 'did'], 1, 'Second conditional question: would + subject + base verb.'),
      ];
    case 'Can & Could':
      return [
        _GQ('___ you help me carry these bags, please?', ['Can', 'Could', 'Both are correct', 'Neither'], 2, 'Both "can" and "could" work for polite requests. "Could" is slightly more formal.'),
        _GQ('When she was young, she ___ dance very well.', ['can', 'could', 'is able', 'was able to'], 1, '"Could" for past ability.'),
        _GQ('"She ___ speak Spanish when she was 5." Choose correctly.', ['can', 'could', 'cans', 'coulds'], 1, '"could" = past ability.'),
        _GQ('It ___ rain later — the sky looks dark.', ['can', 'could', 'both correct', 'neither'], 1, '"Could" expresses future possibility.'),
      ];
    case 'A & An (Indefinite)':
      return [
        _GQ('She is ___ engineer.', ['a', 'an', 'the', 'no article'], 1, '"engineer" starts with a vowel sound → "an".'),
        _GQ('He wants to be ___ university professor.', ['a', 'an', 'the', 'no article'], 0, '"university" starts with a "yu" consonant sound → "a".'),
        _GQ('I waited for ___ hour outside.', ['a', 'an', 'the', 'no article'], 1, '"hour" has a silent h → starts with vowel sound → "an".'),
        _GQ('It was ___ unique opportunity.', ['a', 'an', 'the', 'no article'], 0, '"unique" starts with a "yu" consonant sound → "a".'),
        _GQ('She is ___ honest person.', ['a', 'an', 'the', 'no article'], 1, '"honest" has a silent h → starts with vowel sound → "an".'),
      ];
    case 'Prepositions of Place':
      return [
        _GQ('The keys are ___ the table.', ['in', 'on', 'at', 'above'], 1, 'On a surface → "on".'),
        _GQ('She works ___ a hospital.', ['in', 'on', 'at', 'inside'], 0, 'Inside an enclosed space/building → "in".'),
        _GQ('I\'ll meet you ___ the station.', ['in', 'on', 'at', 'by'], 2, 'A specific point/location → "at".'),
        _GQ('The cat is sleeping ___ the bed.', ['at', 'on', 'in', 'above'], 1, '"on" = on top of a surface.'),
        _GQ('They live ___ a small village ___ the mountains.', ['at / in', 'in / in', 'on / at', 'in / on'], 1, '"in a village" (an area) / "in the mountains" (a region).'),
      ];
    default:
      return [
        _GQ('Which sentence is grammatically correct?', [
          'She go to school every day.',
          'She goes to school every day.',
          'She is go to school every day.',
          'She going to school every day.',
        ], 1, 'With she/he/it in simple present, add -s/-es to the verb.'),
        _GQ('Choose the correct option: "If I ___ rich, I would travel the world."', ['am', 'was', 'were', 'be'], 2, 'Second conditional: if + were (for all subjects).'),
        _GQ('The report ___ by the manager yesterday.', ['submitted', 'was submitted', 'has submitted', 'submits'], 1, 'Past passive: was + past participle.'),
        _GQ('"Have you ___ been to New York?"', ['ever', 'never', 'already', 'yet'], 0, '"ever" is used in questions with present perfect.'),
      ];
  }
}
