import 'package:flutter/material.dart';
import 'package:smartnursery/shared/widgets/shared_bottom_navbar.dart';
import 'package:smartnursery/features/news-feed/screen/feed_page.dart';
import 'package:smartnursery/features/classes/screens/instance_classe.dart';
import 'package:smartnursery/shared/widgets/shared_header.dart';

class ClassesPage extends StatelessWidget {
  const ClassesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF9F9F9,
      ), // Fond clair d'après la maquette
      bottomNavigationBar: const SafeArea(
        top: false,
        child: SharedBottomNavbar(currentIndex: 4),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            SharedHeader(
              title: 'Classes',
              leftWidget: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 32,
              ),
              leftLabel: null,
              onLeftTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedPage()),
                );
              },
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  children: [
                    // Card 1 (Little Angels - Teal/Light Blue)
                    _ClassCard(
                      title: 'Little Angels',
                      ageGroup: '5 mois - 2 ans',
                      backgroundColor: const Color(0xFF7DF0FC), // Cyan clair
                      titleColor: const Color(0xFF0F5A4D),
                      subtitleColor: const Color(
                        0xFF0F5A4D,
                      ).withValues(alpha: 0.8),
                      imagePath: 'assets/icons/enfant_classe1.png',
                      classId: 'class_little_angels',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SmartNurseryClassPage(
                              classId: 'class_little_angels',
                              className: 'Little Angels',
                              classColor: Color(0xFF8BC34A),
                              classBgColor: Color(0xFFD7E8B8),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Card 2 (Young Explorers - Yellow)
                    _ClassCard(
                      title: 'Young\nExplorers',
                      ageGroup: '2 - 4 ans',
                      backgroundColor: const Color(0xFFFEE34F), // Jaune soleil
                      titleColor: const Color(0xFF6B5A00),
                      subtitleColor: const Color(
                        0xFF6B5A00,
                      ).withValues(alpha: 0.8),
                      imagePath: 'assets/icons/enfant-classe2.png',
                      classId: 'class_young_explorers',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SmartNurseryClassPage(
                              classId: 'class_young_explorers',
                              className: 'Young Explorers',
                              classColor: Color(0xFFC8A800),
                              classBgColor: Color(0xFFFFF8D0),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Card 3 (Future Stars - Red/Pink)
                    _ClassCard(
                      title: 'Future Stars',
                      ageGroup: '4 - 6 ans',
                      backgroundColor: const Color(0xFFFF8B9E), // Rose pastel
                      titleColor: const Color(0xFF7A1D1D),
                      subtitleColor: const Color(
                        0xFF7A1D1D,
                      ).withValues(alpha: 0.8),
                      imagePath: 'assets/icons/jeux-classe3.png',
                      classId: 'class_future_stars',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SmartNurseryClassPage(
                              classId: 'class_future_stars',
                              className: 'Future Stars',
                              classColor: Color(0xFFD04060),
                              classBgColor: Color(0xFFFFE0E8),
                            ),
                          ),
                        );
                      },
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


class _ClassCard extends StatelessWidget {
  final String title;
  final String ageGroup;
  final Color backgroundColor;
  final Color titleColor;
  final Color subtitleColor;
  final String imagePath;
  final String classId;
  final VoidCallback? onTap;

  const _ClassCard({
    required this.title,
    required this.ageGroup,
    required this.backgroundColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.imagePath,
    required this.classId,
    this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 8),
              blurRadius: 16,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Column: Text & Button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ageGroup,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // White Capsule Button "Entrer"
                  UnconstrainedBox(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Text(
                        'Entrer',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Right Column: Image with circular backdrop overlay
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.5),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    spreadRadius: 2,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    imagePath,
                    width: 70,
                    height: 70,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
