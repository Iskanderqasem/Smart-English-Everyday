import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      {'title': 'Word Match', 'desc': 'Match words with their meanings', 'icon': '🃏', 'color': Colors.blue, 'route': '/games/word-match'},
      {'title': 'Hangman', 'desc': 'Guess the word letter by letter', 'icon': '🎯', 'color': Colors.red, 'route': '/games/hangman'},
      {'title': 'Word Search', 'desc': 'Find hidden words in the grid', 'icon': '🔍', 'color': Colors.green, 'route': '/games/word-search'},
      {'title': 'Crossword', 'desc': 'Complete the crossword puzzle', 'icon': '✏️', 'color': Colors.purple, 'route': '/games/crossword'},
      {'title': 'Fill the Blank', 'desc': 'Complete the sentences', 'icon': '📝', 'color': Colors.orange, 'route': '/games/fill-blank'},
      {'title': 'Memory Cards', 'desc': 'Flip cards to find pairs', 'icon': '🧠', 'color': Colors.teal, 'route': '/games/memory'},
      {'title': 'Sentence Builder', 'desc': 'Arrange words into sentences', 'icon': '🔤', 'color': Colors.indigo, 'route': '/games/sentence-builder'},
      {'title': 'Vocabulary Race', 'desc': 'Answer fast to win!', 'icon': '🏃', 'color': Colors.pink, 'route': '/games/vocab-race'},
      {'title': 'Speaking Challenge', 'desc': 'Speak & earn points', 'icon': '🎤', 'color': Colors.amber, 'route': '/games/speaking-challenge'},
      {'title': 'Daily Challenge', 'desc': 'New challenge every day', 'icon': '⚡', 'color': Colors.deepOrange, 'route': '/games/daily'},
    ];

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
      body: Column(
        children: [
          _buildDailyChallengeBanner(context),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1),
              itemCount: games.length,
              itemBuilder: (context, i) {
                final g = games[i];
                return _GameCard(
                  title: g['title'] as String,
                  desc: g['desc'] as String,
                  icon: g['icon'] as String,
                  color: g['color'] as Color,
                  onTap: () => context.push(g['route'] as String),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallengeBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Daily Challenge', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('Complete today\'s challenge for 50 XP bonus!', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ])),
          ElevatedButton(
            onPressed: () => context.push('/games/daily'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
            child: const Text('Play'),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title, desc, icon;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({required this.title, required this.desc, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 50, height: 50, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 26)))),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 2),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardSheet extends StatelessWidget {
  const _LeaderboardSheet();

  @override
  Widget build(BuildContext context) {
    final players = [
      {'rank': '🥇', 'name': 'Sarah M.', 'xp': '4,820', 'flag': '🇬🇧'},
      {'rank': '🥈', 'name': 'Ahmed K.', 'xp': '4,215', 'flag': '🇦🇪'},
      {'rank': '🥉', 'name': 'Maria L.', 'xp': '3,890', 'flag': '🇧🇷'},
      {'rank': '4', 'name': 'You', 'xp': '1,240', 'flag': '⭐'},
      {'rank': '5', 'name': 'John D.', 'xp': '980', 'flag': '🇺🇸'},
    ];
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const Text('🏆 Leaderboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('This Week', style: TextStyle(color: Colors.grey)),
          const Divider(),
          Expanded(
            child: ListView.builder(
              controller: ctrl,
              itemCount: players.length,
              itemBuilder: (_, i) {
                final p = players[i];
                return ListTile(
                  leading: Text(p['rank']!, style: const TextStyle(fontSize: 22)),
                  title: Text('${p['flag']} ${p['name']}', style: TextStyle(fontWeight: p['name'] == 'You' ? FontWeight.bold : FontWeight.normal, color: p['name'] == 'You' ? AppColors.primary : null)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text('${p['xp']} XP', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
