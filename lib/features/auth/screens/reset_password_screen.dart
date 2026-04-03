import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/features/auth/screens/otp_verification_screen.dart';
import 'package:smartnursery/features/auth/widgets/auth_header.dart';
import 'package:smartnursery/features/auth/widgets/auth_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const OtpVerificationScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authPageBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Green wave header ──────────────────────────────
            const AuthHeader(height: 220),

            // ── Content ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),

                    // Title
                    const Text(
                      'Réinitialiser votre mot de passe',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.authTitle,
                    ),

                    const SizedBox(height: 32),

                    // Email field
                    AuthTextField(
                      hint: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.formPrefixOrange,
                        size: 22,
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Veuillez entrer votre email' : null,
                    ),

                    const SizedBox(height: 14),

                    // Password field
                    AuthTextField(
                      hint: 'Mot de passe',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: const Icon(
                        Icons.lock_rounded,
                        color: AppColors.formPrefixYellow,
                        size: 22,
                      ),
                      validator: (v) =>
                          (v == null || v.length < 6) ? 'Minimum 6 caractères' : null,
                    ),

                    const SizedBox(height: 14),

                    // Confirm password field
                    AuthTextField(
                      hint: 'confirmer votre mot de passe',
                      controller: _confirmController,
                      isPassword: true,
                      prefixIcon: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primaryButton,
                        size: 22,
                      ),
                      validator: (v) => v != _passwordController.text
                          ? 'Les mots de passe ne correspondent pas'
                          : null,
                    ),

                    const SizedBox(height: 40),

                    // Submit button
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: const BoxDecoration(
                        boxShadow: AppShadows.primaryButton,
                      ),
                      child: ElevatedButton(
                        onPressed: _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButton,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Footer link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Vous avez déjà un compte , ',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.mutedText,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textLink,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
