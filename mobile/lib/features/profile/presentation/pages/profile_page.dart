import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    try {
      final data = sl<StorageService>().getUserData();
      if (data != null) setState(() => _user = UserModel.fromJson(data));
    } catch (_) {}
  }

  String get _displayName => _user?.fullName.isNotEmpty == true ? _user!.fullName : 'Student';
  String get _username => _user?.username.isNotEmpty == true ? '@${_user!.username}' : '';
  String get _level => _user?.cefrLevel ?? 'A1';
  String get _variant {
    final v = _user?.englishVariant ?? 'US';
    if (v.toLowerCase().contains('british') || v.toLowerCase().contains('uk')) return 'UK';
    if (v.toLowerCase().contains('australian') || v.toLowerCase().contains('au')) return 'AU';
    return 'US';
  }
  String get _streakDays => '${_user?.streakDays ?? 0} days';
  String get _totalXp => '${_user?.totalXp ?? 0} XP';
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white24,
                            child: Text(
                              _initials,
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          Positioned(
                            right: 0, bottom: 0,
                            child: Container(
                              width: 28, height: 28,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, size: 16, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(_displayName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      if (_username.isNotEmpty)
                        Text(_username, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        _StatPill(Icons.local_fire_department, _streakDays, Colors.orange),
                        const SizedBox(width: 8),
                        _StatPill(Icons.star, _totalXp, Colors.amber),
                        const SizedBox(width: 8),
                        _StatPill(Icons.emoji_events, _level, Colors.white),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
            title: const Text('Profile'),
            actions: [
              IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
            ],
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
                    _MenuItem(Icons.notifications_outlined, 'Notifications', Colors.purple, () {}),
                    _MenuItem(Icons.language, 'English Variant: $_variant', Colors.green, () {}),
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
                      onPressed: _signOut,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Smart English Everyday v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 32),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('42', 'Hours'),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStat('38', 'Lessons'),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStat('847', 'Words'),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStat(_variant, 'Variant'),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCertificates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Certificates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _CertCard('Level 1 Complete', 'Jan 2024', Icons.school),
              _CertCard('Grammar Master', 'Feb 2024', Icons.menu_book),
              _CertCard('Vocabulary Pro', 'Mar 2024', Icons.emoji_events),
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
          ),
          child: Column(
            children: items.asMap().entries.map((e) => Column(children: [
              ListTile(
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: e.value.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(e.value.icon, color: e.value.color, size: 20),
                ),
                title: Text(e.value.label, style: const TextStyle(color: Colors.black87)),
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
  final IconData icon;
  final String text;
  final Color color;
  const _StatPill(this.icon, this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 14),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
    ]),
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
  final String title, date;
  final IconData icon;
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
        Icon(icon, color: Colors.white, size: 28),
        const Spacer(),
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(date, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    ),
  );
}
