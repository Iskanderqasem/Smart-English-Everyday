import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../main.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../shared/widgets/custom_button.dart';

// ─── Data models ──────────────────────────────────────────────────────────────

class _Q {
  final String text;
  final List<String> options;
  final int answer;
  final String section; // grammar | vocabulary | structure
  final String level;   // A1 A2 B1 B2 C1 C2

  const _Q(this.text, this.options, this.answer, this.section, this.level);
}

class _Result {
  final DateTime date;
  final String cefrLevel;
  final int correct;
  final int total;
  final double grammarPct;
  final double vocabPct;
  final double structurePct;

  _Result({
    required this.date,
    required this.cefrLevel,
    required this.correct,
    required this.total,
    required this.grammarPct,
    required this.vocabPct,
    required this.structurePct,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'cefrLevel': cefrLevel,
    'correct': correct,
    'total': total,
    'grammarPct': grammarPct,
    'vocabPct': vocabPct,
    'structurePct': structurePct,
  };

  factory _Result.fromJson(Map<String, dynamic> j) => _Result(
    date: DateTime.parse(j['date'] as String),
    cefrLevel: j['cefrLevel'] as String,
    correct: j['correct'] as int,
    total: j['total'] as int,
    grammarPct: (j['grammarPct'] as num).toDouble(),
    vocabPct: (j['vocabPct'] as num).toDouble(),
    structurePct: (j['structurePct'] as num).toDouble(),
  );
}

// ─── Question Bank (75 questions) ────────────────────────────────────────────

const _kBank = <_Q>[
  // ── GRAMMAR ──────────────────────────────────────────────────────────────
  _Q('She ___ to school every day.', ['go','goes','going','has gone'], 1, 'grammar', 'A1'),
  _Q('There ___ a lot of students in the class.', ['is','are','was','be'], 1, 'grammar', 'A1'),
  _Q('___ you like a cup of tea?', ['Do','Would','Should','Are'], 1, 'grammar', 'A1'),
  _Q('They ___ watching TV when I arrived.', ['is','are','was','were'], 3, 'grammar', 'A2'),
  _Q('I have ___ this book before.', ['read','reading','reads','readed'], 0, 'grammar', 'A2'),
  _Q('She is ___ than her sister.', ['tall','taller','tallest','more tall'], 1, 'grammar', 'A2'),
  _Q('If it rains tomorrow, we ___ stay inside.', ['will','would','shall','should'], 0, 'grammar', 'B1'),
  _Q('By the time we arrived, the film ___.', ['already started','has already started','had already started','was starting'], 2, 'grammar', 'B1'),
  _Q('She asked me where ___ the day before.', ['I had gone','had I gone','I went','did I go'], 0, 'grammar', 'B1'),
  _Q('The report ___ by the manager before noon.', ['submitted','was submitted','has submitted','submits'], 1, 'grammar', 'B1'),
  _Q('Not only ___ late, but he also forgot his homework.', ['did he arrive','he arrived','arrived he','he did arrive'], 0, 'grammar', 'B2'),
  _Q('Had I known the answer, I ___ told you.', ['will have','would have','shall have','had'], 1, 'grammar', 'B2'),
  _Q('The data ___ collected over a period of six months.', ['were','was','are','is'], 0, 'grammar', 'B2'),
  _Q('It is essential that each student ___ the assignment on time.', ['submits','submit','submitted','is submitting'], 1, 'grammar', 'C1'),
  _Q('Rarely ___ such a compelling argument presented.', ['was','is','has','have'], 0, 'grammar', 'C1'),
  _Q('The findings suggest that further research ___ in this field.', ['is needed','are needed','needs','need'], 0, 'grammar', 'C1'),
  _Q('___ the project been completed, we would have received additional funding.', ['If','Had','Should','Were'], 1, 'grammar', 'C2'),
  _Q('The committee recommended that the policy ___ reconsidered immediately.', ['is','was','be','were'], 2, 'grammar', 'C2'),
  _Q('No sooner ___ than the audience burst into applause.', ['had she finished','she had finished','did she finish','she finished'], 0, 'grammar', 'C2'),
  _Q('She acted as if she ___ the owner of the place.', ['is','was','were','be'], 2, 'grammar', 'B2'),
  _Q('Neither the teacher nor the students ___ ready for the test.', ['was','were','is','are'], 1, 'grammar', 'B1'),
  _Q('I wish I ___ more time to study last week.', ['have','had','had had','would have'], 2, 'grammar', 'B2'),
  _Q('The new policy, ___ was introduced last year, has been very effective.', ['which','that','who','what'], 0, 'grammar', 'B2'),

  // ── VOCABULARY ──────────────────────────────────────────────────────────
  _Q('The scientist\'s work was considered ___ because it completely changed the field.', ['redundant','pivotal','ambiguous','trivial'], 1, 'vocabulary', 'B1'),
  _Q('The politician\'s speech was full of ___ — using many words but saying little of value.', ['verbosity','clarity','brevity','conciseness'], 0, 'vocabulary', 'B2'),
  _Q('The two countries reached a ___ agreement — one that both sides found acceptable.', ['unilateral','bilateral','multilateral','mutual'], 3, 'vocabulary', 'B1'),
  _Q('His argument was ___, meaning it could be interpreted in more than one way.', ['definitive','ambiguous','explicit','coherent'], 1, 'vocabulary', 'B2'),
  _Q('The company decided to ___ its losses by reducing the workforce.', ['mitigate','aggravate','accelerate','magnify'], 0, 'vocabulary', 'B2'),
  _Q('The new law was designed to ___ discrimination in the workplace.', ['perpetuate','exacerbate','eradicate','stimulate'], 2, 'vocabulary', 'C1'),
  _Q('Her ___ manner made everyone around her feel at ease.', ['austere','affable','brusque','aloof'], 1, 'vocabulary', 'C1'),
  _Q('The ___ of the new policy was its failure to address root causes.', ['advantage','shortcoming','success','implementation'], 1, 'vocabulary', 'B2'),
  _Q('Scientists are trying to ___ the effects of the treatment in different populations.', ['replicate','negate','distort','diminish'], 0, 'vocabulary', 'C1'),
  _Q('The results were ___ — surprising and difficult to explain.', ['predictable','anomalous','consistent','coherent'], 1, 'vocabulary', 'C1'),
  _Q('To ___ means to make something clearer by explaining it in more detail.', ['obscure','elucidate','conceal','distort'], 1, 'vocabulary', 'B2'),
  _Q('A ___ decision is one made using clear, logical reasoning.', ['impulsive','rational','arbitrary','hasty'], 1, 'vocabulary', 'B1'),
  _Q('The professor was known for her ___ research — covering many different fields.', ['narrow','specialized','interdisciplinary','focused'], 2, 'vocabulary', 'C1'),
  _Q('The new evidence ___ the existing theory — it supported it strongly.', ['refuted','corroborated','contradicted','undermined'], 1, 'vocabulary', 'C2'),
  _Q('Her ___ attitude toward her work helped her succeed despite many obstacles.', ['apathetic','tenacious','indifferent','lethargic'], 1, 'vocabulary', 'B2'),
  _Q('The government sought to ___ tensions by opening diplomatic channels.', ['escalate','defuse','intensify','provoke'], 1, 'vocabulary', 'B2'),
  _Q('The concept was so ___ that even experts struggled to fully grasp it.', ['elementary','mundane','abstruse','transparent'], 2, 'vocabulary', 'C2'),

  // ── STRUCTURE / SENTENCE COMPLETION ──────────────────────────────────────
  _Q('"Despite ___ for hours, they were unable to find a solution." — Choose the correct form.', ['to try','tried','having tried','being tried'], 2, 'structure', 'B2'),
  _Q('Choose the sentence that is grammatically correct:', ['Each of the students have to complete the test.','Neither of the answers are correct.','The majority of the class is ready.','All of the books was returned.'], 2, 'structure', 'B1'),
  _Q('Which sentence correctly uses the passive voice?', ['The manager approved by the board.','The board approved the manager.','The board had approved by the manager.','The manager was approved by the board.'], 3, 'structure', 'B1'),
  _Q('"___ the weather improves, the outdoor event will be cancelled." Which word fits?', ['Because','Although','Unless','Despite'], 2, 'structure', 'B1'),
  _Q('Select the most appropriate word: "The evidence suggests that climate change is ___ many ecosystems."', ['affecting','affecting on','affected by','effect on'], 0, 'structure', 'B2'),
  _Q('"Not until the last moment ___ the truth." Choose the correct form.', ['he realised','did he realise','he did realise','realised he'], 1, 'structure', 'C1'),
  _Q('Which sentence avoids a dangling modifier?', ['Walking down the street, the rain started.','Walking down the street, she noticed it was raining.','The rain started, walking down the street.','She noticed the rain, walking down the street it started.'], 1, 'structure', 'C1'),
  _Q('Select the correct reported speech: She said, "I am studying now."', ['She said she is studying now.','She said she was studying then.','She told she was studying now.','She said that she studies now.'], 1, 'structure', 'B2'),
  _Q('Which is the correct collocation?', ['make a mistake','do a mistake','have a mistake','get a mistake'], 0, 'structure', 'A2'),
  _Q('"The results were ___ different from what had been predicted." Which word best fills the gap?', ['markedly','marking','marked','marks'], 0, 'structure', 'C1'),
  _Q('Choose the sentence with the correct article usage:', ['She is best student in the class.','She is a best student in the class.','She is the best student in the class.','She is best the student in class.'], 2, 'structure', 'A2'),
  _Q('Which sentence correctly uses a relative clause?', ['The book which I borrowed it was excellent.','The book that I borrowed was excellent.','The book which I borrowed it, was excellent.','The book, I borrowed it, was excellent.'], 1, 'structure', 'B1'),
  _Q('"I would rather you ___ late." Choose the correct form.', ['not come','not to come','did not come','do not come'], 2, 'structure', 'C1'),
  _Q('Select the sentence with correct subject-verb agreement:', ['The number of applicants have increased.','A number of applicants has increased.','A number of applicants have increased.','The number of applicants has increased.'], 3, 'structure', 'B2'),
  _Q('"___ by many researchers, the hypothesis has now been widely accepted." Choose the best option.', ['Studied','Having been studied','Being studied','To be studied'], 1, 'structure', 'C2'),
];

// ─── Page ─────────────────────────────────────────────────────────────────────

class AssessmentPage extends StatefulWidget {
  const AssessmentPage({super.key});
  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // session state
  List<_Q> _questions = [];
  List<int?> _answers = [];
  int _current = 0;
  bool _submitted = false;
  bool _loading = false;
  _Result? _latestResult;

  // history
  List<_Result> _history = [];

  static const _historyKey = 'assessment_history_v2';
  static const _sessionCount = 20; // questions per session

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _loadHistory() {
    try {
      final raw = sl<StorageService>().getList(_historyKey);
      if (raw != null) {
        setState(() {
          _history = raw
              .map((e) => _Result.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
              ..sort((a, b) => b.date.compareTo(a.date));
        });
      }
    } catch (_) {}
  }

  Future<void> _saveResult(_Result r) async {
    try {
      final list = [r.toJson(), ..._history.take(9).map((e) => e.toJson())].toList();
      await sl<StorageService>().saveList(_historyKey, list);
    } catch (_) {}
  }

  void _startSession() {
    final rng = Random();
    // Pick 10 grammar, 5 vocabulary, 5 structure questions randomly
    final grammar = (_kBank.where((q) => q.section == 'grammar').toList()..shuffle(rng)).take(10).toList();
    final vocab = (_kBank.where((q) => q.section == 'vocabulary').toList()..shuffle(rng)).take(5).toList();
    final structure = (_kBank.where((q) => q.section == 'structure').toList()..shuffle(rng)).take(5).toList();
    final all = [...grammar, ...vocab, ...structure]..shuffle(rng);
    setState(() {
      _questions = all;
      _answers = List.filled(all.length, null);
      _current = 0;
      _submitted = false;
      _latestResult = null;
    });
  }

  void _selectAnswer(int idx) {
    if (_submitted) return;
    setState(() => _answers[_current] = idx);
  }

  void _next() {
    if (_current < _questions.length - 1) {
      setState(() => _current++);
    } else {
      _submit();
    }
  }

  void _prev() {
    if (_current > 0) setState(() => _current--);
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    // Score by section
    int grammarC = 0, grammarT = 0, vocabC = 0, vocabT = 0, structC = 0, structT = 0;
    for (var i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final correct = _answers[i] == q.answer;
      switch (q.section) {
        case 'grammar':   grammarT++; if (correct) grammarC++; break;
        case 'vocabulary': vocabT++;  if (correct) vocabC++;  break;
        case 'structure': structT++;  if (correct) structC++;  break;
      }
    }

    final totalCorrect = grammarC + vocabC + structC;
    final pct = totalCorrect / _questions.length;
    final cefr = _cefrFromPct(pct);

    final r = _Result(
      date: DateTime.now(),
      cefrLevel: cefr,
      correct: totalCorrect,
      total: _questions.length,
      grammarPct: grammarT > 0 ? grammarC / grammarT : 0,
      vocabPct: vocabT > 0 ? vocabC / vocabT : 0,
      structurePct: structT > 0 ? structC / structT : 0,
    );

    await _saveResult(r);
    setState(() {
      _loading = false;
      _submitted = true;
      _latestResult = r;
      _history = [r, ..._history.take(9)];
    });
  }

  static String _cefrFromPct(double pct) {
    if (pct >= 0.90) return 'C2';
    if (pct >= 0.75) return 'C1';
    if (pct >= 0.60) return 'B2';
    if (pct >= 0.45) return 'B1';
    if (pct >= 0.28) return 'A2';
    return 'A1';
  }

  static String _ieltsFromCefr(String c) {
    switch (c) {
      case 'C2': return '8.5 – 9.0';
      case 'C1': return '7.0 – 8.0';
      case 'B2': return '5.5 – 6.5';
      case 'B1': return '4.0 – 5.0';
      case 'A2': return '3.0 – 3.5';
      default:   return 'Below 3.0';
    }
  }

  static String _toeflFromCefr(String c) {
    switch (c) {
      case 'C2': return '110 – 120';
      case 'C1': return '87 – 109';
      case 'B2': return '53 – 86';
      case 'B1': return '30 – 52';
      case 'A2': return '18 – 29';
      default:   return 'Below 18';
    }
  }

  static Color _cefrColor(String c) {
    switch (c) {
      case 'C2': return const Color(0xFF6A0DAD);
      case 'C1': return const Color(0xFF1565C0);
      case 'B2': return Colors.teal;
      case 'B1': return Colors.green;
      case 'A2': return Colors.orange;
      default:   return Colors.red;
    }
  }

  static String _cefrLabel(String c) {
    switch (c) {
      case 'C2': return 'Mastery';
      case 'C1': return 'Advanced';
      case 'B2': return 'Upper Intermediate';
      case 'B1': return 'Intermediate';
      case 'A2': return 'Elementary';
      default:   return 'Beginner';
    }
  }

  static String _recommendation(String c) {
    switch (c) {
      case 'C2': return 'Outstanding! You are at a near-native level. Focus on nuance, academic writing, and idiomatic expression.';
      case 'C1': return 'Excellent! You handle complex topics with ease. Work on refining academic vocabulary and advanced grammar.';
      case 'B2': return 'Great progress! You can discuss most topics fluently. Focus on reading academic texts and expanding vocabulary.';
      case 'B1': return 'Good foundation! You can handle everyday English well. Focus on more complex grammar and reading comprehension.';
      case 'A2': return 'You\'re making progress! Focus on building grammar structures, expanding vocabulary, and listening practice.';
      default:   return 'Great start! Begin with basic grammar, everyday vocabulary, and simple conversation practice.';
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          if (_questions.isEmpty && !_submitted)
            Expanded(
              child: TabBarView(controller: _tabCtrl, children: [
                _buildWelcome(),
                _buildHistoryTab(),
              ]),
            )
          else if (_submitted && _latestResult != null)
            Expanded(child: _buildResults(_latestResult!))
          else
            Expanded(child: _buildQuestion()),
        ]),
      ),
    );
  }

  Widget _buildHeader() {
    if (_questions.isNotEmpty && !_submitted) {
      // Progress header during quiz
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
        ),
        child: Column(children: [
          Row(children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Exit Assessment?'),
                  content: const Text('Your progress will be lost.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep going')),
                    TextButton(onPressed: () { Navigator.pop(context); setState(() { _questions = []; _answers = []; _current = 0; }); }, child: const Text('Exit', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ),
            ),
            Expanded(child: Column(children: [
              Text('Question ${_current + 1} of ${_questions.length}', style: const TextStyle(color: Colors.white, fontSize: 13)),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: (_current + 1) / _questions.length,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 5,
                borderRadius: BorderRadius.circular(3),
              ),
            ])),
            const SizedBox(width: 48),
          ]),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _SectionChip('Grammar', _questions[_current].section == 'grammar', Colors.blue),
            const SizedBox(width: 6),
            _SectionChip('Vocabulary', _questions[_current].section == 'vocabulary', Colors.purple),
            const SizedBox(width: 6),
            _SectionChip('Structure', _questions[_current].section == 'structure', Colors.teal),
          ]),
        ]),
      );
    }

    // Default header
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            if (_submitted || _questions.isNotEmpty)
              IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                  onPressed: () => setState(() { _questions = []; _answers = []; _current = 0; _submitted = false; }))
            else
              IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                  onPressed: () => context.go('/home')),
            const Expanded(
              child: Text('Level Assessment', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
            const SizedBox(width: 48),
          ]),
        ),
        if (_questions.isEmpty && !_submitted)
          TabBar(
            controller: _tabCtrl,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: const [Tab(text: 'Assessment'), Tab(text: 'History')],
          ),
      ]),
    );
  }

  // ─── Welcome ──────────────────────────────────────────────────────────────

  Widget _buildWelcome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 52),
          ),
          const SizedBox(height: 24),
          const Text('English Level Assessment', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          const Text('TOEFL-standard questions across Grammar, Vocabulary, and Sentence Structure', style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5), textAlign: TextAlign.center),
          const SizedBox(height: 28),
          Row(children: [
            _InfoBox(Icons.quiz_outlined, '20', 'Questions', Colors.blue),
            const SizedBox(width: 12),
            _InfoBox(Icons.timer_outlined, '15–20', 'Minutes', Colors.orange),
            const SizedBox(width: 12),
            _InfoBox(Icons.refresh, 'New', 'Every time', Colors.green),
          ]),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('What you\'ll be tested on:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 10),
              _dot('Grammar (10 questions) — tenses, passive voice, conditionals, reported speech'),
              _dot('Vocabulary (5 questions) — meaning in context, TOEFL academic word list'),
              _dot('Structure (5 questions) — sentence completion, word order, collocations'),
            ]),
          ),
          const SizedBox(height: 20),
          if (_history.isNotEmpty) Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(children: [
              Icon(Icons.history, color: Colors.green[700], size: 20),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Last result', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('${_history.first.cefrLevel} — ${_cefrLabel(_history.first.cefrLevel)}  •  ${_history.first.correct}/${_history.first.total} correct',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800])),
              ])),
              TextButton(onPressed: () => _tabCtrl.animateTo(1), child: const Text('See history')),
            ]),
          ),
          const SizedBox(height: 28),
          CustomButton(label: 'Start Assessment', onPressed: _startSession),
          const SizedBox(height: 12),
          TextButton(onPressed: () => context.go('/home'), child: const Text('Go back to home', style: TextStyle(color: Colors.grey))),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _dot(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4))),
    ]),
  );

  // ─── Question ─────────────────────────────────────────────────────────────

  Widget _buildQuestion() {
    final q = _questions[_current];
    final sectionColors = {'grammar': Colors.blue, 'vocabulary': Colors.purple, 'structure': Colors.teal};
    final color = sectionColors[q.section] ?? AppColors.primary;

    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Section badge
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(q.section[0].toUpperCase() + q.section.substring(1),
                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                child: Text('Level ${q.level}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ]),
            const SizedBox(height: 20),
            Text(q.text, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.5)),
            const SizedBox(height: 24),
            ...q.options.asMap().entries.map((e) {
              final selected = _answers[_current] == e.key;
              return GestureDetector(
                onTap: () => _selectAnswer(e.key),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected ? color.withOpacity(0.08) : Colors.white,
                    border: Border.all(color: selected ? color : Colors.grey[300]!, width: selected ? 2 : 1),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: selected ? [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8)] : [],
                  ),
                  child: Row(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: selected ? color : Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text(
                        String.fromCharCode(65 + e.key),
                        style: TextStyle(fontWeight: FontWeight.bold, color: selected ? Colors.white : Colors.grey[600], fontSize: 14),
                      )),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Text(e.value, style: TextStyle(fontSize: 15, color: selected ? color : Colors.black87, fontWeight: selected ? FontWeight.w600 : FontWeight.normal))),
                  ]),
                ),
              );
            }),
          ]),
        ),
      ),

      // Navigation bar
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: Row(children: [
          if (_current > 0)
            OutlinedButton.icon(
              onPressed: _prev,
              icon: const Icon(Icons.arrow_back_ios, size: 14),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: _answers[_current] != null && !_loading ? _next : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_current < _questions.length - 1 ? 'Next →' : 'Submit'),
          ),
        ]),
      ),
    ]);
  }

  // ─── Results ──────────────────────────────────────────────────────────────

  Widget _buildResults(_Result r) {
    final color = _cefrColor(r.cefrLevel);
    final overall = r.correct / r.total;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const SizedBox(height: 8),
        // Main result card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(children: [
            Text(r.cefrLevel, style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold)),
            Text(_cefrLabel(r.cefrLevel), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Text('${r.correct} / ${r.total} correct  •  ${(overall * 100).round()}%',
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ]),
        ),
        const SizedBox(height: 20),

        // TOEFL & IELTS estimates
        Row(children: [
          Expanded(child: _ScoreCard('TOEFL iBT', _toeflFromCefr(r.cefrLevel), Icons.assignment, Colors.blue)),
          const SizedBox(width: 12),
          Expanded(child: _ScoreCard('IELTS Est.', _ieltsFromCefr(r.cefrLevel), Icons.school, Colors.green)),
        ]),
        const SizedBox(height: 20),

        // Skill breakdown
        _Section(title: 'Skill Breakdown', child: Column(children: [
          _ScoreBar('Grammar',   r.grammarPct,   Colors.blue),
          _ScoreBar('Vocabulary', r.vocabPct,    Colors.purple),
          _ScoreBar('Structure', r.structurePct,  Colors.teal),
          _ScoreBar('Overall',   overall,         color),
        ])),
        const SizedBox(height: 16),

        // Recommendation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.lightbulb, color: color, size: 20),
              const SizedBox(width: 8),
              Text('AI Recommendation', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ]),
            const SizedBox(height: 8),
            Text(_recommendation(r.cefrLevel), style: const TextStyle(color: Colors.black87, height: 1.5)),
          ]),
        ),
        const SizedBox(height: 20),

        // Answer review
        _Section(
          title: 'Review Your Answers',
          child: Column(children: _questions.asMap().entries.map((e) {
            final correct = _answers[e.key] == e.value.answer;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: correct ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: correct ? Colors.green[200]! : Colors.red[200]!),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(correct ? Icons.check_circle : Icons.cancel, color: correct ? Colors.green : Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Q${e.key + 1}: ${e.value.text}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis)),
                ]),
                if (!correct) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 26),
                    child: Text('Correct: ${e.value.options[e.value.answer]}', style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                ],
              ]),
            );
          }).toList()),
        ),
        const SizedBox(height: 20),

        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () => setState(() { _questions = []; _answers = []; _current = 0; _submitted = false; }),
            icon: const Icon(Icons.home_outlined),
            label: const Text('Home'),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton.icon(
            onPressed: _startSession,
            icon: const Icon(Icons.refresh),
            label: const Text('Retake'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          )),
        ]),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.rocket_launch),
            label: const Text('Start My Learning Plan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }

  // ─── History ──────────────────────────────────────────────────────────────

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.history, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No assessments yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 8),
          const Text('Take an assessment to track your progress over time.', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () { _tabCtrl.animateTo(0); },
            child: const Text('Take Assessment'),
          ),
        ]),
      );
    }

    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('${_history.length} assessment${_history.length == 1 ? '' : 's'}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
        TextButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Clear History?'),
              content: const Text('All past assessment results will be permanently deleted.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                TextButton(
                  onPressed: () async {
                    await sl<StorageService>().delete(_historyKey);
                    setState(() => _history = []);
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Clear', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
          label: const Text('Clear all', style: TextStyle(color: Colors.red, fontSize: 13)),
        ),
      ]),
      const SizedBox(height: 8),
      ..._history.asMap().entries.map((entry) {
        final i = entry.key;
        final r = entry.value;
        final color = _cefrColor(r.cefrLevel);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            border: i == 0 ? Border.all(color: color.withOpacity(0.4), width: 1.5) : null,
          ),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(r.cefrLevel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(_cefrLabel(r.cefrLevel), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                if (i == 0) Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('Latest', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold))),
              ]),
              Text('${r.correct}/${r.total} correct  •  ${(r.correct / r.total * 100).round()}%',
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Text(_formatDate(r.date), style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('TOEFL', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
              Text(_toeflFromCefr(r.cefrLevel), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ]),
        );
      }),
    ]);
  }

  static String _formatDate(DateTime d) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}  ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _SectionChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  const _SectionChip(this.label, this.active, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: active ? Colors.white : Colors.white24,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: TextStyle(fontSize: 11, color: active ? color : Colors.white70, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
  );
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _InfoBox(this.icon, this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    ),
  );
}

class _ScoreCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _ScoreCard(this.title, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.2))),
    child: Column(children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(height: 6),
      Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
    ]),
  );
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _ScoreBar(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      SizedBox(width: 86, child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87))),
      Expanded(child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(value: value, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation(color), minHeight: 10),
      )),
      const SizedBox(width: 8),
      SizedBox(width: 38, child: Text('${(value * 100).round()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
    ]),
  );
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
      const SizedBox(height: 14),
      child,
    ]),
  );
}
