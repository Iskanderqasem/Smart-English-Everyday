import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔑', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text('Forgot Password?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Enter your email and we\'ll send you a reset link.', style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 32),
          CustomTextField(controller: _emailCtrl, label: 'Email Address', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: Validators.email),
          const SizedBox(height: 24),
          CustomButton(label: 'Send Reset Link', isLoading: _loading, onPressed: _submit),
          const SizedBox(height: 16),
          Center(child: TextButton(onPressed: () => context.pop(), child: const Text('Back to Login'))),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📬', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          const Text('Check Your Email!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('We sent a reset link to\n${_emailCtrl.text}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 16, height: 1.5)),
          const SizedBox(height: 32),
          CustomButton(label: 'Back to Login', onPressed: () => context.go('/login')),
          const SizedBox(height: 12),
          TextButton(onPressed: _submit, child: const Text('Resend Email')),
        ],
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() { _loading = false; _sent = true; });
  }
}
