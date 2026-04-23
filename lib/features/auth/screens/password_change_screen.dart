import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/features/auth/widgets/auth_header.dart';
import 'package:smartnursery/features/auth/widgets/auth_text_field.dart';
import 'package:smartnursery/features/auth/screens/login_screen.dart';
import 'package:smartnursery/features/auth/auth_service.dart';

class PasswordChangeScreen extends StatefulWidget {
  final String email;
  final String otp;

  const PasswordChangeScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final result = await AuthService.changePasswordWithOtp(
        email: widget.email,
        otp: widget.otp,
        newPassword: _passwordController.text,
      );

      if (!mounted) {
        setState(() => _isLoading = false);
        return;
      }

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe changé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Erreur lors du changement de mot de passe',
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authPageBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header & Hero Image ────────────────────────────
            Stack(
              alignment: Alignment.topCenter,
              children: [
                const AuthHeader(height: 220),
                Positioned(
                  top: 60,
                  child: Image.asset(
                    'assets/images/enfants-jouent.png',
                    width: 230,
                    height: 188,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),

            // ── Content ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    // Title
                    const Text(
                      'Nouveau mot de passe',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.authTitle,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Pour l\'email : ${widget.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedText,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Password field
                    AuthTextField(
                      hint: 'Nouveau mot de passe',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Image.asset(
                        'assets/icons/cadenas.png',
                        width: 26,
                        height: 26,
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Minimum 6 caractères'
                          : null,
                    ),

                    const SizedBox(height: 14),

                    // Confirm password field
                    AuthTextField(
                      hint: 'Confirmer le mot de passe',
                      controller: _confirmController,
                      isPassword: true,
                      prefixIcon: Image.asset(
                        'assets/icons/Check.png',
                        width: 26,
                        height: 26,
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
                        onPressed: _isLoading ? null : _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButton,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Changer le mot de passe',
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
                          'Retour à la ',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.mutedText,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text(
                            'connexion',
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
