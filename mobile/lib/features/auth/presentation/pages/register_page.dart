import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _step0Key = GlobalKey<FormState>();
  final _step1Key = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  String _selectedVariant = 'US';
  bool _agreedToTerms = false;
  int _step = 0;

  final List<Map<String, String>> _variants = [
    {'code': 'UK', 'name': 'United Kingdom'},
    {'code': 'US', 'name': 'United States'},
    {'code': 'AU', 'name': 'Australian'},
    {'code': 'NZ', 'name': 'New Zealand'},
    {'code': 'CA', 'name': 'Canadian'},
  ];

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _next() {
    final valid = _step == 0
        ? (_step0Key.currentState?.validate() ?? false)
        : (_step1Key.currentState?.validate() ?? false);
    if (valid) setState(() => _step++);
  }

  void _back() => setState(() => _step--);

  void _submit() {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms of Service')),
      );
      return;
    }
    context.read<AuthBloc>().add(AuthRegisterRequested(
          fullName:
              '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim(),
          username: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          englishVariant: _selectedVariant,
          country: 'GB',
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthNeedsAssessment || state is AuthAuthenticated) {
          context.go('/assessment');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _step > 0
                            ? _back
                            : () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                      ),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Step indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _StepIndicator(current: _step, total: 3),
                ),
                const SizedBox(height: 12),
                // Content
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: _buildCurrentStep(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildStep0();
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep0() {
    return Form(
      key: _step0Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personal Info',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Tell us your name',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _firstNameCtrl,
            label: 'First Name',
            prefixIcon: const Icon(Icons.person_outline),
            validator: (v) =>
                v == null || v.isEmpty ? 'First name is required' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _lastNameCtrl,
            label: 'Last Name',
            prefixIcon: const Icon(Icons.person_outline),
            validator: (v) =>
                v == null || v.isEmpty ? 'Last name is required' : null,
          ),
          const SizedBox(height: 32),
          CustomButton(label: 'Next', onPressed: _next),
          const SizedBox(height: 16),
          _signInLink(),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Account Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Set up your login credentials',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _usernameCtrl,
            label: 'Username',
            prefixIcon: const Icon(Icons.alternate_email),
            validator: AppValidators.username,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailCtrl,
            label: 'Email Address',
            prefixIcon: const Icon(Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
            validator: AppValidators.email,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordCtrl,
            label: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            isPassword: true,
            validator: AppValidators.password,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _confirmPasswordCtrl,
            label: 'Confirm Password',
            prefixIcon: const Icon(Icons.lock_outline),
            isPassword: true,
            validator: (v) =>
                v != _passwordCtrl.text ? 'Passwords do not match' : null,
          ),
          const SizedBox(height: 32),
          CustomButton(label: 'Next', onPressed: _next),
          const SizedBox(height: 16),
          _signInLink(),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('English Preference',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Which English variant do you prefer?',
            style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 20),
        ..._variants.map((v) => _VariantTile(
              name: v['name']!,
              code: v['code']!,
              selected: _selectedVariant == v['code'],
              onTap: () => setState(() => _selectedVariant = v['code']!),
            )),
        const SizedBox(height: 20),
        InkWell(
          onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Checkbox(
                value: _agreedToTerms,
                onChanged: (v) => setState(() => _agreedToTerms = v!),
                activeColor: AppColors.primary,
              ),
              const Expanded(
                child: Text(
                  'I agree to the Terms of Service and Privacy Policy',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) => CustomButton(
            label: 'Create Account',
            isLoading: state is AuthLoading,
            onPressed: _agreedToTerms ? _submit : null,
          ),
        ),
        const SizedBox(height: 16),
        _signInLink(),
      ],
    );
  }

  Widget _signInLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Already have an account? ',
              style: TextStyle(color: Colors.black54)),
          GestureDetector(
            onTap: () => context.go('/login'),
            child: const Text('Sign In',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final labels = ['Personal Info', 'Account Details', 'Preferences'];
    return Row(
      children: List.generate(total, (i) {
        final done = i < current;
        final active = i == current;
        return Expanded(
          child: Row(
            children: [
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: done
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: active || done
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: done
                          ? Icon(Icons.check,
                              size: 16, color: AppColors.primary)
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: active
                                    ? AppColors.primary
                                    : Colors.white70,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 9,
                      color: active || done
                          ? Colors.white
                          : Colors.white60,
                      fontWeight: active
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              if (i < total - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: done
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _VariantTile extends StatelessWidget {
  final String name;
  final String code;
  final bool selected;
  final VoidCallback onTap;

  const _VariantTile({
    required this.name,
    required this.code,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              '$name English',
              style: TextStyle(
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? AppColors.primary : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
