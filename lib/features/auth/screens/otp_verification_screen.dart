import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/features/auth/widgets/auth_header.dart';
import 'package:smartnursery/features/auth/screens/password_change_screen.dart';
import 'package:smartnursery/features/auth/auth_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String expectedOtp;
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.expectedOtp,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _otpLength = 6;

  late String _currentOtp;
  bool _isResending = false;
  int _resendCountdown = 0;
  bool _canResend = true;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();
    _currentOtp = widget.expectedOtp;
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _onConfirm() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == _otpLength) {
      if (AuthService.verifyOtp(otp, _currentOtp)) {
        // OTP is correct, navigate to password change screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PasswordChangeScreen(email: widget.email),
          ),
        );
      } else {
        // OTP is incorrect
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code de vérification incorrect'),
            backgroundColor: Colors.red,
          ),
        );
        // Clear the OTP fields for retry
        for (final controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer le code complet'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// Renvoyer le code OTP à l'email
  Future<void> _onResend() async {
    if (!_canResend) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veuillez attendre $_resendCountdown secondes avant de renvoyer',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isResending = true);

    try {
      // Demander un nouveau code OTP
      final result = await AuthService.requestPasswordReset(widget.email);

      if (!mounted) return;

      if (result['success'] == true) {
        _currentOtp = result['otp'] as String;

        // Effacer les champs OTP
        for (final controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nouveau code envoyé à votre email !'),
            backgroundColor: Colors.green,
          ),
        );

        // Démarrer le compte à rebours de 60 secondes
        _startResendCountdown();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur lors du renvoi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  /// Démarrer le compte à rebours de 60 secondes avant de permettre un autre renvoi
  void _startResendCountdown() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _resendCountdown--);
        if (_resendCountdown > 0) {
          _startResendCountdown();
        } else {
          setState(() => _canResend = true);
        }
      }
    });
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  // Title
                  const Text(
                    'Code de vérification',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.authTitle,
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  const Text(
                    'Entrez le code de vérification envoyé à\nvotre e-mail',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.authSubtitle,
                  ),

                  const SizedBox(height: 36),

                  // OTP boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_otpLength, (index) {
                      return _OtpBox(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        onChanged: (v) => _onOtpChanged(index, v),
                      );
                    }),
                  ),

                  const SizedBox(height: 40),

                  // Confirm button
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: const BoxDecoration(
                      boxShadow: AppShadows.primaryButton,
                    ),
                    child: ElevatedButton(
                      onPressed: _onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirmer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Resend row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "vous n'avez pas  reçu le code ? ",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.borderInactive,
                        ),
                      ),
                      GestureDetector(
                        onTap: _canResend ? _onResend : null,
                        child: Text(
                          _canResend
                              ? 'Renvoyer le code'
                              : 'Renvoyer dans $_resendCountdown s',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _canResend
                                ? AppColors.textLink
                                : AppColors.borderInactive,
                          ),
                        ),
                      ),
                      if (_isResending) ...[
                        const SizedBox(width: 8),
                        const SizedBox(
                          height: 12,
                          width: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textLink,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 40),

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
          ],
        ),
      ),
    );
  }
}

// ── Individual OTP box ────────────────────────────────────────────────────────
class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 52,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.titleText,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.authPageBackground,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderInactive),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderInactive),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.primaryButton,
              width: 1.8,
            ),
          ),
        ),
      ),
    );
  }
}
