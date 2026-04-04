import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/shared/widgets/shared_bottom_navbar.dart';
import 'package:smartnursery/shared/widgets/shared_header.dart';
import 'package:smartnursery/features/news-feed/screen/feed_page.dart';

class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      bottomNavigationBar: const SafeArea(top: false, child: SharedBottomNavbar(currentIndex: 3)),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            SharedHeader(
              title: 'Activité',
              leftWidget: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
              leftLabel: null,
              onLeftTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedPage()),
                );
              },
            ),

            const SizedBox(height: 16),

            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top header intro
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1B941B),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/book-open-text-white-background.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Activité du jour',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Choisir une activité a explorer',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Add new activity card
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.activityCardAddBg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: Colors.black12, width: 1.0),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 24),
                          Image.asset(
                            'assets/icons/Icon.png', // Fallback as assumed grid icon
                            width: 60,
                            height: 60,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.grid_view_rounded, size: 50, color: Colors.orange);
                            },
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Ajouter une nouvelle activité',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Red Card
                    _buildActivityCard(
                      color: AppColors.activityCardRed,
                      textColor: Colors.white,
                    ),

                    const SizedBox(height: 16),

                    // Yellow Card
                    _buildActivityCard(
                      color: AppColors.activityCardYellow,
                      textColor: Colors.white, 
                    ),

                    const SizedBox(height: 16),

                    // Teal Card
                    _buildActivityCard(
                      color: AppColors.activityCardTeal,
                      textColor: Colors.white,
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required Color color,
    required Color textColor,
  }) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.black12, width: 1.0),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          // Left Icon
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/book-open-text-black-background.svg',
                width: 30,
                height: 30,
                colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Center Text
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activité du jour',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  'Choisir une activité a explorer',
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          // Right arrow button
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_forward,
              color: textColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}
