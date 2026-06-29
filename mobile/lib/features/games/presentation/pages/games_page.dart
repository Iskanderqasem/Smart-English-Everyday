import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  // route: null = not yet implemented → shows "Coming Soon" snackbar
  static const _games = [
    {'title': 'Word Match',         'desc': 'Match words with meanings', 'icon': '🃏', 'color': Colors.blue,       'route': '/game/word-match'},
    {'title': 'Hangman',            'desc': 'Guess word letter by letter','icon': '🎯', 'color': Colors.red,        'route': '/game/hangman'},
    {'title': 'Word Search',        'desc': 'Find hidden words in grid',  'icon': '🔍', 'color': Colors.green,      'route': '/game/word-search'},
    {'title': 'Crossword',          'desc': 'Complete the crossword',     'icon': '✏️', 'color': Colors.purple,     'route': null},
    {'title': 'Fill the Blank',     'desc': 'Complete the sentences',     'icon': '📝', 'color': Colors.orange,     'route': null},
    {'title': 'Memory Cards',       'desc': 'Flip cards to find pairs',   'icon': '🧠', 'color': Colors.teal,       'route': null},
    {'title': 'Sentence Builder',   'desc': 'Arrange words into order',   'icon': '🔤', 'color': Colors.indigo,     'route': null},
    {'title': 'Vocabulary Race',    'desc': 'Answer fast to win!',        'icon': '🏃', 'color': Colors.pink,       'route': null},
    {'title': 'Speaking Challenge', 'desc': 'Speak & earn points',        'icon': '🎤', 'color': Colors.amber,      'route': null},
    {'title': 'Daily Challenge',    'desc': 'New challenge every day',    'icon': '⚡', 'color': Colors.deepOrange, 'route': null},
  ];

  void _onTap(BuildContext context, Object? route) {
    if (route is String) {
      context.push(route);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coming soon! This game is under construction.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games & Activities'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.leaderboard_outlined), onPressed: () {
            showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => const _LeaderboardSheet());
          }),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _DailyBanner(onPlay: () => _onTap(context, null))),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final g = _games[i];
                  final ready = g['route'] != null;
                  return _GameCard(
                    title: g['title'] as String,
                    desc: g['desc'] as String,
                    icon: g['icon'] as String,
                    color: (g['color'] as MaterialColor),
                    ready: ready,
                    onTap: () => _onTap(context, g['route']),
                  );
                },
                childCount: _games.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Daily Challenge Banner ───────────────────────────────────────────────────

class _DailyBanner extends StatelessWidget {
  final VoidCallback onPlay;
  const _DailyBanner({required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            const Text('⚡', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Daily Challenge',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 2),
                  Text('Complete today for 50 XP bonus!',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onPlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: const Size(60, 36),
              ),
              child: const Text('Play', style: TextStyle(fontSize: 13)),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Game Card ────────────────────────────────────────────────────────────────

class _GameCard extends StatelessWidget {
  final String title, desc, icon;
  final MaterialColor color;
  final bool ready;
  final VoidCallback onTap;

  const _GameCard({
    required this.title, required this.desc, required this.icon,
    required this.color, required this.ready, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
              ),
              if (!ready) Positioned(
                right: 0, top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(6)),
                  child: const Text('Soon', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ─── Leaderboard Sheet ────────────────────────────────────────────────────────

class _LeaderboardSheet extends StatelessWidget {
  const _LeaderboardSheet();

  @override
  Widget build(BuildContext context) {
    const players = [
      {'rank': '🥇', 'name': 'You', 'xp': '—', 'flag': '⭐'},
    ];
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      expand: false,
      builder: (_, ctrl) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const Text('🏆 Leaderboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Weekly XP ranking', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const Divider(height: 24),
          Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.emoji_events_outlined, size: 56, color: Colors.amber),
              const SizedBox(height: 12),
              const Text('Play games to appear on the leaderboard!',
                  style: TextStyle(color: Colors.grey, fontSize: 14), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Complete Word Match, Hangman, or Word Search\nto earn XP and rank up.',
                  style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
            ]),
          ),
        ]),
      ),
    );
  }
}
