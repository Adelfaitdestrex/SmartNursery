import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/shared/widgets/shared_bottom_navbar.dart';
import 'package:smartnursery/shared/widgets/shared_header.dart';
import 'package:smartnursery/features/news-feed/screen/feed_page.dart';

class ClassesPage extends StatelessWidget {
  const ClassesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      bottomNavigationBar: const SafeArea(top: false, child: SharedBottomNavbar(currentIndex: 4)),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            SharedHeader(
              title: 'Classes',
              leftWidget: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
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
                padding: const EdgeInsets.only(top: 24, bottom: 40),
                child: Column(
                  children: [
                    // Card 1 (Little Angels - Teal)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: _ClassCard(
                          title: 'Little Angels',
                          ageGroup: '5 mois-2 ans',
                          backgroundColor: AppColors.activityCardTeal,
                          titleColor: const Color(0xFF0F5A4D),
                          buttonColor: const Color(0xFF48C9B0), // It usually is slightly offset from bg, let's use a similar or lighter teal
                          imagePath: 'assets/icons/enfant_classe1.png',
                          imageWidth: 60,
                          imageHeight: 60,
                          topOffset: -20,
                          leftOffset: -20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Card 2 (Young Explorers - Yellow)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: _ClassCard(
                          title: 'Young Explorers',
                          ageGroup: '2 - 4 ans',
                          backgroundColor: AppColors.activityCardYellow,
                          titleColor: const Color(0xFF6B5A00),
                          buttonColor: const Color(0xFFFFD54F),
                          imagePath: 'assets/icons/enfant-classe2.png',
                          imageWidth: 65,
                          imageHeight: 65,
                          topOffset: -20,
                          leftOffset: -10,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Card 3 (Future Stars - Red)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: _ClassCard(
                          title: 'Future Stars',
                          ageGroup: '4 - 6 ans',
                          backgroundColor: AppColors.activityCardRed,
                          titleColor: const Color(0xFF7A1D1D),
                          buttonColor: const Color(0xFFFF7B7B),
                          imagePath: 'assets/icons/jeux-classe3.png',
                          imageWidth: 50,
                          imageHeight: 50,
                          topOffset: -15,
                          leftOffset: -15,
                        ),
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

class _ClassCard extends StatelessWidget {
  final String title;
  final String ageGroup;
  final Color backgroundColor;
  final Color titleColor;
  final Color buttonColor;
  final String imagePath;
  final double imageWidth;
  final double imageHeight;
  final double topOffset;
  final double leftOffset;

  const _ClassCard({
    required this.title,
    required this.ageGroup,
    required this.backgroundColor,
    required this.titleColor,
    required this.buttonColor,
    required this.imagePath,
    required this.imageWidth,
    required this.imageHeight,
    required this.topOffset,
    required this.leftOffset,
  });

  @override
  Widget build(BuildContext context) {
    // We add margin so the Positioned image doesn't get cut off by screen edges
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Card Container
        Container(
          width: 260,
          margin: const EdgeInsets.only(top: 15, left: 15), // Reserve space for the image sticking out
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
            // A dark shadow representing the card border offset shown in figma
            border: Border.all(color: Colors.black12, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: titleColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                ageGroup,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // Button "Entrer"
              Container(
                width: 140,
                height: 40,
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Entrer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Floating Image
        Positioned(
          top: topOffset,
          left: leftOffset,
          child: Image.asset(
            imagePath,
            width: imageWidth,
            height: imageHeight,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.image_not_supported, 
              size: 40,
              color: Colors.black45,
            ),
          ),
        ),
      ],
    );
  }
}
