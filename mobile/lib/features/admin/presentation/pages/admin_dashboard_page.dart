import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});
  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedNav = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF1a237e),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          Padding(padding: const EdgeInsets.only(right: 12), child: CircleAvatar(backgroundColor: Colors.white24, child: const Text('A', style: TextStyle(color: Colors.white)))),
        ],
      ),
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width > 600) _buildSidebar(),
          Expanded(
            child: IndexedStack(
              index: _selectedNav,
              children: [
                _buildDashboardTab(),
                _buildUsersTab(),
                _buildAnalyticsTab(),
                _buildReportsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 600
        ? NavigationBar(
            selectedIndex: _selectedNav,
            onDestinationSelected: (i) => setState(() => _selectedNav = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
              NavigationDestination(icon: Icon(Icons.people_outlined), selectedIcon: Icon(Icons.people), label: 'Users'),
              NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Analytics'),
              NavigationDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description), label: 'Reports'),
            ],
          )
        : null,
    );
  }

  Widget _buildSidebar() {
    final items = [
      {'icon': Icons.dashboard, 'label': 'Dashboard'},
      {'icon': Icons.people, 'label': 'Users'},
      {'icon': Icons.analytics, 'label': 'Analytics'},
      {'icon': Icons.description, 'label': 'Reports'},
    ];
    return Container(
      width: 200,
      color: const Color(0xFF1a237e),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text('ADMIN', style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 2)),
          const SizedBox(height: 8),
          ...items.asMap().entries.map((e) => ListTile(
            leading: Icon(e.value['icon'] as IconData, color: _selectedNav == e.key ? Colors.white : Colors.white54),
            title: Text(e.value['label'] as String, style: TextStyle(color: _selectedNav == e.key ? Colors.white : Colors.white54)),
            selected: _selectedNav == e.key,
            selectedTileColor: Colors.white12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onTap: () => setState(() => _selectedNav = e.key),
          )),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Today at a glance', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _StatCard2('Total Students', '12,847', '+234 this month', Icons.people, Colors.blue),
              _StatCard2('Active Today', '1,432', '+12% vs yesterday', Icons.trending_up, Colors.green),
              _StatCard2('New This Week', '287', 'Registration rate', Icons.person_add, Colors.orange),
              _StatCard2('Avg CEFR Score', 'B1.2', 'Platform average', Icons.school, Colors.purple),
            ],
          ),
          const SizedBox(height: 24),
          const Text('User Growth (Last 30 Days)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
            child: LineChart(LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 5, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10)))),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, _) => Text('${(v/1000).toStringAsFixed(1)}k', style: const TextStyle(fontSize: 10)))),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [LineChartBarData(
                spots: List.generate(30, (i) => FlSpot(i.toDouble(), (10000 + i * 100 + (i % 7 == 0 ? 200 : 0)).toDouble())),
                isCurved: true,
                color: AppColors.primary,
                barWidth: 3,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
              )],
            )),
          ),
          const SizedBox(height: 24),
          const Text('Top Students', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...List.generate(5, (i) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
            child: Row(children: [
              Container(width: 32, height: 32, decoration: BoxDecoration(color: [Colors.amber, Colors.grey[300], Colors.brown[300], Colors.blue[100], Colors.green[100]][i], borderRadius: BorderRadius.circular(16)),
                child: Center(child: Text('${i+1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))),
              const SizedBox(width: 12),
              CircleAvatar(radius: 18, backgroundColor: AppColors.primary.withOpacity(0.1), child: Text(['S','A','M','J','L'][i], style: const TextStyle(color: AppColors.primary))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(['Sarah Mitchell','Ahmed Khalil','Maria Lopez','John Davis','Lisa Chen'][i], style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(['ðŸ‡¬ðŸ‡§ C1','ðŸ‡¦ðŸ‡ª B2','ðŸ‡§ðŸ‡· B1','ðŸ‡ºðŸ‡¸ C1','ðŸ‡¨ðŸ‡³ B2'][i], style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ])),
              Text(['4,820 XP','4,215 XP','3,890 XP','3,650 XP','3,420 XP'][i], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: TextField(decoration: InputDecoration(hintText: 'Search students...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), filled: true, fillColor: Colors.grey[100]))),
            const SizedBox(width: 12),
            OutlinedButton.icon(icon: const Icon(Icons.filter_list), label: const Text('Filter'), onPressed: () {}),
            const SizedBox(width: 8),
            ElevatedButton.icon(icon: const Icon(Icons.download), label: const Text('Export'), onPressed: () {}),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 20,
            itemBuilder: (_, i) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: Text('U', style: const TextStyle(color: AppColors.primary))),
                title: Text('Student ${i+1}'),
                subtitle: Text('student${i+1}@email.com â€¢ Joined ${30-i} days ago'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                    child: Text(['A2','B1','B1','B2','A1'][i%5], style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 8),
                  const Icon(Icons.more_vert, color: Colors.grey),
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Learning Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('CEFR Distribution'),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
          child: BarChart(BarChartData(
            barGroups: [
              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 12, color: Colors.red[300]!, width: 28, borderRadius: BorderRadius.circular(4))]),
              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 28, color: Colors.orange[300]!, width: 28, borderRadius: BorderRadius.circular(4))]),
              BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 35, color: Colors.yellow[700]!, width: 28, borderRadius: BorderRadius.circular(4))]),
              BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 22, color: Colors.green[400]!, width: 28, borderRadius: BorderRadius.circular(4))]),
              BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 15, color: Colors.blue[400]!, width: 28, borderRadius: BorderRadius.circular(4))]),
              BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 8, color: Colors.purple[400]!, width: 28, borderRadius: BorderRadius.circular(4))]),
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text(['A1','A2','B1','B2','C1','C2'][v.toInt()], style: const TextStyle(fontWeight: FontWeight.bold)))),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, _) => Text('${v.toInt()}%', style: const TextStyle(fontSize: 10)))),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(drawVerticalLine: false),
          )),
        ),
      ]),
    );
  }

  Widget _buildReportsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Export Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...[
            {'title': 'Student Progress Report', 'desc': 'All students progress, levels, and scores', 'icon': Icons.people},
            {'title': 'Learning Analytics', 'desc': 'Engagement and completion metrics', 'icon': Icons.analytics},
            {'title': 'Monthly Summary', 'desc': 'New registrations, active users, retention', 'icon': Icons.calendar_month},
            {'title': 'Top Performers', 'desc': 'Highest scoring students by country', 'icon': Icons.emoji_events},
          ].map((r) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(r['icon'] as IconData, color: AppColors.primary)),
              title: Text(r['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(r['desc'] as String, style: const TextStyle(color: Colors.grey)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                OutlinedButton(onPressed: () {}, child: const Text('PDF')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () {}, child: const Text('Excel')),
              ]),
            ),
          )),
        ],
      ),
    );
  }
}

int _height(int n) => n; // workaround

class _StatCard2 extends StatelessWidget {
  final String title, value, subtitle;
  final IconData icon;
  final Color color;
  const _StatCard2(this.title, this.value, this.subtitle, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Icon(icon, color: color, size: 20),
          ]),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}

