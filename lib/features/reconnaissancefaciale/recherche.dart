import 'package:flutter/material.dart';
import 'dart:math' as math;

class RechercheFacePage extends StatelessWidget {
  const RechercheFacePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFFBFEF9);
    const Color headerColor = Color(0xFFA2D642);
    const Color buttonColor = Color(0xFF88C043);
    const Color darkText = Color(0xFF28352E);
    const Color mediumText = Color(0xFF546259);
    const Color infoBg = Color(0xFFECF6ED);
    const Color greenAccent = Color(0xFFA2D642);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            /// HEADER FULL WIDTH
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 110,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: headerColor,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.only(top: 10, left: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Reconnaissance faciale',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// CONTENU FULL WIDTH
            Positioned.fill(
              child: SingleChildScrollView(
                child: Center(
                  // ✅ IMPORTANT : force le centrage global
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 500, // ✅ limite propre sur web (design centré)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 140, 24, 150),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                          const Text(
                            "Vérification d'identité",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: darkText,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Placez votre visage dans le cadre pour\nsécuriser votre accès à la plateforme.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: mediumText,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 40),

                          /// CADRE CAMERA
                          Center(
                            child: SizedBox(
                              width: 260,
                              height: 260,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CustomPaint(
                                    size: const Size(260, 260),
                                    painter: DashedCirclePainter(
                                      color: Color.fromRGBO(0, 111, 29, 0.2),
                                      strokeWidth: 4,
                                      dashWidth: 10,
                                      dashSpace: 10,
                                    ),
                                  ),
                                  Container(
                                    width: 236,
                                    height: 236,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: greenAccent,
                                        width: 4,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        'https://images.unsplash.com/photo-1542909168-82c3e7fdca5c?auto=format&fit=crop&w=500&q=60',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 45),

                          /// INFO BOX
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                        color: infoBg,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.wb_sunny_outlined,
                                            color: mediumText,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Assurez-vous d'être dans un\nendroit bien éclairé.",
                                    style: TextStyle(
                                              color: mediumText,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// FOOTER FULL WIDTH
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 35),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(40, 53, 46, 0.06),
                      blurRadius: 32,
                      offset: Offset(0, -12),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Annuler"),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("Commencer"),
                      ),
                    ),
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

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashWidth = 5.0,
    this.dashSpace = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final radius = size.width / 2;
    final circumference = 2 * math.pi * radius;
    final count = (circumference / (dashWidth + dashSpace)).floor();
    final sweepAngle = (dashWidth / circumference) * 2 * math.pi;
    final gapAngle = (dashSpace / circumference) * 2 * math.pi;

    for (int i = 0; i < count; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius),
        i * (sweepAngle + gapAngle),
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
