import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/features/A_propos_enfant/redirection_info_enfant.dart';
import 'package:smartnursery/shared/widgets/shared_bottom_navbar.dart';
import 'package:smartnursery/shared/widgets/shared_header.dart';
import 'package:smartnursery/features/A_propos_enfant/models/child_model.dart';
import 'package:smartnursery/features/activities/models/activity_model.dart';
import 'package:smartnursery/features/activities/widgets/activity_card.dart';

class ActivityDetailsPage extends StatelessWidget {
  final ChildModel child;
  const ActivityDetailsPage({super.key, required this.child});

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
              title: 'Activité de ${child.firstName}',
              leftWidget: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 32,
              ),
              leftLabel: null,
              onLeftTap: () {
                Navigator.pop(context);
              },
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('activities')
                    .where('participants', arrayContains: child.childId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: darkGreen),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "Aucune activité enregistrée pour le moment.",
                      ),
                    );
                  }

                  // Obtenir toutes les activités de l'enfant, triées par date (récente en premier)
                  final activities = snapshot.data!.docs
                      .map(
                        (doc) => ActivityModel.fromMap(
                          doc.data() as Map<String, dynamic>,
                          id: doc.id,
                        ),
                      )
                      .toList();
                  activities.sort((a, b) => b.date.compareTo(a.date));

                  // L'activité la plus récente à afficher en grand
                  final recentActivity = activities.first;

                  // Calculer la durée
                  final startTime = recentActivity.startTime;
                  final endTime = recentActivity.endTime;
                  int durationMinutes =
                      (endTime.hour * 60 + endTime.minute) -
                      (startTime.hour * 60 + startTime.minute);
                  if (durationMinutes < 0) durationMinutes += 24 * 60;
                  final hours = durationMinutes ~/ 60;
                  final mins = durationMinutes % 60;
                  final durationStr = hours > 0
                      ? '${hours}h ${mins > 0 ? mins : ''}'
                      : '${mins}m';

                  final timeStr =
                      '${startTime.hour.toString().padLeft(2, '0')}h${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}h${endTime.minute.toString().padLeft(2, '0')}';

                  String descStr = recentActivity.description;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        // Carte image principale avec le titre de l'activité
                        _buildMainImageCard(
                          recentActivity.title,
                          recentActivity.theme.backgroundColor,
                        ),

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
                                    child: _buildInfoTile("Horaire", timeStr),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildInfoTile("Durée", durationStr),
                                  ),
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
                                    color: recentActivity.theme.backgroundColor
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      descStr,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 25),

                              // الحالة والحرارة (statiques pour l'instant car non gérés dans ActivityModel)
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

                        // Bouton pour afficher toutes les activités de l'enfant
                        if (activities.length > 1)
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AllChildActivitiesPage(
                                    child: child,
                                    activities: activities,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.list_alt),
                            label: const Text(
                              "Voir toutes les activités de la journée",
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: darkGreen,
                              side: const BorderSide(color: darkGreen),
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
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
                              Icon(
                                Icons.restaurant,
                                size: 18,
                                color: darkGreen,
                              ),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainImageCard(String title, Color themeColor) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: BorderRadius.circular(40),
        image: const DecorationImage(
          image: NetworkImage(
            'https://via.placeholder.com/400x300',
          ), // Image statique pour l'instant
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.stars, color: themeColor, size: 16),
                const SizedBox(width: 5),
                const Text(
                  "Activité Récente",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            Text(
              title,
              style: const TextStyle(
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

class AllChildActivitiesPage extends StatelessWidget {
  final ChildModel child;
  final List<ActivityModel> activities;

  const AllChildActivitiesPage({
    super.key,
    required this.child,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            SharedHeader(
              title: 'Toutes les activités',
              leftWidget: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 32,
              ),
              leftLabel: null,
              onLeftTap: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  return ActivityCard(
                    activity: activities[index],
                    userRole: '',
                    userId: '',
                    nurseryId: child.nurseryId,
                    showManageButton: false,
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
