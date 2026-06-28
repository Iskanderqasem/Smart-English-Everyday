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
  // Separate form keys so each step only validates its own fields
  final _step0Key = GlobalKey<FormState>();
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

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
    {'code': 'UK', 'name': 'United Kingdom English'},
    {'code': 'US', 'name': 'United States English'},
    {'code': 'AU', 'name': 'Australian English'},
    {'code': 'NZ', 'name': 'New Zealand English'},
    {'code': 'CA', 'name': 'Canadian English'},
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

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _step0Key.currentState?.validate() ?? false;
      case 1:
        return _step1Key.currentState?.validate() ?? false;
      case 2:
        return _step2Key.currentState?.validate() ?? false;
      default:
        return false;
    }
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
                    child: Theme(
                      // Override stepper colors so text is clearly visible
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                          onSurface: Colors.black87,
                          primary: AppColors.primary,
                        ),
                      ),
                      child: Stepper(
                        currentStep: _currentStep,
                        onStepTapped: (step) {
                          // Only allow tapping back to a previous step
                          if (step < _currentStep) {
                            setState(() => _currentStep = step);
                          }
                        },
                        controlsBuilder: (context, details) =>
                            _buildStepperControls(context),
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
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Step _buildPersonalInfoStep() {
    return Step(
      title: const Text('Personal Info',
          style: TextStyle(fontWeight: FontWeight.w600)),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _step0Key,
        child: Column(
          children: [
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
          ],
        ),
      ),
    );
  }

  Step _buildAccountStep() {
    return Step(
      title: const Text('Account Details',
          style: TextStyle(fontWeight: FontWeight.w600)),
      isActive: _currentStep >= 1,
      state: _currentStep > 1
          ? StepState.complete
          : _currentStep == 1
              ? StepState.indexed
              : StepState.indexed,
      content: Form(
        key: _step1Key,
        child: Column(
          children: [
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
          ],
        ),
      ),
    );
  }

  Step _buildPreferencesStep() {
    return Step(
      title: const Text('English Preference',
          style: TextStyle(fontWeight: FontWeight.w600)),
      isActive: _currentStep >= 2,
      content: Form(
        key: _step2Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select your preferred English variant:',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87),
            ),
            const SizedBox(height: 12),
            ..._englishVariants.map((v) => RadioListTile<String>(
                  title: Text(v['name']!,
                      style: const TextStyle(color: Colors.black87)),
                  value: v['code']!,
                  groupValue: _selectedVariant,
                  onChanged: (val) => setState(() => _selectedVariant = val!),
                  activeColor: AppColors.primary,
                )),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _agreedToTerms,
              onChanged: (v) => setState(() => _agreedToTerms = v!),
              title: const Text(
                'I agree to the Terms of Service and Privacy Policy',
                style: TextStyle(color: Colors.black87),
              ),
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
                const Text('Already have an account? ',
                    style: TextStyle(color: Colors.black54)),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: const Text('Sign In',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (_currentStep < 2)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (_validateCurrentStep()) {
                  setState(() => _currentStep++);
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
    if (_step2Key.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(AuthRegisterRequested(
            fullName:
                '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'
                    .trim(),
            username: _usernameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            englishVariant: _selectedVariant,
            country: 'GB',
          ));
    }
  }
}
