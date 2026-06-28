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
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  String _selectedVariant = 'US';
  bool _agreedToTerms = false;
  int _currentStep = 0;

  final List<Map<String, String>> _englishVariants = [
    {'code': 'UK', 'name': '🇬🇧 United Kingdom English'},
    {'code': 'US', 'name': '🇺🇸 United States English'},
    {'code': 'AU', 'name': '🇦🇺 Australian English'},
    {'code': 'NZ', 'name': '🇳🇿 New Zealand English'},
    {'code': 'CA', 'name': '🇨🇦 Canadian English'},
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/assessment');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Container(
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
                _buildHeader(context),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Stepper(
                        currentStep: _currentStep,
                        onStepTapped: (step) => setState(() => _currentStep = step),
                        controlsBuilder: (context, details) => _buildStepperControls(context, details),
                        steps: [
                          _buildPersonalInfoStep(),
                          _buildAccountStep(),
                          _buildPreferencesStep(),
                        ],
                      ),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const Text(
            'Create Account',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Step _buildPersonalInfoStep() {
    return Step(
      title: const Text('Personal Info'),
      content: Column(
        children: [
          CustomTextField(
            controller: _firstNameCtrl,
            label: 'First Name',
            prefixIcon: Icons.person_outline,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _lastNameCtrl,
            label: 'Last Name',
            prefixIcon: Icons.person_outline,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Step _buildAccountStep() {
    return Step(
      title: const Text('Account Details'),
      content: Column(
        children: [
          CustomTextField(
            controller: _usernameCtrl,
            label: 'Username',
            prefixIcon: Icons.alternate_email,
            validator: Validators.username,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailCtrl,
            label: 'Email Address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordCtrl,
            label: 'Password',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: Validators.password,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _confirmPasswordCtrl,
            label: 'Confirm Password',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: (v) => v != _passwordCtrl.text ? 'Passwords do not match' : null,
          ),
        ],
      ),
    );
  }

  Step _buildPreferencesStep() {
    return Step(
      title: const Text('English Preference'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select your preferred English variant:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ..._englishVariants.map((v) => RadioListTile<String>(
                title: Text(v['name']!),
                value: v['code']!,
                groupValue: _selectedVariant,
                onChanged: (val) => setState(() => _selectedVariant = val!),
                activeColor: AppColors.primary,
              )),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _agreedToTerms,
            onChanged: (v) => setState(() => _agreedToTerms = v!),
            title: const Text('I agree to the Terms of Service and Privacy Policy'),
            activeColor: AppColors.primary,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 20),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return CustomButton(
                label: 'Create Account',
                isLoading: state is AuthLoading,
                onPressed: _agreedToTerms ? _handleRegister : null,
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account? '),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: const Text('Sign In', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperControls(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (_currentStep < 2)
            ElevatedButton(
              onPressed: () {
                if (_currentStep == 0 && _formKey.currentState!.validate()) {
                  setState(() => _currentStep = 1);
                } else if (_currentStep == 1 && _formKey.currentState!.validate()) {
                  setState(() => _currentStep = 2);
                }
              },
              child: const Text('Next'),
            ),
          if (_currentStep > 0) ...[
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () => setState(() => _currentStep--),
              child: const Text('Back'),
            ),
          ],
        ],
      ),
    );
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthRegisterEvent(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        englishVariant: _selectedVariant,
      ));
    }
  }
}
