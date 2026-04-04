import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/shared/widgets/shared_bottom_navbar.dart';
import 'package:smartnursery/shared/widgets/shared_header.dart';
import 'package:smartnursery/features/news-feed/screen/feed_page.dart';

class CantinePage extends StatefulWidget {
  const CantinePage({super.key});

  @override
  State<CantinePage> createState() => _CantinePageState();
}

class _CantinePageState extends State<CantinePage> {
  final List<String> filters = ['Tout', 'vegetarien', 'viande', 'poisson'];
  int selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      bottomNavigationBar: const SafeArea(top: false, child: SharedBottomNavbar(currentIndex: 1)),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            SharedHeader(
              title: 'Cantine',
              leftWidget: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
              leftLabel: null,
              onLeftTap: () {
                // Navigate back to FeedPage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedPage()),
                );
              },
            ),
            
            const SizedBox(height: 16),

            // Filter row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cantineFilterBg,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.bottomNavBorder, width: 0.5),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      filters.length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFilterIndex = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.cantineChipBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selectedFilterIndex == index 
                                  ? Colors.black 
                                  : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              filters[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Food Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75, // Adjust width to height ratio
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'nom_du_plat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        // Circular placeholder
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  // This creates the checkerboard effect shown in Figma
                                  image: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/4/47/PNG_transparency_demonstration_1.png'),
                                  fit: BoxFit.cover,
                                  opacity: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.favorite_border, color: Colors.black, size: 24),
                            Text(
                              'add',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
