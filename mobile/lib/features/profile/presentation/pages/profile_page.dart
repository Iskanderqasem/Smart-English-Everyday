import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 40),
                  Stack(
                    children: [
                      const CircleAvatar(radius: 48, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 48, color: Colors.white)),
                      Positioned(right: 0, bottom: 0, child: Container(
                        width: 28, height: 28,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, size: 16, color: AppColors.primary),
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Student Name', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text('@username', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _StatPill('🔥 7 days'),
                    const SizedBox(width: 8),
                    _StatPill('⭐ 1,240 XP'),
                    const SizedBox(width: 8),
                    _StatPill('🏆 B1'),
                  ]),
                ]),
              ),
            ),
            title: const Text('Profile'),
            actions: [IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {})],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 20),
                  _buildCertificates(),
                  const SizedBox(height: 20),
                  _buildMenuSection('Learning', [
                    _MenuItem(Icons.bar_chart, 'My Progress', Colors.blue, () => context.push('/progress')),
                    _MenuItem(Icons.emoji_events, 'Achievements', Colors.amber, () {}),
                    _MenuItem(Icons.card_membership, 'Certificates', Colors.green, () {}),
                    _MenuItem(Icons.history, 'Study History', Colors.purple, () {}),
                  ]),
                  const SizedBox(height: 12),
                  _buildMenuSection('Account', [
                    _MenuItem(Icons.person_outline, 'Edit Profile', Colors.blue, () {}),
                    _MenuItem(Icons.lock_outline, 'Change Password', Colors.orange, () {}),
                    _MenuItem(Icons.security, 'Two-Factor Auth', Colors.teal, () {}),
                    _MenuItem(Icons.notifications_outlined, 'Notifications', Colors.purple, () {}),
                    _MenuItem(Icons.language, 'English Variant', Colors.green, () {}),
                  ]),
                  const SizedBox(height: 12),
                  _buildMenuSection('Support', [
                    _MenuItem(Icons.help_outline, 'Help Center', Colors.grey, () {}),
                    _MenuItem(Icons.feedback_outlined, 'Send Feedback', Colors.blue, () {}),
                    _MenuItem(Icons.privacy_tip_outlined, 'Privacy Policy', Colors.grey, () {}),
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                      onPressed: () => context.go('/login'),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.all(14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Smart English Everyday v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('42', 'Hours'),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStat('38', 'Lessons'),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStat('847', 'Words'),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStat('🇺🇸', 'Variant'),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCertificates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Certificates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _CertCard('Level 1 Complete', 'Jan 2024', '🎓'),
              _CertCard('Grammar Master', 'Feb 2024', '📚'),
              _CertCard('Vocabulary Pro', 'Mar 2024', '🏆'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
          child: Column(
            children: items.asMap().entries.map((e) => Column(children: [
              ListTile(
                leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: e.value.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(e.value.icon, color: e.value.color, size: 20)),
                title: Text(e.value.label),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: e.value.onTap,
              ),
              if (e.key < items.length - 1) const Divider(height: 1, indent: 64),
            ])).toList(),
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String text;
  const _StatPill(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
  );
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.label, this.color, this.onTap);
}

class _CertCard extends StatelessWidget {
  final String title, date, icon;
  const _CertCard(this.title, this.date, this.icon);
  @override
  Widget build(BuildContext context) => Container(
    width: 140,
    margin: const EdgeInsets.only(right: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [Colors.amber[700]!, Colors.orange[400]!]),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const Spacer(),
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(date, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    ),
  );
}
