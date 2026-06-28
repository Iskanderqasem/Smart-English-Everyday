import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  static const _adminUsername = 'admin';
  static const _adminPassword = 'Admin@2024';

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 600));
    if (_usernameCtrl.text.trim() == _adminUsername &&
        _passwordCtrl.text == _adminPassword) {
      if (mounted) context.go('/admin');
    } else {
      setState(() { _error = 'Invalid username or password'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B4B),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 44),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Admin Portal',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Text(
                  'Smart English Everyday',
                  style: TextStyle(fontSize: 14, color: Colors.white54),
                ),
                const SizedBox(height: 40),

                // Card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sign In', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const Text('Enter your admin credentials', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 24),

                      // Username
                      const Text('Username', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _usernameCtrl,
                        decoration: InputDecoration(
                          hintText: 'admin',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        ),
                        onSubmitted: (_) => _login(),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          hintText: 'Enter password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        ),
                        onSubmitted: (_) => _login(),
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 18),
                            const SizedBox(width: 8),
                            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                          ]),
                        ),
                      ],

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _loading
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Back to Student Login', style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                // Hint box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Column(
                    children: [
                      Row(children: [
                        Icon(Icons.info_outline, color: Colors.white54, size: 16),
                        SizedBox(width: 8),
                        Text('Default Credentials', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
                      ]),
                      SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Username:', style: TextStyle(color: Colors.white38, fontSize: 12)),
                        Text('admin', style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace')),
                      ]),
                      SizedBox(height: 4),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Password:', style: TextStyle(color: Colors.white38, fontSize: 12)),
                        Text('Admin@2024', style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace')),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
