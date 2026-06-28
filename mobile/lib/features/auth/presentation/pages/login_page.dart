import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text,
              password: _passwordController.text,
              ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRouter.home);
        } else if (state is AuthNeedsAssessment) {
          context.go(AppRouter.assessment);
        } else if (state is AuthNeedsEmailVerification) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please verify your email to continue.'),
              backgroundColor: AppColors.warning,
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            'SE',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 16),
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 4),
                      const Text(
                        'Sign in to continue your learning journey',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),
                // Form card
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        32,
                        24,
                        MediaQuery.of(context).viewInsets.bottom + 24,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              label: AppStrings.email,
                              hint: 'your@email.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: AppValidators.email,
                              prefixIcon: const Icon(Icons.email_outlined),
                              textInputAction: TextInputAction.next,
                            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: AppStrings.password,
                              hint: 'Enter your password',
                              controller: _passwordController,
                              isPassword: true,
                              validator: (v) => v == null || v.isEmpty ? AppStrings.fieldRequired : null,
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _onLogin(),
                            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                const Text(AppStrings.rememberMe, style: TextStyle(fontSize: 14)),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => context.push(AppRouter.forgotPassword),
                                  child: const Text(AppStrings.forgotPassword),
                                ),
                              ],
                            ).animate().fadeIn(delay: 300.ms),
                            const SizedBox(height: 24),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) => CustomButton(
                                label: AppStrings.login,
                                onPressed: _onLogin,
                                isLoading: state is AuthLoading,
                                variant: ButtonVariant.gradient,
                                gradientColors: AppColors.primaryGradient,
                              ),
                            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    AppStrings.orContinueWith,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                                Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                              ],
                            ).animate().fadeIn(delay: 500.ms),
                            const SizedBox(height: 16),
                            SocialButton(
                              label: AppStrings.continueWithGoogle,
                              icon: const Icon(Icons.g_mobiledata_rounded, size: 28, color: Colors.red),
                              onPressed: () => context.read<AuthBloc>().add(const AuthGoogleSignInRequested()),
                            ).animate().fadeIn(delay: 550.ms),
                            if (Platform.isIOS) ...[
                              const SizedBox(height: 12),
                              SocialButton(
                                label: AppStrings.continueWithApple,
                                icon: const Icon(Icons.apple_rounded, size: 24),
                                onPressed: () => context.read<AuthBloc>().add(const AuthAppleSignInRequested()),
                              ).animate().fadeIn(delay: 600.ms),
                            ],
                            const SizedBox(height: 12),
                            SocialButton(
                              label: AppStrings.continueWithFacebook,
                              icon: const Icon(Icons.facebook_rounded, size: 24, color: Color(0xFF1877F2)),
                              onPressed: () => context.read<AuthBloc>().add(const AuthFacebookSignInRequested()),
                            ).animate().fadeIn(delay: 650.ms),
                            const SizedBox(height: 24),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppStrings.dontHaveAccount,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  TextButton(
                                    onPressed: () => context.go(AppRouter.register),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                    ),
                                    child: const Text(
                                      AppStrings.signUpNow,
                                      style: TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 700.ms),
                          ],
                        ),
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
}


