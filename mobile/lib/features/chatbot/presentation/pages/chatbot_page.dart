import 'dart:math' show Random;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});
  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _msgs = <Map<String, dynamic>>[
    {
      'text':
          'Hello! I\'m your English conversation partner. I can help you practise speaking, correct your grammar, and teach you new vocabulary.\n\nChoose a topic below or just type anything to start! 😊',
      'isUser': false,
    },
  ];
  bool _typing = false;
  String? _activeTopic;

  static const _topics = ['Travel', 'Food', 'Work', 'Movies', 'Sports', 'Education'];

  Future<void> _send([String? override]) async {
    final text = (override ?? _ctrl.text).trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    setState(() {
      _msgs.add({'text': text, 'isUser': true});
      _typing = true;
    });
    _scrollToBottom();

    // Simulate thinking time
    await Future.delayed(Duration(milliseconds: 900 + Random().nextInt(600)));

    final history = _msgs.where((m) => m['isUser'] as bool).map((m) => m['text'] as String).toList();
    final reply = ChatbotEngine.respond(text, history, _activeTopic);
    if (reply.newTopic != null) _activeTopic = reply.newTopic;

    if (!mounted) return;
    setState(() {
      _typing = false;
      _msgs.add({'text': reply.text, 'isUser': false, 'correction': reply.correction});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AI Conversation Partner', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Practise English freely', style: TextStyle(fontSize: 11, color: Colors.white70)),
        ]),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'New conversation',
            onPressed: () => setState(() {
              _msgs.clear();
              _msgs.add({'text': 'Sure! Let\'s start fresh. What would you like to talk about today?', 'isUser': false});
              _activeTopic = null;
            }),
          ),
        ],
      ),
      body: Column(children: [
        // Topic chips
        SizedBox(
          height: 46,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: _topics.map((t) {
              final active = _activeTopic == t;
              return GestureDetector(
                onTap: () => _send('Let\'s talk about $t'),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Text(t,
                      style: TextStyle(
                          fontSize: 13,
                          color: active ? Colors.white : AppColors.primary,
                          fontWeight: active ? FontWeight.bold : FontWeight.normal)),
                ),
              );
            }).toList(),
          ),
        ),

        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            itemCount: _msgs.length + (_typing ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == _msgs.length) {
                return _buildTyping();
              }
              final m = _msgs[i];
              final isUser = m['isUser'] as bool;
              final correction = m['correction'] as String?;
              return Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: correction != null ? 4 : 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                      decoration: BoxDecoration(
                        gradient: isUser
                            ? const LinearGradient(colors: [AppColors.primary, AppColors.secondary])
                            : null,
                        color: isUser ? null : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isUser ? 18 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 18),
                        ),
                        boxShadow: isUser
                            ? []
                            : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Text(m['text'] as String,
                          style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                              fontSize: 15,
                              height: 1.5)),
                    ),
                  ),
                  if (correction != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('✏️ ', style: TextStyle(fontSize: 13)),
                          Expanded(
                            child: Text(correction,
                                style: TextStyle(
                                    color: Colors.orange.shade900, fontSize: 13, height: 1.4)),
                          ),
                        ]),
                      ),
                    ),
                ],
              );
            },
          ),
        ),

        // Input bar
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                maxLines: 3,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message in English…',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              onPressed: _send,
              mini: true,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildTyping() => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
      ),
      child: const _TypingDots(),
    ),
  );
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) {
          final phase = (_c.value * 3 - i).clamp(0.0, 1.0);
          final opacity = 0.3 + 0.7 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade400.withOpacity(opacity),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }));
      },
    );
  }
}

// ─── Chatbot Engine ───────────────────────────────────────────────────────────

class _Reply {
  final String text;
  final String? correction; // grammar correction shown in amber box
  final String? newTopic;
  const _Reply(this.text, {this.correction, this.newTopic});
}

class ChatbotEngine {
  static final _rng = Random();

  static _Reply respond(String input, List<String> history, String? currentTopic) {
    final lower = input.toLowerCase().trim();

    // ── 1. Detect grammar errors first ───────────────────────────────────────
    final correction = _checkGrammar(input);

    // ── 2. Detect topic switch ────────────────────────────────────────────────
    String? detectedTopic = _detectTopic(lower);

    // ── 3. Detect intent ──────────────────────────────────────────────────────
    if (_isGreeting(lower)) {
      return _Reply(
        _pick(['Hi there! Great to see you! What would you like to practise today — grammar, vocabulary, or just have a conversation?',
          'Hello! Welcome back. Shall we continue where we left off, or start a new topic?',
          'Hey! Ready to practise your English? I can help you with conversation, grammar, or vocabulary. What would you like?']),
        correction: correction,
      );
    }

    if (_isGoodbye(lower)) {
      return _Reply(
        _pick(['Goodbye! Great chatting with you. Keep practising your English every day — even 10 minutes makes a difference!',
          'See you later! Remember: consistent practice is the key to fluency. Come back anytime!',
          'Bye! You\'re doing really well. Keep it up!']),
        correction: correction,
      );
    }

    if (_isThankYou(lower)) {
      return _Reply(
        _pick(['You\'re very welcome! Learning a language takes patience — you\'re doing great. What shall we practise next?',
          'My pleasure! That\'s what I\'m here for. Is there anything specific you\'d like to work on?',
          'Happy to help! Remember, every conversation you have in English makes you better. What else is on your mind?']),
        correction: correction,
      );
    }

    // ── 4. Grammar question detection ────────────────────────────────────────
    final grammarReply = _handleGrammarQuestion(lower);
    if (grammarReply != null) {
      return _Reply(grammarReply, correction: correction);
    }

    // ── 5. Vocabulary question detection ─────────────────────────────────────
    final vocabReply = _handleVocabQuestion(lower);
    if (vocabReply != null) {
      return _Reply(vocabReply, correction: correction);
    }

    // ── 6. Short / nonsense input detection ──────────────────────────────────
    final wordCount = input.trim().split(RegExp(r'\s+')).length;
    if (wordCount <= 2 && !_looksLikeEnglish(lower)) {
      return _Reply(
        'I didn\'t quite understand that. Try writing a full sentence in English — for example: "I like travelling to new places." What would you like to talk about?',
        correction: correction,
      );
    }

    if (wordCount == 1) {
      return _Reply(
        'Could you say a bit more? Writing full sentences helps you practise English better. For example, instead of just "$input", you could say "I think $input is very important." Give it a try!',
        correction: correction,
      );
    }

    // ── 7. Topic-specific responses ───────────────────────────────────────────
    final topic = detectedTopic ?? currentTopic;
    if (topic != null) {
      final topicReply = _handleTopic(lower, topic, history.length);
      if (topicReply != null) {
        return _Reply(topicReply, correction: correction, newTopic: detectedTopic ?? currentTopic);
      }
    }

    // ── 8. General conversational fallback ────────────────────────────────────
    return _Reply(_generalReply(lower, input), correction: correction, newTopic: detectedTopic);
  }

  // ─── Grammar checking ──────────────────────────────────────────────────────

  static String? _checkGrammar(String text) {
    final issues = <String>[];
    final lower = text.toLowerCase();
    final words = lower.split(RegExp(r'\s+'));

    // Uncapitalised "i"
    if (RegExp(r'(?<![a-z])i ').hasMatch(text) && !text.startsWith('I ')) {
      issues.add('Always capitalise "I" when it\'s a pronoun: write "I" not "i".');
    }

    // Missing apostrophe in contractions
    if (RegExp(r'\b(dont|cant|wont|didnt|isnt|arent|wasnt|werent|hasnt|havent|wouldnt|couldnt|shouldnt)\b').hasMatch(lower)) {
      issues.add('Remember contractions need an apostrophe: "don\'t", "can\'t", "won\'t", "didn\'t", etc.');
    }

    // He/She/It + base verb (missing -s)
    final heSheShe = RegExp(r'\b(he|she|it)\s+(go|come|work|play|like|have|make|want|need|think|know|see|get|do|say|tell|live|eat|drink|read|write|speak|learn|teach|run|walk|drive|fly|swim|dance|sing|cook|clean|buy|sell)\b');
    if (heSheShe.hasMatch(lower)) {
      final m = heSheShe.firstMatch(lower)!;
      final subject = m.group(1)!;
      final verb = m.group(2)!;
      final fixed = verb == 'have' ? 'has' : verb == 'go' ? 'goes' : verb == 'do' ? 'does' : '${verb}s';
      issues.add('With "${subject[0].toUpperCase()}${subject.substring(1)}", the verb needs -s: "${subject[0].toUpperCase()}${subject.substring(1)} $fixed" not "${subject[0].toUpperCase()}${subject.substring(1)} $verb".');
    }

    // "Yesterday I [present tense verb]" — should be past
    final yesterdayPresent = RegExp(r'\byesterday\s+i\s+(go|come|eat|see|have|make|buy|sell|work|play|watch|visit|meet|read|write|speak|learn)\b');
    if (yesterdayPresent.hasMatch(lower)) {
      final m = yesterdayPresent.firstMatch(lower)!;
      final verb = m.group(1)!;
      final pastForms = {'go':'went','come':'came','eat':'ate','see':'saw','have':'had','make':'made','buy':'bought','sell':'sold','work':'worked','play':'played','watch':'watched','visit':'visited','meet':'met','read':'read','write':'wrote','speak':'spoke','learn':'learnt'};
      final past = pastForms[verb] ?? '${verb}ed';
      issues.add('"Yesterday" requires the past tense: "Yesterday I $past" not "Yesterday I $verb".');
    }

    // "I am + [past tense verb]" confusion
    if (RegExp(r'\bi am (went|came|ate|saw|had|made|bought|got|did|said|told)\b').hasMatch(lower)) {
      issues.add('Be careful: "I am" is present, not past. Use "I went", "I came", "I ate" (not "I am went").');
    }

    // Missing article before consonant noun
    final missingArticle = RegExp(r'\b(have|has|is|are|see|met|visited|got)\s+(dog|cat|car|book|phone|job|friend|brother|sister|teacher|student|city|country|school|university|problem|idea|question|mistake)\b');
    if (missingArticle.hasMatch(lower)) {
      final m = missingArticle.firstMatch(lower)!;
      final noun = m.group(2)!;
      issues.add('Don\'t forget the article: use "a $noun" (or "the $noun" if it\'s specific).');
    }

    // "More + [one-syllable adjective]" — should use -er
    final moreShort = RegExp(r'\bmore\s+(big|small|tall|short|old|new|fast|slow|hot|cold|hard|soft|long|rich|poor|young|cheap|clean|dark|bright)\b');
    if (moreShort.hasMatch(lower)) {
      final m = moreShort.firstMatch(lower)!;
      final adj = m.group(1)!;
      final comparatives = {'big':'bigger','small':'smaller','tall':'taller','short':'shorter','old':'older','new':'newer','fast':'faster','slow':'slower','hot':'hotter','cold':'colder','hard':'harder','soft':'softer','long':'longer','rich':'richer','poor':'poorer','young':'younger','cheap':'cheaper','clean':'cleaner','dark':'darker','bright':'brighter'};
      issues.add('For short adjectives, use -er not "more": "${comparatives[adj]}" not "more $adj".');
    }

    if (issues.isEmpty) return null;
    return issues.join(' ');
  }

  // ─── Topic detection ────────────────────────────────────────────────────────

  static String? _detectTopic(String lower) {
    if (_matches(lower, ['travel', 'trip', 'holiday', 'vacation', 'visit', 'country', 'city', 'airport', 'hotel', 'flight', 'abroad', 'tourist', 'passport'])) return 'Travel';
    if (_matches(lower, ['food', 'eat', 'cook', 'restaurant', 'meal', 'recipe', 'hungry', 'dish', 'cuisine', 'breakfast', 'lunch', 'dinner', 'taste', 'delicious'])) return 'Food';
    if (_matches(lower, ['work', 'job', 'career', 'office', 'boss', 'colleague', 'salary', 'meeting', 'project', 'business', 'employee', 'interview', 'company'])) return 'Work';
    if (_matches(lower, ['movie', 'film', 'cinema', 'actor', 'actress', 'director', 'watch', 'series', 'tv show', 'netflix', 'scene', 'plot', 'character'])) return 'Movies';
    if (_matches(lower, ['sport', 'football', 'soccer', 'basketball', 'tennis', 'gym', 'exercise', 'team', 'player', 'match', 'game', 'training', 'fit', 'health'])) return 'Sports';
    if (_matches(lower, ['school', 'university', 'study', 'learn', 'student', 'teacher', 'class', 'exam', 'degree', 'course', 'education', 'grade', 'subject'])) return 'Education';
    return null;
  }

  // ─── Grammar question handler ──────────────────────────────────────────────

  static String? _handleGrammarQuestion(String lower) {
    if (_matches(lower, ['present perfect', 'have been', 'has been', 'have done'])) {
      return 'The present perfect connects the past to the present. We use it for:\n\n'
          '• Experience: "I have visited Paris." (at some point in my life)\n'
          '• Recent past with present effect: "I have lost my keys." (they\'re still lost)\n'
          '• Duration to now: "I have lived here for 5 years."\n\n'
          'Formula: Subject + have/has + past participle\n'
          '"She has worked here since 2019."\n\n'
          'Would you like to practise making sentences with the present perfect?';
    }
    if (_matches(lower, ['past simple', 'simple past', 'regular verb', 'irregular verb'])) {
      return 'The past simple is used for completed actions in the past.\n\n'
          '• Regular verbs: add -ed → "I worked", "She played", "We visited"\n'
          '• Irregular verbs: change form → "I went", "She saw", "We ate"\n'
          '• Negatives: did not + base verb → "I didn\'t go"\n'
          '• Questions: Did + subject + base verb? → "Did you eat?"\n\n'
          'Can you make a sentence about something you did yesterday?';
    }
    if (_matches(lower, ['passive voice', 'passive'])) {
      return 'The passive voice focuses on the action, not who does it.\n\n'
          '• Active: "The teacher explains the lesson."\n'
          '• Passive: "The lesson is explained by the teacher."\n\n'
          'Formula: Subject + be (correct tense) + past participle\n'
          '"The book was written in 1990."\n'
          '"The project will be completed next week."\n\n'
          'We often use passive when we don\'t know or don\'t want to say who did the action. Can you try making a passive sentence?';
    }
    if (_matches(lower, ['conditional', 'if clause', 'would', 'second conditional', 'third conditional', 'first conditional'])) {
      return 'Conditionals describe conditions and results:\n\n'
          '• Zero conditional (facts): "If you heat water to 100°C, it boils."\n'
          '• First conditional (real future): "If it rains, I will stay home."\n'
          '• Second conditional (unreal present): "If I had a million pounds, I would travel the world."\n'
          '• Third conditional (unreal past): "If I had studied harder, I would have passed the exam."\n\n'
          'Which type would you like to practise?';
    }
    if (_matches(lower, ['article', 'a or an', 'the', 'definite', 'indefinite'])) {
      return 'Articles can be tricky! Here are the key rules:\n\n'
          '• "a" before consonant sounds: "a book", "a university" (yu-sound)\n'
          '• "an" before vowel sounds: "an apple", "an hour" (silent h)\n'
          '• "the" for specific, known things: "Pass me the book on the table."\n'
          '• No article for general nouns: "I like music." / "Lions are dangerous."\n\n'
          'The most common mistake is using "the" when no article is needed. Try making a sentence using all three types!';
    }
    if (_matches(lower, ['tense', 'tenses', 'which tense', 'what tense'])) {
      return 'English has several main tenses. Here\'s a quick guide:\n\n'
          '• Simple present: "She works every day." (habits/facts)\n'
          '• Present continuous: "She is working now." (happening now)\n'
          '• Simple past: "She worked yesterday." (completed action)\n'
          '• Present perfect: "She has worked here for years." (past → present)\n'
          '• Future: "She will work tomorrow." (future plan)\n\n'
          'Which tense do you find most difficult?';
    }
    return null;
  }

  // ─── Vocabulary question handler ───────────────────────────────────────────

  static String? _handleVocabQuestion(String lower) {
    if (RegExp(r'\bwhat (does|is the meaning of|means)\b').hasMatch(lower)) {
      // Extract the word being asked about
      final wordMatch = RegExp(r'\bwhat (?:does|is the meaning of)\s+"?(\w+)"?\s*mean').firstMatch(lower);
      if (wordMatch != null) {
        return 'That\'s a great vocabulary question! Unfortunately I can\'t look up every word, but I can suggest: '
            'open a dictionary app like Merriam-Webster or Cambridge Dictionary to find the exact meaning, then come back and try to use the word in a sentence. '
            'Using new words in context is the best way to remember them! Would you like to practise using it?';
      }
    }
    if (_matches(lower, ['synonym', 'synonyms', 'another word for', 'similar word'])) {
      return 'Building synonyms is a great way to improve your vocabulary!\n\n'
          'Some useful synonym groups:\n'
          '• Big: large, enormous, huge, vast, substantial\n'
          '• Good: excellent, outstanding, superb, brilliant, wonderful\n'
          '• Important: crucial, essential, significant, vital, key\n'
          '• Happy: joyful, delighted, pleased, content, cheerful\n\n'
          'Using varied vocabulary makes your English much more sophisticated. What word would you like synonyms for?';
    }
    if (_matches(lower, ['phrasal verb', 'phrasal verbs', 'look up', 'give up', 'run out'])) {
      return 'Phrasal verbs are very common in everyday English!\n\n'
          'Here are some useful ones:\n'
          '• "give up" = stop trying: "Don\'t give up learning English!"\n'
          '• "look forward to" = be excited about: "I\'m looking forward to the weekend."\n'
          '• "run out of" = have no more: "We\'ve run out of time."\n'
          '• "get along with" = have a good relationship: "I get along well with my colleagues."\n'
          '• "come across" = find by chance: "I came across an interesting article."\n\n'
          'Can you make a sentence using one of these?';
    }
    return null;
  }

  // ─── Topic-specific responses ──────────────────────────────────────────────

  static String? _handleTopic(String lower, String topic, int depth) {
    switch (topic) {
      case 'Travel': return _travelReply(lower, depth);
      case 'Food':   return _foodReply(lower, depth);
      case 'Work':   return _workReply(lower, depth);
      case 'Movies': return _moviesReply(lower, depth);
      case 'Sports': return _sportsReply(lower, depth);
      case 'Education': return _educationReply(lower, depth);
    }
    return null;
  }

  static String _travelReply(String lower, int depth) {
    if (_matches(lower, ['favourite', 'favorite', 'best', 'love', 'amazing', 'beautiful', 'wonderful'])) {
      return _pick([
        'That sounds incredible! What made it your favourite — the culture, the food, or the scenery?',
        'Wonderful choice! Did you go with family, friends, or alone? How did you get there?',
        'That\'s a great destination. Would you recommend it to other travellers? What\'s the one thing they must see?',
      ]);
    }
    if (_matches(lower, ['want', 'dream', 'would like', 'plan', 'hope'])) {
      return _pick([
        'Great travel ambitions! What attracts you to that place — the history, the beaches, or the food?',
        'That\'s on many people\'s bucket list! What would you do first when you arrive?',
        'Exciting! Are you planning to go soon, or is it a future dream? How would you prepare for such a trip?',
      ]);
    }
    if (_matches(lower, ['problem', 'lost', 'difficult', 'hard', 'issue', 'trouble'])) {
      return _pick([
        'Travelling can definitely have its challenges! What happened exactly? Describing the problem in detail is great English practice.',
        'Oh no! Problems while travelling can be stressful. How did you deal with it? What would you do differently next time?',
      ]);
    }
    return _pick([
      'Travelling is such a rich topic for conversation! Tell me: have you ever been to a country where you didn\'t speak the language? How did you manage?',
      'Travel broadens the mind! What do you think is more valuable — travelling to many countries briefly, or staying in one place for a long time?',
      'Let\'s go deeper on travel! What\'s your packing strategy — do you travel light or take everything? And what\'s the one thing you always bring?',
      'Fascinating! When you travel, do you prefer planned itineraries or spontaneous adventures? Why?',
      'Interesting! Do you think travel changes people? Has travelling changed the way you see the world?',
    ]);
  }

  static String _foodReply(String lower, int depth) {
    if (_matches(lower, ['cook', 'recipe', 'make', 'prepare', 'bake'])) {
      return _pick([
        'You cook? Wonderful! What\'s your signature dish — the one you\'re most proud of? Walk me through how you make it!',
        'Home cooking is a great skill. Do you prefer cooking for yourself or for others? What type of cuisine do you enjoy cooking most?',
        'A chef in the making! What\'s the most difficult thing you\'ve ever attempted to cook? Did it work out?',
      ]);
    }
    if (_matches(lower, ['restaurant', 'cafe', 'eat out', 'takeaway', 'delivery'])) {
      return _pick([
        'Eating out is always fun! Do you have a favourite restaurant? What makes it special — the food, the atmosphere, or the service?',
        'When you choose a restaurant, what\'s most important to you? The price, the quality, the menu variety, or the location?',
        'Interesting! Do you think home cooking is healthier than restaurant food? Why or why not?',
      ]);
    }
    if (_matches(lower, ['favourite', 'favorite', 'love', 'best', 'delicious', 'amazing'])) {
      return _pick([
        'That sounds delicious! Is that something you grew up eating, or did you discover it later? How would you describe the taste to someone who\'s never tried it?',
        'Wonderful taste! Does that dish have any cultural significance in your country? Or is it something you discovered elsewhere?',
        'Yummy! If you had to describe that food to someone who\'s never seen or tasted it, what five words would you use?',
      ]);
    }
    return _pick([
      'Food is a wonderful topic! Do you prefer the cuisine from your own country or trying foreign dishes? Why?',
      'Let\'s talk about food in more depth! Do you think people in your country eat healthily? What are the most common dishes?',
      'Interesting! Do you believe food is just fuel for the body, or is it part of culture and identity? Give me your opinion!',
      'Here\'s a question: if you could only eat one cuisine for the rest of your life, what would you choose and why?',
    ]);
  }

  static String _workReply(String lower, int depth) {
    if (_matches(lower, ['stress', 'tired', 'busy', 'difficult', 'hard', 'overtime', 'pressure'])) {
      return _pick([
        'Work-life balance is really important. How do you manage stress when work gets overwhelming? What strategies do you use?',
        'That sounds challenging! Do you think your workplace does enough to support employees\' wellbeing? What could be improved?',
        'Many people struggle with work pressure. Do you believe it\'s possible to have a successful career and still have time for personal life?',
      ]);
    }
    if (_matches(lower, ['dream job', 'ideal job', 'want to be', 'career goal', 'ambition'])) {
      return _pick([
        'That\'s an inspiring goal! What skills do you think you need to develop to achieve it? What steps are you taking now?',
        'Fascinating career choice! What motivates you most — the salary, the passion for the work, or the impact you can make?',
        'Great ambition! Do you think it\'s more important to follow your passion or to pursue financial security in your career?',
      ]);
    }
    if (_matches(lower, ['colleague', 'boss', 'team', 'manager', 'coworker'])) {
      return _pick([
        'Workplace relationships really affect job satisfaction! How would you describe the culture in your workplace? Is it collaborative or competitive?',
        'Having good colleagues makes such a difference. What qualities do you value most in a teammate or manager?',
        'Interesting! Have you ever had a conflict with a colleague? How did you resolve it? This is a very common interview question too!',
      ]);
    }
    return _pick([
      'Work is such an important part of life. What do you think makes someone really successful in their career — talent, hard work, or connections?',
      'Let\'s discuss work further! Do you prefer working in an office, from home, or a mix of both? What are the advantages and disadvantages?',
      'Here\'s a thought-provoking question: If you won the lottery, would you still work? What does work mean to you beyond just money?',
      'Interesting perspective! Do you think it\'s possible to be both highly successful at work AND have a great personal life? How?',
    ]);
  }

  static String _moviesReply(String lower, int depth) {
    if (_matches(lower, ['favourite', 'favorite', 'best', 'love', 'recommend', 'amazing'])) {
      return _pick([
        'Great taste! What makes that film so special to you? Is it the acting, the story, the direction, or the emotional impact?',
        'Interesting choice! Who\'s your favourite actor or director? What is it about their work that you admire?',
        'Would you recommend that film to a friend? How would you describe the plot without spoiling it? That\'s great English practice!',
      ]);
    }
    if (_matches(lower, ['action', 'comedy', 'drama', 'horror', 'romance', 'thriller', 'documentary', 'animation'])) {
      return _pick([
        'That\'s a popular genre! What is it about that genre that appeals to you? What elements make a really good film of that type?',
        'Interesting choice of genre! Can you recommend one film from that category that you think everyone should watch? Tell me a bit about it.',
        'Different genres serve different moods! Do you ever watch films from other genres, or do you always stick to your favourite type?',
      ]);
    }
    if (_matches(lower, ['actor', 'actress', 'director', 'character', 'scene', 'plot', 'ending'])) {
      return _pick([
        'Film analysis is fascinating! Can you describe what made that aspect so memorable? Details make your English more expressive.',
        'Great observation! Do you think the director made the right choices? How would you have done it differently?',
        'You clearly think deeply about films! Have you ever considered writing a film review? It\'s excellent English writing practice.',
      ]);
    }
    return _pick([
      'Let\'s talk cinema! Do you prefer watching films at home or at the cinema? What\'s the difference in experience?',
      'Film is a great topic! Do you think films from your country are well-known internationally? What does your national cinema offer that Hollywood doesn\'t?',
      'Here\'s an interesting debate: Are streaming services like Netflix better or worse for the film industry? Share your opinion!',
      'Films can teach us so much! Have you ever learnt something important from a film? What was it and how did it affect you?',
    ]);
  }

  static String _sportsReply(String lower, int depth) {
    if (_matches(lower, ['favourite', 'favorite', 'best', 'love', 'support', 'team', 'play', 'watch'])) {
      return _pick([
        'Sports passion is wonderful! Do you prefer playing sports yourself or watching them? What draws you to that choice?',
        'Great sport! Have you ever played it competitively or just for fun? How long have you been involved with it?',
        'Interesting! Do you think being a sports fan teaches you anything useful in life — teamwork, dealing with failure, perseverance?',
      ]);
    }
    if (_matches(lower, ['health', 'fitness', 'exercise', 'gym', 'training', 'workout'])) {
      return _pick([
        'Fitness is so important. What\'s your exercise routine? Do you prefer structured workouts or more casual activity like walking or cycling?',
        'That\'s a healthy approach! Do you think people in your country generally lead healthy lifestyles? What could be improved?',
        'Interesting! Some people exercise for health, others for appearance, others for mental wellbeing. What\'s your primary motivation?',
      ]);
    }
    if (_matches(lower, ['world cup', 'olympics', 'championship', 'final', 'tournament', 'international'])) {
      return _pick([
        'Big sporting events bring the world together! Did you watch the last one? What was the most memorable moment for you?',
        'International competitions are so exciting! Do you think sports can help build friendships between countries? Give an example.',
        'Let\'s discuss! Do you think hosting major sporting events like the Olympics is worth the cost for a country? Why or why not?',
      ]);
    }
    return _pick([
      'Sports is a fascinating topic! Do you think sports teaches children important life lessons? What values can be learnt from sport?',
      'Let\'s debate! Do you think professional athletes are paid too much? Justify your opinion!',
      'Interesting! Are extreme sports like skydiving or base jumping real sports, or just dangerous hobbies? Where do you draw the line?',
      'Some people say eSports (competitive video gaming) should be in the Olympics. What\'s your view? Is it a real sport?',
    ]);
  }

  static String _educationReply(String lower, int depth) {
    if (_matches(lower, ['university', 'college', 'degree', 'graduate', 'student', 'study'])) {
      return _pick([
        'University life is such an important experience! What subject did you study or are you studying? Why did you choose it?',
        'Higher education opens so many doors! Do you think a university degree is essential for success in today\'s world? Why?',
        'Interesting! Did your degree match your career expectations? Would you choose the same subject again?',
      ]);
    }
    if (_matches(lower, ['learn', 'english', 'language', 'study', 'improve', 'fluent', 'fluency'])) {
      return _pick([
        'Learning English is such a valuable skill! How long have you been studying it? What methods work best for you?',
        'Great dedication to learning! Do you think it\'s better to learn a language by studying grammar rules or through conversation? Why?',
        'That\'s fantastic! What\'s your biggest challenge when speaking English? Is it vocabulary, pronunciation, or finding the right words quickly?',
        'Wonderful! Do you have an English learning goal — like passing an exam, or using it for work or travel? What\'s your target level?',
      ]);
    }
    if (_matches(lower, ['school', 'teacher', 'class', 'lesson', 'exam', 'test'])) {
      return _pick([
        'School experiences shape us so much! What subject were you best at in school? Did you enjoy learning it or were you just naturally good at it?',
        'Teachers make such a difference! Who was your most influential teacher? What made them special?',
        'Exams are stressful! Do you think exams are the best way to measure a student\'s ability? What alternatives could be used?',
      ]);
    }
    return _pick([
      'Education is fascinating! Do you think the education system in your country prepares young people well for modern life? What would you change?',
      'Let\'s debate: Is formal education more important than real-world experience? Which has benefited you more in your life?',
      'Interesting topic! With online learning becoming so common, do you think traditional classroom education will still exist in 50 years?',
      'Here\'s a thought: Should education be completely free for everyone? What are the arguments for and against?',
    ]);
  }

  // ─── General fallback ─────────────────────────────────────────────────────

  static String _generalReply(String lower, String original) {
    // If they seem to be sharing an opinion
    if (_matches(lower, ['i think', 'i believe', 'in my opinion', 'i feel', 'i agree', 'i disagree', 'personally'])) {
      return _pick([
        'That\'s a well-expressed opinion! I can see your point. Can you give me an example from your own experience that supports this view?',
        'Interesting perspective! Have you always thought this way, or has something changed your opinion over time?',
        'I see where you\'re coming from. Can you think of any argument against your own view? Considering both sides strengthens your reasoning.',
        'Good point! How confident are you in that opinion — is it something you feel very strongly about, or are you open to being persuaded otherwise?',
      ]);
    }

    // If they ask a question
    if (lower.contains('?') || lower.startsWith('what ') || lower.startsWith('how ') || lower.startsWith('why ') || lower.startsWith('do you ') || lower.startsWith('can you ')) {
      return _pick([
        'Great question! I love that you\'re curious. Rather than me giving you the answer, what do YOU think? Express your own view first — that\'s the best English practice!',
        'That\'s a thought-provoking question! Before I respond, tell me what you already know or think about this topic.',
        'Excellent question! Let\'s explore it together. What\'s your initial reaction when you think about this?',
      ]);
    }

    // Describing something
    if (_matches(lower, ['it is', 'it was', 'there is', 'there are', 'i saw', 'i went', 'i visited', 'i met', 'i had', 'i ate'])) {
      return _pick([
        'Great description! Can you add more detail? Try using at least three descriptive words (adjectives or adverbs) to paint a clearer picture.',
        'Interesting! What were your feelings about this experience? Expressing emotions in English is an important skill.',
        'That\'s vivid! If you were describing this to someone who\'s never experienced it, what would you say to make them understand exactly what it was like?',
        'Nice sharing! What surprised you most about this? Sometimes the unexpected parts make the best stories.',
      ]);
    }

    return _pick([
      'That\'s interesting! Tell me more — I\'d love to hear your thoughts in more detail. The more you write, the better your English gets!',
      'I see! And how does that make you feel? Expressing emotions and opinions is key to natural English conversation.',
      'Fascinating point! Can you explain a bit more? Try to express the same idea using different words — it\'s great vocabulary practice.',
      'Interesting! Let me ask you something to explore this further: do you think this is the same in other cultures, or is it specific to your experience?',
      'Great contribution to the conversation! Now let me challenge you slightly: can you argue the opposite point of view, even if you don\'t believe it? This is excellent language practice!',
    ]);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static bool _matches(String lower, List<String> keywords) =>
      keywords.any((k) => lower.contains(k));

  static bool _isGreeting(String lower) =>
      RegExp(r'^(hi|hello|hey|good morning|good evening|good afternoon|howdy|greetings|what\'s up|sup)').hasMatch(lower);

  static bool _isGoodbye(String lower) =>
      _matches(lower, ['goodbye', 'bye', 'see you', 'take care', 'good night', 'cya', 'farewell']);

  static bool _isThankYou(String lower) =>
      _matches(lower, ['thank', 'thanks', 'thank you', 'cheers', 'appreciate']);

  static bool _looksLikeEnglish(String lower) {
    const commonWords = ['the', 'a', 'an', 'is', 'are', 'was', 'i', 'you', 'he', 'she', 'it', 'we', 'they', 'my', 'your', 'have', 'has', 'do', 'does', 'can', 'will', 'would', 'like', 'go', 'good', 'very', 'yes', 'no'];
    return commonWords.any((w) => lower.split(RegExp(r'\s+')).contains(w));
  }

  static String _pick(List<String> options) => options[_rng.nextInt(options.length)];
}
