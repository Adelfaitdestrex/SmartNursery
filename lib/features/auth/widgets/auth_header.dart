import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';

/// The green-to-white wave header shared across auth screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, this.height = 220});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ClipPath(
        clipper: _WaveClipper(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.headerTop,
                AppColors.headerBottom,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);

    // First wave curve (dip)
    path.cubicTo(
      size.width * 0.15,
      size.height - 10,
      size.width * 0.3,
      size.height + 20,
      size.width * 0.5,
      size.height - 20,
    );

    // Second wave curve (rise)
    path.cubicTo(
      size.width * 0.7,
      size.height - 60,
      size.width * 0.85,
      size.height - 10,
      size.width,
      size.height - 30,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
