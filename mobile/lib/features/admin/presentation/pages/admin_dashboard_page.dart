import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

// ─── Mock Data ───────────────────────────────────────────────────────────────

class _Student {
  final int id;
  final String name, email, country, level, joinedDays;
  final int xp, streak, lessonsCompleted;
  final double readingScore, listeningScore, writingScore, grammarScore;
  final bool hasCertificate;
  final String status;

  const _Student({
    required this.id,
    required this.name,
    required this.email,
    required this.country,
    required this.level,
    required this.joinedDays,
    required this.xp,
    required this.streak,
    required this.lessonsCompleted,
    required this.readingScore,
    required this.listeningScore,
    required this.writingScore,
    required this.grammarScore,
    required this.hasCertificate,
    required this.status,
  });
}

final _mockStudents = [
  const _Student(id: 1, name: 'Sarah Mitchell', email: 'sarah@example.com', country: 'UK', level: 'C1', joinedDays: '120 days ago', xp: 4820, streak: 42, lessonsCompleted: 87, readingScore: 0.88, listeningScore: 0.84, writingScore: 0.79, grammarScore: 0.91, hasCertificate: true, status: 'Active'),
  const _Student(id: 2, name: 'Ahmed Khalil', email: 'ahmed@example.com', country: 'UAE', level: 'B2', joinedDays: '95 days ago', xp: 4215, streak: 28, lessonsCompleted: 72, readingScore: 0.75, listeningScore: 0.71, writingScore: 0.68, grammarScore: 0.80, hasCertificate: true, status: 'Active'),
  const _Student(id: 3, name: 'Maria Lopez', email: 'maria@example.com', country: 'Brazil', level: 'B1', joinedDays: '60 days ago', xp: 3890, streak: 15, lessonsCompleted: 54, readingScore: 0.65, listeningScore: 0.60, writingScore: 0.58, grammarScore: 0.70, hasCertificate: false, status: 'Active'),
  const _Student(id: 4, name: 'John Davis', email: 'john@example.com', country: 'USA', level: 'C1', joinedDays: '200 days ago', xp: 3650, streak: 7, lessonsCompleted: 91, readingScore: 0.82, listeningScore: 0.88, writingScore: 0.76, grammarScore: 0.85, hasCertificate: true, status: 'Active'),
  const _Student(id: 5, name: 'Lisa Chen', email: 'lisa@example.com', country: 'China', level: 'B2', joinedDays: '45 days ago', xp: 3420, streak: 31, lessonsCompleted: 48, readingScore: 0.78, listeningScore: 0.65, writingScore: 0.72, grammarScore: 0.82, hasCertificate: false, status: 'Active'),
  const _Student(id: 6, name: 'Fatima Al-Rashid', email: 'fatima@example.com', country: 'Saudi Arabia', level: 'A2', joinedDays: '30 days ago', xp: 1240, streak: 12, lessonsCompleted: 18, readingScore: 0.45, listeningScore: 0.40, writingScore: 0.38, grammarScore: 0.50, hasCertificate: false, status: 'Active'),
  const _Student(id: 7, name: 'Carlos Mendez', email: 'carlos@example.com', country: 'Mexico', level: 'B1', joinedDays: '75 days ago', xp: 2800, streak: 0, lessonsCompleted: 40, readingScore: 0.62, listeningScore: 0.55, writingScore: 0.60, grammarScore: 0.65, hasCertificate: false, status: 'Inactive'),
  const _Student(id: 8, name: 'Emma Wilson', email: 'emma@example.com', country: 'Australia', level: 'C2', joinedDays: '300 days ago', xp: 9100, streak: 89, lessonsCompleted: 145, readingScore: 0.96, listeningScore: 0.94, writingScore: 0.91, grammarScore: 0.97, hasCertificate: true, status: 'Active'),
];

// ─── Main Page ───────────────────────────────────────────────────────────────

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _nav = 0;
  _Student? _selectedStudent;

  static const _navColor = Color(0xFF0D1B4B);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: _navColor,
        foregroundColor: Colors.white,
        title: Row(children: [
          const Icon(Icons.admin_panel_settings, size: 22),
          const SizedBox(width: 8),
          const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: CircleAvatar(backgroundColor: Colors.white24, radius: 16, child: Text('A', style: TextStyle(color: Colors.white, fontSize: 14))),
          ),
          TextButton.icon(
            onPressed: () => context.go('/admin-login'),
            icon: const Icon(Icons.logout, color: Colors.white70, size: 18),
            label: const Text('Logout', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
      body: Row(
        children: [
          if (wide) _buildSidebar(),
          Expanded(
            child: _selectedStudent != null
                ? _StudentDetailView(
                    student: _selectedStudent!,
                    onBack: () => setState(() => _selectedStudent = null),
                  )
                : IndexedStack(
                    index: _nav,
                    children: [
                      _DashboardTab(onViewStudent: (s) => setState(() { _selectedStudent = s; _nav = 1; })),
                      _StudentsTab(onViewStudent: (s) => setState(() => _selectedStudent = s)),
                      _CertificatesTab(),
                      _AnalyticsTab(),
                      _ReportsTab(),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: wide ? null : NavigationBar(
        backgroundColor: _navColor,
        indicatorColor: Colors.white24,
        selectedIndex: _nav,
        onDestinationSelected: (i) => setState(() { _nav = i; _selectedStudent = null; }),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined, color: Colors.white54), selectedIcon: Icon(Icons.dashboard, color: Colors.white), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.people_outlined, color: Colors.white54), selectedIcon: Icon(Icons.people, color: Colors.white), label: 'Students'),
          NavigationDestination(icon: Icon(Icons.card_membership_outlined, color: Colors.white54), selectedIcon: Icon(Icons.card_membership, color: Colors.white), label: 'Certs'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined, color: Colors.white54), selectedIcon: Icon(Icons.analytics, color: Colors.white), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.description_outlined, color: Colors.white54), selectedIcon: Icon(Icons.description, color: Colors.white), label: 'Reports'),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final items = [
      (Icons.dashboard, 'Dashboard'),
      (Icons.people, 'Students'),
      (Icons.card_membership, 'Certificates'),
      (Icons.analytics, 'Analytics'),
      (Icons.description, 'Reports'),
    ];
    return Container(
      width: 210,
      color: const Color(0xFF0D1B4B),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('NAVIGATION', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2)),
          ),
          const SizedBox(height: 8),
          ...items.asMap().entries.map((e) {
            final selected = _nav == e.key && _selectedStudent == null;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: ListTile(
                dense: true,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                selected: selected,
                selectedTileColor: Colors.white12,
                leading: Icon(e.value.$1, color: selected ? Colors.white : Colors.white38, size: 20),
                title: Text(e.value.$2, style: TextStyle(color: selected ? Colors.white : Colors.white54, fontSize: 14)),
                onTap: () => setState(() { _nav = e.key; _selectedStudent = null; }),
              ),
            );
          }),
          const Spacer(),
          const Divider(color: Colors.white12),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ListTile(
              dense: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: const Icon(Icons.logout, color: Colors.white38, size: 20),
              title: const Text('Logout', style: TextStyle(color: Colors.white54, fontSize: 14)),
              onTap: () => context.go('/admin-login'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Dashboard Tab ────────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  final void Function(_Student) onViewStudent;
  const _DashboardTab({required this.onViewStudent});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const Text('Platform statistics at a glance', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              _KpiCard('Total Students', '${_mockStudents.length}', 'Registered users', Icons.people, Colors.blue),
              _KpiCard('Active Today', '${_mockStudents.where((s) => s.status == 'Active').length}', 'Currently active', Icons.trending_up, Colors.green),
              _KpiCard('Certificates Issued', '${_mockStudents.where((s) => s.hasCertificate).length}', 'Completed students', Icons.card_membership, Colors.orange),
              _KpiCard('Avg Level', 'B1+', 'Platform average', Icons.school, Colors.purple),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Top Students', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          ...List.generate(5, (i) {
            final s = _mockStudents[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: [Colors.amber, Colors.grey[400], Colors.brown[300], Colors.blue[200], Colors.green[200]][i],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white))),
                ),
                const SizedBox(width: 12),
                CircleAvatar(radius: 18, backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(s.name[0], style: const TextStyle(color: AppColors.primary))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                  Text('${s.country} - CEFR ${s.level}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ])),
                Text('${s.xp} XP', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                TextButton(onPressed: () => onViewStudent(s), child: const Text('View')),
              ]),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Students Tab ─────────────────────────────────────────────────────────────

class _StudentsTab extends StatefulWidget {
  final void Function(_Student) onViewStudent;
  const _StudentsTab({required this.onViewStudent});

  @override
  State<_StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<_StudentsTab> {
  String _search = '';
  String _levelFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final levels = ['All', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final filtered = _mockStudents.where((s) {
      final matchSearch = s.name.toLowerCase().contains(_search.toLowerCase()) ||
          s.email.toLowerCase().contains(_search.toLowerCase());
      final matchLevel = _levelFilter == 'All' || s.level == _levelFilter;
      return matchSearch && matchLevel;
    }).toList();

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: levels.map((l) {
                final sel = l == _levelFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(l),
                    selected: sel,
                    onSelected: (_) => setState(() => _levelFilter = l),
                    selectedColor: AppColors.primary.withOpacity(0.15),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              }).toList()),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Text('${filtered.length} students', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final s = filtered[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(s.name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('${s.country} - Joined ${s.joinedDays}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ]),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    _LevelBadge(s.level),
                    const SizedBox(width: 8),
                    if (s.hasCertificate)
                      const Icon(Icons.verified, color: Colors.green, size: 18),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: s.status == 'Active' ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(s.status, style: TextStyle(color: s.status == 'Active' ? Colors.green[700] : Colors.red[700], fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => widget.onViewStudent(s),
                      child: const Text('Details'),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Certificates Tab ─────────────────────────────────────────────────────────

class _CertificatesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final certified = _mockStudents.where((s) => s.hasCertificate).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Certificates', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text('Students who completed their level assessment', style: TextStyle(color: Colors.grey)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Icon(Icons.verified, color: Colors.green[700], size: 18),
                const SizedBox(width: 6),
                Text('${certified.length} Issued', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
              ]),
            ),
          ]),
          const SizedBox(height: 24),
          ...certified.map((s) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.workspace_premium, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                  Text(s.email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(children: [
                    _LevelBadge(s.level),
                    const SizedBox(width: 8),
                    Text('${s.xp} XP', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 8),
                    Text('${s.lessonsCompleted} lessons', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ]),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                    child: Text('CERTIFIED', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: 14),
                    label: const Text('Download', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                  ),
                ]),
              ]),
            ),
          )),
          if (_mockStudents.where((s) => !s.hasCertificate).isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('In Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            ..._mockStudents.where((s) => !s.hasCertificate).map((s) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
              child: Row(children: [
                CircleAvatar(backgroundColor: Colors.orange.withOpacity(0.1),
                  child: Text(s.name[0], style: const TextStyle(color: Colors.orange))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                  Text('Level ${s.level} - ${s.lessonsCompleted} lessons completed', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
                  child: Text('IN PROGRESS', style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold, fontSize: 10)),
                ),
              ]),
            )),
          ],
        ],
      ),
    );
  }
}

// ─── Analytics Tab ────────────────────────────────────────────────────────────

class _AnalyticsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Learning Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const Text('Platform-wide performance insights', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('CEFR Level Distribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(BarChartData(
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 1, color: Colors.red[300]!, width: 28, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 2, color: Colors.orange[300]!, width: 28, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 2, color: Colors.yellow[700]!, width: 28, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 2, color: Colors.green[400]!, width: 28, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 2, color: Colors.blue[400]!, width: 28, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 1, color: Colors.purple[400]!, width: 28, borderRadius: BorderRadius.circular(4))]),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Padding(padding: const EdgeInsets.only(top: 4), child: Text(['A1','A2','B1','B2','C1','C2'][v.toInt()], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))))),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.black54)))),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(drawVerticalLine: false),
                )),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Average Skill Scores', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 16),
              _SkillRow('Reading', 0.74, Colors.blue),
              _SkillRow('Listening', 0.70, Colors.purple),
              _SkillRow('Writing', 0.68, Colors.orange),
              _SkillRow('Grammar', 0.77, Colors.green),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─── Reports Tab ──────────────────────────────────────────────────────────────

class _ReportsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reports', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const Text('Download or preview platform reports', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          ...[
            (Icons.people, 'Student Progress Report', 'All students - levels, XP, and lessons completed', Colors.blue),
            (Icons.analytics, 'Learning Analytics', 'Engagement, completion rates, skill averages', Colors.purple),
            (Icons.calendar_month, 'Monthly Summary', 'New registrations, active users, retention rate', Colors.orange),
            (Icons.workspace_premium, 'Certificate Report', 'Students who earned their certificates', Colors.green),
            (Icons.emoji_events, 'Top Performers', 'Highest scoring students by level and country', Colors.amber),
          ].map((r) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(width: 48, height: 48,
                decoration: BoxDecoration(color: r.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(r.$1, color: r.$4)),
              title: Text(r.$2, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              subtitle: Text(r.$3, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                OutlinedButton(onPressed: () {}, child: const Text('PDF')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Excel'),
                ),
              ]),
            ),
          )),
        ],
      ),
    );
  }
}

// ─── Student Detail View ──────────────────────────────────────────────────────

class _StudentDetailView extends StatelessWidget {
  final _Student student;
  final VoidCallback onBack;

  const _StudentDetailView({required this.student, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Students'),
          ),
          const SizedBox(height: 8),
          // Profile header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0D1B4B), AppColors.secondary]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white24,
                child: Text(student.name[0], style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 20),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(student.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text(student.email, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text('${student.country} - Joined ${student.joinedDays}', style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                _LevelBadge(student.level),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: student.status == 'Active' ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(student.status, style: TextStyle(color: student.status == 'Active' ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(children: [
            Expanded(child: _MiniStat('${student.xp}', 'XP Points', Icons.star, Colors.amber)),
            const SizedBox(width: 12),
            Expanded(child: _MiniStat('${student.streak}', 'Day Streak', Icons.local_fire_department, Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _MiniStat('${student.lessonsCompleted}', 'Lessons Done', Icons.menu_book, Colors.blue)),
          ]),
          const SizedBox(height: 16),
          // Skill scores
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Skill Assessment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 16),
              _SkillRow('Reading', student.readingScore, Colors.blue),
              _SkillRow('Listening', student.listeningScore, Colors.purple),
              _SkillRow('Writing', student.writingScore, Colors.orange),
              _SkillRow('Grammar', student.grammarScore, Colors.green),
            ]),
          ),
          const SizedBox(height: 16),
          // Certificate
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: student.hasCertificate ? Colors.green[50] : Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: student.hasCertificate ? Colors.green.withOpacity(0.4) : Colors.grey.withOpacity(0.2)),
            ),
            child: Row(children: [
              Icon(student.hasCertificate ? Icons.workspace_premium : Icons.hourglass_empty,
                color: student.hasCertificate ? const Color(0xFFFFD700) : Colors.grey, size: 40),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  student.hasCertificate ? 'Certificate Earned' : 'Certificate Pending',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: student.hasCertificate ? Colors.green[800] : Colors.grey[600]),
                ),
                Text(
                  student.hasCertificate ? 'CEFR ${student.level} - Smart English Everyday' : 'Complete all required lessons to earn certificate',
                  style: TextStyle(color: student.hasCertificate ? Colors.green[600] : Colors.grey, fontSize: 13),
                ),
              ])),
              if (student.hasCertificate)
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Download'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                ),
            ]),
          ),
          const SizedBox(height: 16),
          // Admin actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Admin Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                OutlinedButton.icon(icon: const Icon(Icons.edit, size: 16), label: const Text('Edit Profile'), onPressed: () {}),
                OutlinedButton.icon(icon: const Icon(Icons.lock_reset, size: 16), label: const Text('Reset Password'), onPressed: () {}),
                OutlinedButton.icon(icon: const Icon(Icons.upgrade, size: 16), label: const Text('Change Level'), onPressed: () {}),
                OutlinedButton.icon(
                  icon: Icon(student.status == 'Active' ? Icons.block : Icons.check_circle, size: 16),
                  label: Text(student.status == 'Active' ? 'Suspend' : 'Activate'),
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(foregroundColor: student.status == 'Active' ? Colors.red : Colors.green),
                ),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final String title, value, subtitle;
  final IconData icon;
  final Color color;
  const _KpiCard(this.title, this.value, this.subtitle, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Icon(icon, color: color, size: 20),
        ]),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
        Text(subtitle, style: TextStyle(color: color, fontSize: 11)),
      ]),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _MiniStat(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ]),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String level;
  const _LevelBadge(this.level);

  @override
  Widget build(BuildContext context) {
    final color = {'A1': Colors.red, 'A2': Colors.orange, 'B1': Colors.yellow[700]!, 'B2': Colors.green, 'C1': Colors.blue, 'C2': Colors.purple}[level] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.4))),
      child: Text(level, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

class _SkillRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _SkillRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.black87))),
        Expanded(child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: value, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation(color), minHeight: 10),
        )),
        const SizedBox(width: 8),
        SizedBox(width: 36, child: Text('${(value * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87))),
      ]),
    );
  }
}
