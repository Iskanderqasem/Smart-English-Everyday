import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final storage = sl<StorageService>();
    final data = storage.getUserData();
    if (data != null) setState(() => _user = UserModel.fromJson(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _HomeTab(),
          _LearnTab(),
          _PracticeTab(),
          _ProgressTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Learn'),
          NavigationDestination(icon: Icon(Icons.sports_esports_outlined), selectedIcon: Icon(Icons.sports_esports), label: 'Practice'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ─── HOME TAB ───────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning!';
    if (h < 17) return 'Good afternoon!';
    return 'Good evening!';
  }

  @override
  Widget build(BuildContext context) {
    UserModel? user;
    try {
      final data = sl<StorageService>().getUserData();
      if (data != null) user = UserModel.fromJson(data);
    } catch (_) {}

    final firstName = user?.fullName.split(' ').first ?? 'Student';
    final initials = () {
      final parts = (user?.fullName ?? '').trim().split(' ');
      if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      return parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'S';
    }();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.primary,
          expandedHeight: 60,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting(), style: const TextStyle(fontSize: 13, color: Colors.white70)),
              Text('Hi, $firstName!', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () {},
                ),
                Positioned(
                  right: 8, top: 8,
                  child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => context.go('/profile'),
                child: CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStreakAndXP(user),
                const SizedBox(height: 20),
                _buildDailyWord(context),
                const SizedBox(height: 20),
                _buildContinueLearning(context),
                const SizedBox(height: 20),
                _buildQuickAccess(context),
                const SizedBox(height: 20),
                _buildWeeklyProgress(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakAndXP(UserModel? user) {
    final streak = user?.streakDays.toString() ?? '0';
    final xp = user != null ? _formatXp(user.totalXp) : '0';
    final level = user?.cefrLevel ?? 'A1';
    return Row(
      children: [
        Expanded(child: _StatCard(icon: Icons.local_fire_department, value: streak, label: 'Day Streak', color: Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(icon: Icons.star, value: xp, label: 'XP Points', color: Colors.amber)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(icon: Icons.emoji_events, value: level, label: 'CEFR Level', color: AppColors.primary)),
      ],
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k';
    return xp.toString();
  }

  Widget _buildDailyWord(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Word of the Day', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                child: const Text('Tap to quiz', style: TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Perseverance', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const Text('/p-er-suh-VEER-ens/', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          const Text('noun - Continued effort despite difficulty', style: TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 8),
          const Text('"Her perseverance finally paid off."', style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.volume_up, color: Colors.white), onPressed: () {}),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Text('See all words', style: TextStyle(color: Colors.white)),
                label: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearning(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Continue Learning', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 12),
        _LessonCard(
          title: 'Present Perfect Tense',
          subtitle: 'Level 5 - Grammar',
          progress: 0.6,
          icon: Icons.menu_book,
          color: Colors.blue,
          onTap: () => context.push('/lessons'),
        ),
        const SizedBox(height: 8),
        _LessonCard(
          title: 'Business Vocabulary',
          subtitle: 'Level 8 - Vocabulary',
          progress: 0.3,
          icon: Icons.work_outline,
          color: Colors.purple,
          onTap: () => context.push('/vocabulary'),
        ),
      ],
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    final items = [
      {'icon': Icons.headphones, 'label': 'Listening', 'route': '/listening', 'color': Colors.blue},
      {'icon': Icons.mic, 'label': 'Speaking', 'route': '/speaking', 'color': Colors.green},
      {'icon': Icons.edit, 'label': 'Writing', 'route': '/writing', 'color': Colors.orange},
      {'icon': Icons.chrome_reader_mode, 'label': 'Reading', 'route': '/reading', 'color': Colors.red},
      {'icon': Icons.spellcheck, 'label': 'Grammar', 'route': '/grammar', 'color': Colors.purple},
      {'icon': Icons.text_fields, 'label': 'Vocab', 'route': '/vocabulary', 'color': Colors.teal},
      {'icon': Icons.sports_esports, 'label': 'Games', 'route': '/games', 'color': Colors.pink},
      {'icon': Icons.smart_toy, 'label': 'AI Tutor', 'route': '/ai-teacher', 'color': AppColors.primary},
      {'icon': Icons.school, 'label': 'Assessment', 'route': '/assessment', 'color': Colors.amber},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Access', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 5 : 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: items.map((item) => _QuickAccessItem(
            icon: item['icon'] as IconData,
            label: item['label'] as String,
            color: item['color'] as Color,
            onTap: () => context.push(item['route'] as String),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('This Week', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: BarChart(BarChartData(
              barGroups: List.generate(7, (i) => BarChartGroupData(
                x: i,
                barRods: [BarChartRodData(
                  toY: [20, 45, 30, 80, 55, 90, 40][i].toDouble(),
                  color: AppColors.primary,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                )],
              )),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) => Text(['M','T','W','T','F','S','S'][v.toInt()],
                      style: const TextStyle(fontSize: 11, color: Colors.black54)),
                )),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
            )),
          ),
        ],
      ),
    );
  }
}

// ─── SHARED WIDGETS ─────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final String title, subtitle;
  final double progress;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _LessonCard({required this.title, required this.subtitle, required this.progress, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(width: 48, height: 48,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation(color), borderRadius: BorderRadius.circular(4)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessItem({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black87), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── LEARN TAB ──────────────────────────────────────────────────────────────

class _LearnTab extends StatelessWidget {
  const _LearnTab();

  @override
  Widget build(BuildContext context) {
    final levels = ['Alphabet & Phonics', 'Simple Sentences', 'Beginner Conversation', 'Elementary', 'Intermediate', 'Upper Intermediate', 'Advanced', 'Business English', 'Academic English', 'IELTS / TOEFL Prep'];
    final icons = [Icons.abc, Icons.chat_bubble_outline, Icons.record_voice_over, Icons.menu_book, Icons.school, Icons.auto_stories, Icons.emoji_events, Icons.business_center, Icons.science, Icons.assignment];
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.red, Colors.indigo, Colors.brown, Colors.cyan, Colors.amber];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Lessons', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.primary, iconTheme: const IconThemeData(color: Colors.white)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(width: 52, height: 52,
              decoration: BoxDecoration(color: colors[i].withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
              child: Icon(icons[i], color: colors[i], size: 28)),
            title: Text('Level ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(levels[i], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: i == 0 ? 1.0 : i == 1 ? 0.7 : i == 2 ? 0.3 : 0,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(colors[i]),
                borderRadius: BorderRadius.circular(4),
              ),
            ]),
            trailing: i <= 2 ? const Icon(Icons.lock_open, color: Colors.green) : const Icon(Icons.lock, color: Colors.grey),
            onTap: i <= 2 ? () => context.push('/lessons') : null,
          ),
        ),
      ),
    );
  }
}

// ─── PRACTICE TAB ───────────────────────────────────────────────────────────

class _PracticeTab extends StatelessWidget {
  const _PracticeTab();

  @override
  Widget build(BuildContext context) {
    final practices = [
      {'title': 'Speaking Practice', 'icon': Icons.mic, 'color': Colors.green, 'route': '/speaking', 'desc': 'Improve your accent & fluency'},
      {'title': 'Reading Aloud', 'icon': Icons.chrome_reader_mode, 'color': Colors.blue, 'route': '/reading', 'desc': 'Read & get pronunciation score'},
      {'title': 'Writing Workshop', 'icon': Icons.edit, 'color': Colors.orange, 'route': '/writing', 'desc': 'AI-powered writing coach'},
      {'title': 'Listening Skills', 'icon': Icons.headphones, 'color': Colors.purple, 'route': '/listening', 'desc': 'Train your ear with native audio'},
      {'title': 'Word Games', 'icon': Icons.sports_esports, 'color': Colors.pink, 'route': '/games', 'desc': 'Learn while playing'},
      {'title': 'AI Conversation', 'icon': Icons.smart_toy, 'color': AppColors.primary, 'route': '/chatbot', 'desc': 'Chat with your AI tutor'},
    ];
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Practice', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.primary, iconTheme: const IconThemeData(color: Colors.white)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: practices.length,
        itemBuilder: (context, i) {
          final p = practices[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(width: 52, height: 52,
                decoration: BoxDecoration(color: (p['color'] as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(p['icon'] as IconData, color: p['color'] as Color, size: 26)),
              title: Text(p['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              subtitle: Text(p['desc'] as String, style: const TextStyle(color: Colors.grey)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () => context.push(p['route'] as String),
            ),
          );
        },
      ),
    );
  }
}

// ─── PROGRESS TAB ───────────────────────────────────────────────────────────

class _ProgressTab extends StatefulWidget {
  const _ProgressTab();

  @override
  State<_ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<_ProgressTab> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    try {
      final data = sl<StorageService>().getUserData();
      if (data != null) _user = UserModel.fromJson(data);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final level = _user?.cefrLevel ?? 'A1';
    final levelDesc = _levelDescription(level);
    final streak = _user?.streakDays ?? 0;
    final ielts = _user?.ieltsEstimate;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('My Progress', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.primary, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ProgressCard('CEFR Level', '$level - $levelDesc', Icons.star, Colors.amber),
            const SizedBox(height: 12),
            if (ielts != null) ...[
              _ProgressCard('IELTS Estimate', '${ielts.toStringAsFixed(1)}', Icons.school, Colors.blue),
              const SizedBox(height: 12),
            ],
            _ProgressCard('Current Streak', '$streak day${streak == 1 ? '' : 's'}', Icons.local_fire_department, Colors.orange),
            const SizedBox(height: 12),
            _ProgressCard('Total XP', '${_user?.totalXp ?? 0} points', Icons.military_tech, Colors.purple),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/progress'),
              icon: const Icon(Icons.bar_chart),
              label: const Text('View Detailed Report'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }

  String _levelDescription(String level) {
    switch (level) {
      case 'A1': return 'Beginner';
      case 'A2': return 'Elementary';
      case 'B1': return 'Intermediate';
      case 'B2': return 'Upper Intermediate';
      case 'C1': return 'Advanced';
      case 'C2': return 'Proficient';
      default: return 'Beginner';
    }
  }
}

class _ProgressCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _ProgressCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
      child: Row(
        children: [
          Container(width: 48, height: 48,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color)),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
            ],
          )),
        ],
      ),
    );
  }
}

// ─── PROFILE TAB ────────────────────────────────────────────────────────────

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    try {
      final data = sl<StorageService>().getUserData();
      if (data != null) _user = UserModel.fromJson(data);
    } catch (_) {}
  }

  String get _displayName => _user?.fullName.isNotEmpty == true ? _user!.fullName : 'Student';
  String get _email => _user?.email ?? '';
  String get _initials {
    final parts = _displayName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'S';
  }

  void _signOut() {
    context.read<AuthBloc>().add(const AuthLogoutRequested());
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Profile', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.primary, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
              ),
              child: Column(children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white24,
                  child: Text(_initials, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 12),
                Text(_displayName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                if (_email.isNotEmpty) Text(_email, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
              ]),
            ),
            const SizedBox(height: 8),
            _ProfileTile(Icons.person, 'Full Profile', () => context.push('/profile')),
            _ProfileTile(Icons.bar_chart, 'My Progress', () => context.push('/progress')),
            _ProfileTile(Icons.emoji_events, 'Achievements', () {}),
            _ProfileTile(Icons.card_membership, 'Certificates', () {}),
            _ProfileTile(Icons.help_outline, 'Help & Support', () {}),
            _ProfileTile(Icons.logout, 'Sign Out', _signOut, color: Colors.red),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _ProfileTile(this.icon, this.label, this.onTap, {this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.primary),
        title: Text(label, style: TextStyle(color: color ?? Colors.black87)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
