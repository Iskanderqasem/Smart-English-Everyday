import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCEFRCard(),
            const SizedBox(height: 16),
            _buildExamEstimates(),
            const SizedBox(height: 20),
            const Text('Weekly Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildWeeklyChart(),
            const SizedBox(height: 20),
            const Text('Skill Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildSkillsGrid(),
            const SizedBox(height: 20),
            const Text('Achievements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildAchievements(),
            const SizedBox(height: 20),
            const Text('Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildStatistics(),
          ],
        ),
      ),
    );
  }

  Widget _buildCEFRCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(40)),
            child: const Center(child: Text('B1', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CEFR Level', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const Text('B1 — Intermediate', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: 0.65, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Colors.white), minHeight: 8),
                ),
                const SizedBox(height: 4),
                const Text('65% to B2', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamEstimates() {
    return Row(
      children: [
        Expanded(child: _ExamCard('IELTS', '5.5', 'Upper Intermediate', Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _ExamCard('TOEFL', '72', 'Out of 120', Colors.green)),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey[100]!, strokeWidth: 1)),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text(['M','T','W','T','F','S','S'][v.toInt()], style: const TextStyle(fontSize: 11, color: Colors.grey)))),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, _) => Text('${v.toInt()}m', style: const TextStyle(fontSize: 10, color: Colors.grey)))),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [FlSpot(0, 20), FlSpot(1, 45), FlSpot(2, 30), FlSpot(3, 80), FlSpot(4, 55), FlSpot(5, 90), FlSpot(6, 40)],
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsGrid() {
    final skills = [
      {'label': 'Reading', 'value': 0.72, 'color': Colors.blue, 'icon': Icons.chrome_reader_mode},
      {'label': 'Writing', 'value': 0.58, 'color': Colors.orange, 'icon': Icons.edit},
      {'label': 'Speaking', 'value': 0.65, 'color': Colors.green, 'icon': Icons.mic},
      {'label': 'Listening', 'value': 0.70, 'color': Colors.purple, 'icon': Icons.headphones},
      {'label': 'Grammar', 'value': 0.80, 'color': Colors.teal, 'icon': Icons.spellcheck},
      {'label': 'Vocabulary', 'value': 0.68, 'color': Colors.red, 'icon': Icons.text_fields},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: skills.map((s) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(s['icon'] as IconData, color: s['color'] as Color, size: 20),
              const SizedBox(width: 8),
              Text(s['label'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              LinearProgressIndicator(value: s['value'] as double, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation(s['color'] as Color), borderRadius: BorderRadius.circular(4), minHeight: 8),
              const SizedBox(height: 4),
              Text('${((s['value'] as double) * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: s['color'] as Color, fontSize: 13)),
            ]),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildAchievements() {
    final badges = [
      {'name': 'First Step', 'icon': '🎯', 'unlocked': true},
      {'name': '7-Day Streak', 'icon': '🔥', 'unlocked': true},
      {'name': 'Grammar Pro', 'icon': '📚', 'unlocked': true},
      {'name': 'Month Streak', 'icon': '💪', 'unlocked': false},
      {'name': 'Wordmaster', 'icon': '🏆', 'unlocked': false},
      {'name': 'B2 Level', 'icon': '⭐', 'unlocked': false},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        itemBuilder: (_, i) {
          final b = badges[i];
          final unlocked = b['unlocked'] as bool;
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: unlocked ? Colors.amber[50] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: unlocked ? Colors.amber : Colors.grey[300]!, width: 2),
                  ),
                  child: Center(child: Text(unlocked ? b['icon'] as String : '🔒', style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(height: 4),
                Text(b['name'] as String, style: TextStyle(fontSize: 10, color: unlocked ? Colors.black : Colors.grey), textAlign: TextAlign.center),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatistics() {
    final stats = [
      {'label': 'Days Studied', 'value': '23', 'icon': Icons.calendar_today},
      {'label': 'Hours Total', 'value': '42h', 'icon': Icons.timer},
      {'label': 'Words Learned', 'value': '847', 'icon': Icons.text_fields},
      {'label': 'Lessons Done', 'value': '38', 'icon': Icons.menu_book},
      {'label': 'Tests Passed', 'value': '12', 'icon': Icons.check_circle},
      {'label': 'XP Earned', 'value': '1,240', 'icon': Icons.star},
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: stats.map((s) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(s['icon'] as IconData, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(s['value'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(s['label'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
        ]),
      )).toList(),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final String exam, score, subtitle;
  final Color color;
  const _ExamCard(this.exam, this.score, this.subtitle, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(exam, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(score, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        const Text('Estimated', style: TextStyle(color: Colors.grey, fontSize: 10)),
      ]),
    );
  }
}
