import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/shared/widgets/shared_bottom_navbar.dart';
import 'package:smartnursery/shared/widgets/shared_header.dart';
import 'package:smartnursery/features/A_propos_enfant/redirection_info_enfant.dart';

class FoodJournalPage extends StatelessWidget {
  const FoodJournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color mainGreen = Color(0xFF55762A);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      bottomNavigationBar: const SafeArea(
        top: false,
        child: SharedBottomNavbar(currentIndex: 0),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            SharedHeader(
              title: 'Journal alimentaire',
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

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "JOURNAL ALIMENTAIRE",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "L'heure du délicieux\ndéjeuner",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // بطاقة الوجبة الرئيسية
                  _buildMealCard(),

                  const SizedBox(height: 20),

                  // بطاقة مشاركة الفرحة (الخضراء)
                  _buildShareCard(mainGreen),

                  const SizedBox(height: 20),

                  // بطاقة الترطيب (Hydratation)
                  _buildHydrationCard(),

                  const SizedBox(height: 25),

                  // قسم الجدول الزمني (Emploi du temps)
                  const Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: mainGreen,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Emploi du temps quotidien",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildScheduleItem(
                    Icons.nightlight_round,
                    "Sieste de l'après-midi",
                    "Prévue à 14:30 • 1h 30m",
                    true,
                  ),
                  const SizedBox(height: 10),
                  _buildScheduleItem(
                    Icons.check_circle_outline,
                    "Sommeil du matin",
                    "Terminé à 11:00 • 45m",
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بطاقة الوجبة

  Widget _buildMealCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
          Image.network(
            'https://via.placeholder.com/200x150',
            height: 150,
          ), // استبدلها بصورة كرتونية
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFD4E1A1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "BIOLOGIQUE",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Leo a apprécié une portion de purée de patates douces biologiques et quelques tranches de pommes croquantes aujourd'hui.",
            style: TextStyle(color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 20),
          _buildMealInfoRow("CONSOMMATION", "180 ml", null),
          const SizedBox(height: 10),
          _buildMealInfoRow(
            "HUMEUR",
            "Enchanté",
            Icons.sentiment_very_satisfied,
          ),
        ],
      ),
    );
  }

  Widget _buildMealInfoRow(String label, String value, IconData? icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4ED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
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
              Row(
                children: [
                  if (icon != null) Icon(icon, size: 16, color: Colors.green),
                  if (icon != null) const SizedBox(width: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  } // بطاقة المشاركة الخضراء

  Widget _buildShareCard(Color color) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Partagez la joie",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Envoyez une mise à jour instantanée aux grands-parents ou au pédiatre.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () {},
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Partager la mise à jour",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                Icon(Icons.send_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بطاقة الترطيب
  Widget _buildHydrationCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF4D9),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hydratation",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Objectif quotidien : 600ml",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.water_drop_outlined,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.7,
              minHeight: 12,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF55762A)),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "70% de l'objectif atteint",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  } // مكوّن عنصر الجدول الزمني

  Widget _buildScheduleItem(
    IconData icon,
    String title,
    String time,
    bool hasArrow,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF1F4ED),
            child: Icon(icon, color: Colors.green[800]),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          if (hasArrow)
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}
