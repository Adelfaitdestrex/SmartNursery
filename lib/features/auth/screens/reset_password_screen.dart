import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/features/auth/screens/otp_verification_screen.dart';
import 'package:smartnursery/features/auth/widgets/auth_header.dart';
import 'package:smartnursery/features/auth/widgets/auth_text_field.dart';
import 'package:smartnursery/features/auth/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final email = _emailController.text.trim();

      // Request password reset with OTP
      final result = await AuthService.requestPasswordReset(email);

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (result['success'] == true) {
        // Email sent successfully, show confirmation dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Email envoyé'),
            content: Text(
              'Un code de vérification a été envoyé à $email.\n\n'
              'Vérifiez votre boîte mail et entrez le code dans l\'écran suivant.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        if (!mounted) return;

        // Navigate to OTP verification
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(email: email),
          ),
        );
      } else {
        // Email failed to send
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Une erreur s\'est produite'),
            backgroundColor: Colors.red,
          ),
        );
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
                  // Positioned similarly to Figma coordinates overlaying the wave
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
                      'Réinitialiser votre mot de passe',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.authTitle,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Entrez votre adresse e-mail pour recevoir un lien de réinitialisation.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedText,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Email field
                    AuthTextField(
                      hint: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Image.asset(
                        'assets/icons/email.png',
                        width: 26,
                        height: 26,
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Veuillez entrer votre email'
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
                                'Envoyer le lien',
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
