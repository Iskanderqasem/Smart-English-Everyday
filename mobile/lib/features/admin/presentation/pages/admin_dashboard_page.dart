import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

// ─── Main Page ───────────────────────────────────────────────────────────────

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _nav = 0;

  static const _navColor = Color(0xFF0D1B4B);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: _navColor,
        foregroundColor: Colors.white,
        title: const Row(children: [
          Icon(Icons.admin_panel_settings, size: 22),
          SizedBox(width: 8),
          Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/admin-login'),
            icon: const Icon(Icons.logout, color: Colors.white70, size: 18),
            label: const Text('Logout', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
      body: Row(children: [
        if (wide) _buildSidebar(),
        Expanded(
          child: IndexedStack(
            index: _nav,
            children: const [
              _DashboardTab(),
              _StudentsTab(),
              _CertificatesTab(),
              _ReportsTab(),
            ],
          ),
        ),
      ]),
      bottomNavigationBar: wide ? null : NavigationBar(
        backgroundColor: _navColor,
        indicatorColor: Colors.white24,
        selectedIndex: _nav,
        onDestinationSelected: (i) => setState(() => _nav = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined, color: Colors.white54), selectedIcon: Icon(Icons.dashboard, color: Colors.white), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.people_outlined, color: Colors.white54), selectedIcon: Icon(Icons.people, color: Colors.white), label: 'Students'),
          NavigationDestination(icon: Icon(Icons.card_membership_outlined, color: Colors.white54), selectedIcon: Icon(Icons.card_membership, color: Colors.white), label: 'Certs'),
          NavigationDestination(icon: Icon(Icons.description_outlined, color: Colors.white54), selectedIcon: Icon(Icons.description, color: Colors.white), label: 'Reports'),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final items = [
      (Icons.dashboard,        'Dashboard'),
      (Icons.people,           'Students'),
      (Icons.card_membership,  'Certificates'),
      (Icons.description,      'Reports'),
    ];
    return Container(
      width: 210,
      color: _navColor,
      child: Column(children: [
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('NAVIGATION', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2)),
        ),
        const SizedBox(height: 8),
        ...items.asMap().entries.map((e) {
          final selected = _nav == e.key;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: ListTile(
              dense: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              selected: selected,
              selectedTileColor: Colors.white12,
              leading: Icon(e.value.$1, color: selected ? Colors.white : Colors.white38, size: 20),
              title: Text(e.value.$2, style: TextStyle(color: selected ? Colors.white : Colors.white54, fontSize: 14)),
              onTap: () => setState(() => _nav = e.key),
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
      ]),
    );
  }
}

// ─── Backend Notice Banner ────────────────────────────────────────────────────

class _BackendNotice extends StatelessWidget {
  const _BackendNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[300]!),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline, color: Colors.amber[800], size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'This app currently stores data locally on each user\'s device. '
            'To manage real student accounts centrally, connect the backend API. '
            'The data below will update automatically once the backend is active.',
            style: TextStyle(color: Colors.amber[900], fontSize: 13, height: 1.5),
          ),
        ),
      ]),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

// ─── Dashboard Tab ────────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        const Text('Platform statistics', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        const _BackendNotice(),

        // KPI cards — show 0 until backend connected
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.6,
          children: const [
            _KpiCard('Total Students', '0',  'Registered users',     Icons.people,          Colors.blue),
            _KpiCard('Active Today',   '0',  'Currently active',     Icons.trending_up,     Colors.green),
            _KpiCard('Certificates',   '0',  'Completed students',   Icons.card_membership, Colors.orange),
            _KpiCard('Avg Level',      '—',  'Platform average',     Icons.school,          Colors.purple),
          ],
        ),
        const SizedBox(height: 32),

        const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 12),
        const _EmptyState(
          icon: Icons.history,
          title: 'No activity yet',
          subtitle: 'Student activity will appear here once the backend database is connected and users start registering.',
        ),
      ]),
    );
  }
}

// ─── Students Tab ─────────────────────────────────────────────────────────────

class _StudentsTab extends StatelessWidget {
  const _StudentsTab();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Search bar — non-functional until backend
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: TextField(
          enabled: false,
          decoration: InputDecoration(
            hintText: 'Search students… (requires backend)',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const _BackendNotice(),
            const _EmptyState(
              icon: Icons.people_outline,
              title: 'No students yet',
              subtitle: 'When users register through the app, their profiles will appear here. Connect the backend API to enable central user management.',
            ),
          ]),
        ),
      ),
    ]);
  }
}

// ─── Certificates Tab ─────────────────────────────────────────────────────────

class _CertificatesTab extends StatelessWidget {
  const _CertificatesTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Certificates', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
            Text('Students who completed their level assessment', style: TextStyle(color: Colors.grey)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: const Row(children: [
              Icon(Icons.card_membership, color: Colors.grey, size: 18),
              SizedBox(width: 6),
              Text('0 Issued', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ]),
          ),
        ]),
        const SizedBox(height: 24),
        const _BackendNotice(),
        const _EmptyState(
          icon: Icons.workspace_premium_outlined,
          title: 'No certificates issued yet',
          subtitle: 'Certificates are awarded automatically when students complete all required lessons and pass the assessment. They will appear here once the backend is connected.',
        ),

        // Certificate criteria explanation
        const SizedBox(height: 24),
        const Text('Certificate Requirements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 12),
        ...[
          (Icons.menu_book,     Colors.blue,   'Complete all lessons',          'Student must finish all lessons for their CEFR level'),
          (Icons.quiz,          Colors.purple,  'Pass the final assessment',     'Score 70% or higher in the level assessment'),
          (Icons.mic,           Colors.orange,  'Speaking practice',             'Complete at least 5 speaking sessions'),
          (Icons.edit_note,     Colors.green,   'Writing submission',            'Submit at least 3 writing exercises'),
        ].map((r) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: r.$2.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(r.$1, color: r.$2, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.$3, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
              Text(r.$4, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ])),
          ]),
        )),
      ]),
    );
  }
}

// ─── Reports Tab ──────────────────────────────────────────────────────────────

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Reports', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        const Text('Download or preview platform reports', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        const _BackendNotice(),

        ...[
          (Icons.people,              Colors.blue,   'Student Progress Report',   'All students — levels, XP, and lessons completed'),
          (Icons.analytics,           Colors.purple, 'Learning Analytics',        'Engagement, completion rates, skill averages'),
          (Icons.calendar_month,      Colors.orange, 'Monthly Summary',           'New registrations, active users, retention rate'),
          (Icons.workspace_premium,   Colors.green,  'Certificate Report',        'Students who earned their certificates'),
          (Icons.emoji_events,        Colors.amber,  'Top Performers',            'Highest scoring students by level and country'),
        ].map((r) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: r.$2.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(r.$1, color: r.$2),
            ),
            title: Text(r.$3, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            subtitle: Text(r.$4, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: Tooltip(
              message: 'Requires backend connection',
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                OutlinedButton(
                  onPressed: null,
                  child: const Text('PDF'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.grey),
                  child: const Text('Excel'),
                ),
              ]),
            ),
          ),
        )),
      ]),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis)),
          Icon(icon, color: color, size: 20),
        ]),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
        Text(subtitle, style: TextStyle(color: color, fontSize: 11)),
      ]),
    );
  }
}
