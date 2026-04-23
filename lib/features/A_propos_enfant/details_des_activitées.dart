import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/features/A_propos_enfant/redirection_info_enfant.dart';
import 'package:smartnursery/shared/widgets/shared_bottom_navbar.dart';
import 'package:smartnursery/shared/widgets/shared_header.dart';

class ActivityDetailsPage extends StatelessWidget {
  const ActivityDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkGreen = Color(0xFF55762A);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      bottomNavigationBar: const SafeArea(
        top: false,
        child: SharedBottomNavbar(currentIndex: 0),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SharedHeader(
              title: 'Details de l\'activite',
              leftWidget: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 32,
              ),
              leftLabel: null,
              onLeftTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ChildInfoScreen()),
                );
              },
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    // Carte image principale
                    _buildMainImageCard(),

                    const SizedBox(height: 20),

                    // الحاوية البيضاء الرئيسية للمعلومات
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // التوقيت والمدة
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoTile(
                                  "Horaire",
                                  "13h30 - 15h00",
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: _buildInfoTile("Durée", "1h 30")),
                            ],
                          ),
                          const SizedBox(height: 25),

                          // النص الوصفي مع الخط الجانبي
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 3,
                                height: 100,
                                color: Colors.green[200],
                              ),
                              const SizedBox(width: 15),
                              const Expanded(
                                child: Text(
                                  "Léo a fait une sieste paisible cet après-midi. Il s'est endormi rapidement au son d'une douce berceuse et ne s'est pas réveillé une seule fois.",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),

                          // الحالة والحرارة
                          _buildStatusRow(
                            Icons.sentiment_satisfied_alt,
                            "Réveil : Rafraîchi",
                          ),
                          const SizedBox(height: 10),
                          _buildStatusRow(
                            Icons.thermostat,
                            "Température : 21°C",
                          ),

                          const SizedBox(height: 25), // زر المشاركة
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text("Partager la mise à jour"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkGreen,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // المرحلة القادمة
                    const Text(
                      "PROCHAINE ÉTAPE",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF4D9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.restaurant, size: 18, color: darkGreen),
                          SizedBox(width: 10),
                          Text(
                            "Goûter à 16h00",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // صورة النشاط الرئيسية مع العنوان فوقها

  Widget _buildMainImageCard() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        image: const DecorationImage(
          image: NetworkImage(
            'https://via.placeholder.com/400x300',
          ), // ضع صورة الطفل النائم هنا
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        padding: const EdgeInsets.all(25),
        alignment: Alignment.bottomLeft,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.nights_stay, color: Colors.white, size: 16),
                SizedBox(width: 5),
                Text(
                  "Sommeil",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            Text(
              "Sieste de l'après-midi",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4ED),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAF5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[800], size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          const Icon(Icons.info_outline, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
