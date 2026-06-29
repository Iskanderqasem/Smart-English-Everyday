import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AiTeacherPage extends StatefulWidget {
  const AiTeacherPage({super.key});
  @override
  State<AiTeacherPage> createState() => _AiTeacherPageState();
}

class _AiTeacherPageState extends State<AiTeacherPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isTyping = false;

  final List<Map<String, dynamic>> _messages = [
    {'role': 'ai', 'text': 'Hello! I\'m your AI English Teacher 👋 I\'m here 24/7 to help you with grammar, vocabulary, pronunciation, writing, speaking, and anything else you need. What would you like to learn today?'},
  ];

  final _quickQuestions = [
    'Explain the Present Perfect tense',
    'What is the difference between "affect" and "effect"?',
    'How do I use phrasal verbs?',
    'Correct my grammar: "She don\'t like apples"',
    'Give me 5 business idioms',
    'How to improve my accent?',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(18)),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 20)))),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI English Teacher', style: TextStyle(color: Colors.white, fontSize: 16)),
            Text('Always available', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ]),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) return _buildTypingIndicator();
                final m = _messages[i];
                return _ChatBubble(isAi: m['role'] == 'ai', text: m['text']);
              },
            ),
          ),
          if (_messages.length == 1) _buildQuickQuestions(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildQuickQuestions() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickQuestions.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _sendMessage(_quickQuestions[i]),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withOpacity(0.3))),
            child: Text(_quickQuestions[i], style: const TextStyle(color: AppColors.primary, fontSize: 13)),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4))]),
      child: Row(children: [
        IconButton(icon: const Icon(Icons.mic_outlined, color: AppColors.primary), onPressed: () {}),
        Expanded(
          child: TextField(
            controller: _msgCtrl,
            decoration: InputDecoration(
              hintText: 'Ask your teacher anything...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onSubmitted: (v) { if (v.isNotEmpty) _sendMessage(v); },
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () { if (_msgCtrl.text.isNotEmpty) _sendMessage(_msgCtrl.text); },
          child: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(22)),
            child: const Icon(Icons.send, color: Colors.white, size: 20)),
        ),
      ]),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(right: 60, bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(18).copyWith(bottomLeft: Radius.zero)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          ...List.generate(3, (i) => Container(width: 8, height: 8, margin: EdgeInsets.only(right: i < 2 ? 4 : 0), decoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle))),
        ]),
      ),
    );
  }

  void _sendMessage(String text) async {
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _msgCtrl.clear();
      _isTyping = true;
    });
    _scrollToBottom();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add({'role': 'ai', 'text': _generateResponse(text)});
    });
    _scrollToBottom();
  }

  String _generateResponse(String q) {
    final lc = q.toLowerCase();

    // Grammar tenses
    if (lc.contains('present perfect')) return 'The Present Perfect tense has three main uses:\n\n1️⃣ Actions at an unspecified past time:\n"I have visited Paris."\n\n2️⃣ Actions that started in the past and continue now:\n"She has lived here for 5 years."\n\n3️⃣ Recent actions with present relevance:\n"He has just finished his homework."\n\nStructure: Subject + have/has + past participle\n\nCommon signal words: already, yet, just, ever, never, for, since 💡';
    if (lc.contains('past simple') || lc.contains('simple past')) return 'The Past Simple tense describes:\n\n✅ Completed actions at a specific time in the past:\n"I visited Paris last year."\n\n✅ A sequence of past actions:\n"She woke up, had breakfast, and left."\n\nStructure: Subject + verb (past form)\nRegular: verb + -ed (walked, talked)\nIrregular: go→went, buy→bought, see→saw\n\nSignal words: yesterday, last week, in 2020, ago 🕐';
    if (lc.contains('present continuous') || lc.contains('present progressive')) return 'The Present Continuous is used for:\n\n1️⃣ Actions happening RIGHT NOW:\n"She is studying at the moment."\n\n2️⃣ Temporary situations:\n"I am staying with my sister this week."\n\n3️⃣ Future plans:\n"We are meeting at 7pm tonight."\n\nStructure: Subject + am/is/are + verb-ing\n\n⚠️ Stative verbs (know, want, like, love) do NOT use continuous form! ';
    if (lc.contains('future') || lc.contains('will') && lc.contains('going to')) return 'English has several ways to talk about the future:\n\n🔵 will — spontaneous decisions, predictions:\n"I will call you later." / "It will rain tomorrow."\n\n🟢 going to — plans and intentions:\n"I am going to study medicine."\n\n🟡 Present Continuous — fixed arrangements:\n"We are flying to Dubai on Friday."\n\n🔴 Present Simple — timetables:\n"The train leaves at 9am."\n\nChoose based on how planned or certain the future event is! 📅';
    if (lc.contains('conditional') || lc.contains('if clause')) return 'English conditionals:\n\n0️⃣ Zero — general truths:\n"If you heat water to 100°C, it boils."\n\n1️⃣ First — real / likely future:\n"If it rains, I will stay home."\n\n2️⃣ Second — unreal / hypothetical:\n"If I won the lottery, I would travel the world."\n\n3️⃣ Third — past regrets / impossible:\n"If I had studied harder, I would have passed."\n\nTip: The 2nd conditional uses WERE for all subjects:\n"If I were you, I would apologise." ✨';
    if (lc.contains('passive') || lc.contains('passive voice')) return 'The Passive Voice focuses on the ACTION, not the doer:\n\nActive: "The chef cooked the meal."\nPassive: "The meal was cooked by the chef."\n\nStructure: Subject + be (correct tense) + past participle\n\nExamples by tense:\n• Present: "English is spoken worldwide."\n• Past: "The letter was written yesterday."\n• Future: "The report will be submitted tomorrow."\n• Perfect: "The project has been completed."\n\nUse passive when the doer is unknown, unimportant, or obvious 📝';

    // Grammar topics
    if (lc.contains('article') || (lc.contains('a ') && lc.contains('the '))) return 'Articles in English — A, AN, THE:\n\n🔵 A / AN (indefinite) — non-specific things:\n"I saw a dog." (any dog)\n"She is an engineer." (any engineer)\nUse AN before vowel sounds: an apple, an hour\n\n🟢 THE (definite) — specific or unique things:\n"The dog I saw was huge." (that specific dog)\n"The sun rises in the east." (unique object)\n\n⚠️ No article for general plural nouns:\n"Dogs are friendly." (dogs in general)\n"I love music." (music in general) 🎵';
    if (lc.contains('preposition')) return 'Common English Prepositions:\n\n📍 Place: in (inside), on (surface), at (specific point)\n"in the room" / "on the table" / "at the door"\n\n⏰ Time: in (months/years), on (days), at (times)\n"in January" / "on Monday" / "at 3pm"\n\n🔄 Movement: to, into, onto, through, across, along\n"Walk to the shop" / "Jump into the pool"\n\n💡 Tricky ones:\n• depend ON something\n• interested IN something\n• good AT something\n• different FROM something\n• married TO someone 😊';
    if (lc.contains('phrasal verb')) return 'Phrasal Verbs = verb + particle (preposition/adverb)\n\nCommon ones:\n📌 give up = stop trying: "Don\'t give up!"\n📌 find out = discover: "I found out the truth."\n📌 look up = search for: "Look it up in the dictionary."\n📌 carry on = continue: "Carry on with your work."\n📌 run out of = have none left: "We ran out of milk."\n📌 put off = postpone: "Don\'t put it off until tomorrow."\n📌 look forward to = be excited about: "I look forward to meeting you."\n\n⚠️ Separable vs inseparable:\n"Turn the TV off" OR "Turn off the TV" ✅\n"Look after the kids" (NOT "look the kids after") ✅';
    if (lc.contains('modal') || lc.contains('must') || lc.contains('should') || lc.contains('could') || lc.contains('might')) return 'Modal Verbs and their meanings:\n\n💪 must — strong obligation / logical certainty:\n"You must wear a seatbelt." / "She must be tired."\n\n🟡 should — advice / recommendation:\n"You should see a doctor."\n\n🟢 can / could — ability / possibility:\n"I can swim." / "Could you help me?"\n\n🔵 may / might — possibility:\n"It might rain later." / "May I come in?"\n\n🔴 have to — external obligation:\n"I have to work on Saturday."\n\n⚠️ Modal verbs are ALWAYS followed by the infinitive (without to):\n"She can swim." (NOT "She can to swim.") 🏊';

    // Vocabulary topics
    if (lc.contains('affect') && lc.contains('effect')) return '"Affect" vs "Effect" — commonly confused!\n\n🔵 Affect (verb) = to influence something:\n"The noise affected my sleep."\n\n🟢 Effect (noun) = the result:\n"The effect of noise was poor sleep."\n\n💡 Memory trick: "RAVEN"\nRemember: Affect=Verb, Effect=Noun\n\n⚠️ Exceptions:\n• Effect as a verb = to bring about:\n"The new law effected real change." (rare/formal)\n• Affect as a noun = emotion (psychology term):\n"He showed little affect." (very specific use) 📚';
    if (lc.contains('since') && lc.contains('for')) return '"Since" vs "For" with Perfect tenses:\n\n⏰ FOR — a duration (how long):\n"I have lived here for 3 years."\n"She has been studying for 2 hours."\n\n📅 SINCE — a starting point (when it began):\n"I have lived here since 2021."\n"She has been studying since 9am."\n\n💡 Quick test:\nCan you ask "How long?" → use FOR\nCan you state "when it started?" → use SINCE\n\n✏️ Practice: I haven't seen him ___ Monday. (since)\nI have known her ___ five years. (for) 😊';
    if (lc.contains('make') && lc.contains('do')) return '"Make" vs "Do" — fixed collocations:\n\n🔨 MAKE — creating, producing, constructing:\nmake a mistake, make a decision, make a plan\nmake friends, make money, make a phone call\nmake breakfast, make a noise, make progress\n\n✅ DO — tasks, activities, work:\ndo homework, do exercise, do the dishes\ndo business, do your best, do research\ndo someone a favour, do harm\n\n💡 Tip: When unsure, remember:\nMAKE = you produce something new\nDO = you perform/complete an action\n\n📝 Common errors:\n✗ "I did a mistake" → ✅ "I made a mistake"\n✗ "She made her homework" → ✅ "She did her homework"';
    if (lc.contains('vocabulary') || lc.contains('words') && lc.contains('learn')) return 'Best ways to build your vocabulary:\n\n📖 1. Learn words IN CONTEXT — not isolated lists\nRead articles, watch shows, listen to podcasts\n\n🗂️ 2. Use SPACED REPETITION\nReview new words after 1 day, 3 days, 1 week, 1 month\n\n🔗 3. Learn word FAMILIES\nfriend → friendly → friendship → unfriendly → befriend\n\n🖊️ 4. WRITE sentences using new words immediately\n\n🎯 5. Aim for 10–15 new words per day\n\n📱 6. Label objects around your home in English\n\n💬 7. USE words in conversation — that\'s how they stick!\n\nFocus on high-frequency words first (the most common 2,000 words cover 95% of everyday English) ✨';

    // Skills
    if (lc.contains('reading') || lc.contains('improve') && lc.contains('read')) return 'How to improve your English reading:\n\n📚 Start at YOUR level — don\'t struggle with texts that are too hard\n\n🎯 Active reading strategies:\n1. Preview headings before you read\n2. Guess meaning from context before using a dictionary\n3. Read the same text TWICE — first for general meaning, then for details\n\n📰 Best materials by level:\nA1-A2: Graded readers, simple news (BBC Learning English)\nB1-B2: Real news articles, short stories\nC1-C2: Novels, academic articles, opinion pieces\n\n⏰ Habit: Read 15–20 minutes EVERY DAY\nConsistency beats long sessions once a week!\n\n🔑 Focus on: text structure, main idea, supporting details, writer\'s purpose 📖';
    if (lc.contains('writing') || lc.contains('improve') && lc.contains('writ')) return 'How to improve your English writing:\n\n📝 Key principles:\n1. Plan before you write — outline your main points\n2. One idea per paragraph\n3. Use topic sentences to start each paragraph\n4. Connect ideas with linking words:\n   Adding: furthermore, in addition, moreover\n   Contrasting: however, although, on the other hand\n   Concluding: therefore, as a result, consequently\n\n✍️ Practice ideas:\n• Keep a daily journal in English\n• Write emails or messages in English\n• Summarise articles you read\n• Use the Writing Practice section in this app!\n\n🔍 Always proofread:\nCheck: spelling, punctuation, subject-verb agreement, tenses\n\n💡 Quality > Quantity — one well-written paragraph is better than three rushed ones 📄';
    if (lc.contains('speaking') || lc.contains('accent') || lc.contains('pronunciation') || lc.contains('fluency')) return 'How to improve your English speaking:\n\n🗣️ Fluency tips:\n1. Think in English — don\'t translate from your first language\n2. Speak DAILY — even to yourself (self-talk practice!)\n3. Use filler phrases: "Let me think...", "That\'s a good point..."\n4. Don\'t stop to correct every mistake — flow matters more\n\n🎯 Pronunciation:\n• Listen and repeat (shadowing technique)\n• Record yourself and compare to native speakers\n• Focus on word stress — EnGLISH, not ENglish\n• Learn the 44 English phoneme sounds\n\n📺 Resources:\nYouTube: BBC Learning English, English with Lucy\nPodcasts: 6 Minute English (BBC)\n\n🎤 Use the Speaking Practice section in this app to practise and get feedback! 💬';
    if (lc.contains('listen') || lc.contains('listening')) return 'How to improve your English listening:\n\n👂 Why it\'s hard: native speakers speak fast, use contractions, and reduce sounds ("going to" → "gonna")\n\n📻 Practice strategies:\n1. Listen ACTIVELY — take notes, predict what comes next\n2. Watch with subtitles → then without\n3. Listen to the same clip multiple times\n4. Expose yourself to DIFFERENT accents (British, American, Australian)\n\n🎧 Best resources:\n• BBC Learning English (bbc.co.uk/learningenglish)\n• TED Talks (with transcripts!)\n• Podcasts: 6 Minute English, The English We Speak\n• YouTube: Real English channels\n\n⏰ Daily habit: 15 minutes of focused listening + 30+ minutes of passive listening (background)\n\n💡 Use the Listening section in this app — it has British, American, Australian and more accents! 🌍';

    // Corrections
    if (lc.contains('correct') || lc.contains('grammar') && lc.contains('check')) {
      // Look for common patterns to correct in the user's message
      if (lc.contains("don't like") && lc.contains("she")) return 'I can see the error:\n\n❌ "She don\'t like apples"\n✅ "She doesn\'t like apples"\n\nRule: With he/she/it in the present simple, use DOESN\'T (not don\'t):\n• I don\'t / You don\'t / We don\'t / They don\'t\n• He DOESN\'T / She DOESN\'T / It DOESN\'T\n\nMore examples:\n✅ "He doesn\'t work on weekends."\n✅ "She doesn\'t know the answer."\n✅ "It doesn\'t matter." 😊';
      return 'To correct your sentence, please type it in the chat and I\'ll identify any errors and explain the rules.\n\nCommon grammar areas to check:\n• Subject-verb agreement (he/she/it + s)\n• Tense consistency\n• Article usage (a/an/the)\n• Prepositions (in/on/at)\n• Word order\n• Singular vs plural nouns\n\nJust type: "Please correct: [your sentence]" 📝';
    }

    // Business / idioms
    if (lc.contains('idiom') || lc.contains('business english')) return '5 Essential Business English Idioms:\n\n💼 1. "Think outside the box"\n= be creative, find unusual solutions\n"We need to think outside the box on this project."\n\n🤝 2. "Touch base"\n= make contact, check in with someone\n"Let\'s touch base next week to discuss progress."\n\n📊 3. "Get the ball rolling"\n= start something, begin a process\n"Who wants to get the ball rolling on the new campaign?"\n\n⏰ 4. "On the same page"\n= in agreement, have the same understanding\n"Before we proceed, let\'s make sure we\'re all on the same page."\n\n🎯 5. "Hit the ground running"\n= start something quickly and with energy\n"We need someone who can hit the ground running from day one." 🚀';
    if (lc.contains('common mistake') || lc.contains('typical mistake')) return 'Top 10 Common English Mistakes:\n\n1. ❌ "I am agree" → ✅ "I agree"\n2. ❌ "She don\'t like" → ✅ "She doesn\'t like"\n3. ❌ "Peoples" → ✅ "People" (no plural s)\n4. ❌ "Informations" → ✅ "Information" (uncountable)\n5. ❌ "I am boring" → ✅ "I am bored" (feeling vs causing)\n6. ❌ "More better" → ✅ "Better"\n7. ❌ "Since 3 years" → ✅ "For 3 years"\n8. ❌ "I have 25 years" → ✅ "I am 25 years old"\n9. ❌ "She explained me" → ✅ "She explained to me"\n10. ❌ "According to my opinion" → ✅ "In my opinion"\n\nDo any of these apply to you? 😊';

    // Plan questions
    if (lc.contains('plan') && lc.contains('reading')) return 'Reading Improvement Plan — 4 weeks:\n\n📅 Week 1: Foundation\n• Read 1 short article daily (BBC Learning English)\n• Note 5 new words each day\n• Use the Reading section in this app (A2-B1 level)\n\n📅 Week 2: Speed\n• Increase to 2 articles per day\n• Time yourself — aim to improve pace\n• Practice skimming for main ideas\n\n📅 Week 3: Depth\n• Read 1 longer text weekly (500+ words)\n• Summarise each text in 3 sentences\n• Focus on text structure and argument\n\n📅 Week 4: Challenge\n• Read authentic English content (news, blogs)\n• Answer comprehension questions (use the app!)\n• Review all vocabulary from the month\n\n🎯 Goal: Read EVERY DAY — even 15 minutes makes a huge difference over 4 weeks! 📖';

    // Fallback — more helpful than before
    final topic = q.length > 60 ? '${q.substring(0, 57)}...' : q;
    return 'Good question about: "$topic"\n\nHere are some tips I can help you with in this chat:\n\n📚 Grammar: tenses, articles, prepositions, modals, passive voice, conditionals\n🔤 Vocabulary: word differences, idioms, phrasal verbs, collocations\n🗣️ Speaking: fluency, pronunciation, accent tips\n✍️ Writing: structure, linking words, paragraph writing\n👂 Listening: strategies and resources\n✅ Corrections: paste any sentence and ask me to correct it\n\nTry asking something like:\n• "Explain the past perfect tense"\n• "What is the difference between make and do?"\n• "Please correct: She don\'t like coffee"\n• "Give me a plan to improve my speaking" 😊';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }
}

class _ChatBubble extends StatelessWidget {
  final bool isAi;
  final String text;
  const _ChatBubble({required this.isAi, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(right: isAi ? 60 : 0, left: isAi ? 0 : 60, bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isAi ? Colors.grey[100] : AppColors.primary,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomLeft: isAi ? Radius.zero : const Radius.circular(18),
            bottomRight: isAi ? const Radius.circular(18) : Radius.zero,
          ),
        ),
        child: Text(text, style: TextStyle(color: isAi ? Colors.black87 : Colors.white, fontSize: 14, height: 1.5)),
      ),
    );
  }
}
