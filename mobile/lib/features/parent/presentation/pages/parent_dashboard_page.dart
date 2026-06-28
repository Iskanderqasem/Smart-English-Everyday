import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';

class ParentDashboardPage extends StatefulWidget {
  const ParentDashboardPage({super.key});
  @override
  State<ParentDashboardPage> createState() => _ParentDashboardPageState();
}

class _ParentDashboardPageState extends State<ParentDashboardPage> {
  int _selectedChild = 0;

  final _children = [
    {'name': 'Alex', 'age': 12, 'level': 'B1', 'streak': 7, 'xp': 1240, 'avatar': '👦'},
    {'name': 'Sara', 'age': 10, 'level': 'A2', 'streak': 3, 'xp': 680, 'avatar': '👧'},
  ];

  @override
  Widget build(BuildContext context) {
    final child = _children[_selectedChild];
    return Scaffold(
      appBar: AppBar(title: const Text('Parent Dashboard'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: _children.asMap().entries.map((e) => GestureDetector(
            onTap: () => setState(() => _selectedChild = e.key),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _selectedChild == e.key ? AppColors.primary : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Text(e.value['avatar'] as String, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(e.value['name'] as String, style: TextStyle(fontWeight: FontWeight.bold, color: _selectedChild == e.key ? Colors.white : Colors.black87)),
              ]),
            ),
          )).toList()),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _Stat('${child['level']}', 'CEFR Level', Colors.white),
              _Stat('🔥 ${child['streak']}', 'Day Streak', Colors.white),
              _Stat('⭐ ${child['xp']}', 'Total XP', Colors.white),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Weekly Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: BarChart(BarChartData(
              barGroups: [15, 20, 10, 25, 30, 18, 22].asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.toDouble(), color: AppColors.primary, width: 20, borderRadius: BorderRadius.circular(6))])).toList(),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text(['M','T','W','T','F','S','S'][v.toInt()], style: const TextStyle(fontSize: 12, color: Colors.grey)))),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            )),
          ),
          const SizedBox(height: 20),
          const Text('Skills Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...['Reading', 'Writing', 'Speaking', 'Listening', 'Grammar', 'Vocabulary'].asMap().entries.map((e) {
            final vals = [0.8, 0.6, 0.5, 0.7, 0.65, 0.75];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                SizedBox(width: 90, child: Text(e.value, style: const TextStyle(fontSize: 14))),
                Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: vals[e.key], backgroundColor: Colors.grey[200], color: AppColors.primary, minHeight: 8))),
                SizedBox(width: 40, child: Text('${(vals[e.key] * 100).toInt()}%', textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
              ]),
            );
          }),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            icon: const Icon(Icons.mail_outline),
            label: const Text('Contact Teacher'),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message sent to teacher!'))),
          )),
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _Stat(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
    Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
  ]);
}
