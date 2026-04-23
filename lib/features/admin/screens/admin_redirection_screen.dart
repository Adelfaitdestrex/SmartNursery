import 'dart:ui';
import 'package:flutter/material.dart';
import 'admin_settings_screen.dart';
import 'admin_users_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_add_user_screen.dart';
import 'admin_manage_classes_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5), // Fond principal
      body: Stack(
        children: [
          // Effets flous en arrière-plan
          Positioned(
            top: -50,
            left: -50,
            child: _buildBlob(
              const Color(0xFF9DEEC4).withValues(alpha: 0.5),
              300,
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: _buildBlob(
              const Color(0xFFCDE5FF).withValues(alpha: 0.5),
              350,
            ),
          ),
          Positioned(
            top: 400,
            left: -150,
            child: _buildBlob(
              const Color(0xFFFCDC98).withValues(alpha: 0.3),
              400,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 40,
                top: 16,
              ),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 32),
                  _buildProfileCard(context),
                  const SizedBox(height: 24),
                  _buildActionCards(context),
                  const SizedBox(height: 16),
                  _buildSummaryCards(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(Color color, double size) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF34322F).withValues(alpha: 0.06),
            offset: const Offset(0, 10),
            blurRadius: 40,
            spreadRadius: -15,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bouton Retour
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF156C4C)),
            ),
          ),
          // Titre
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Bienvenue dans le mode\nadmin !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF156C4C),
                  height: 1.2,
                ),
              ),
            ),
          ),
          // Notification
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF9DEEC4).withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF156C4C),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF34322F).withValues(alpha: 0.06),
            offset: const Offset(0, 40),
            blurRadius: 40,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9DEEC4).withValues(alpha: 0.4),
                  blurRadius: 24,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white,
              child: const CircleAvatar(
                radius: 44,
                backgroundColor: Color(
                  0xFF1B2C3A,
                ), // Couleur sombre en fond de l'avatar
                // Simulation de l'avatar Admin
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Textes
          const Text(
            'Mon Profil',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF156C4C),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Voir et modifier votre profil',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xCC615F5B),
            ),
          ),
          const SizedBox(height: 24),
          // Bouton
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF156C4C), Color(0xFF005F41)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 6,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: const Text(
                'Gérer le compte',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Column(
      children: [
        _buildActionCard(
          context,
          title: 'Gérer les\nclasses',
          subtitle: 'Organisez les groupes\net les activités',
          icon: Icons.menu_book_rounded,
          iconBgColor: const Color(0xFFCDE5FF),
          rotation: 0.05,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminManageClassesScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          context,
          title: 'Gérer les\nutilisateurs',
          subtitle: 'Parents, enseignants et\npersonnel',
          icon: Icons.groups_rounded,
          iconBgColor: const Color(0xFFFCDC98),
          rotation: -0.03,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          context,
          title: 'Dashboard\n',
          subtitle: 'Statistiques et rapports\nd\'activité',
          icon: Icons.bar_chart_rounded,
          iconBgColor: const Color(0xFF9DEEC4),
          rotation: 0.02,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          },
        ),
        const SizedBox(height: 16),
        // 4ème carte ajoutée pour conserver la logique "Créer Utilisateur"
        _buildActionCard(
          context,
          title: 'Créer\nUtilisateur',
          subtitle: 'Ajouter un nouveau\ncompte membre',
          icon: Icons.person_add_rounded,
          iconBgColor: const Color(0xFFE2C4FF), // Violet clair pastel
          rotation: -0.04,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminAddUserScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required double rotation,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F3EF),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              offset: const Offset(0, 5),
              blurRadius: 15,
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône avec fond tourné
            Transform.rotate(
              angle: rotation,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.black87, size: 32),
              ),
            ),
            const SizedBox(width: 20),
            // Textes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF34322F),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF615F5B),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            // Flèche
            const Icon(Icons.chevron_right_rounded, color: Color(0x6634322F)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard('128', 'ENFANTS', const Color(0xFF156C4C)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard('12', 'CLASSES', const Color(0xFF31638A)),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String number, String label, Color numberColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: numberColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF615F5B),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
