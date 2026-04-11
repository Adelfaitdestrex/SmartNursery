import 'package:flutter/material.dart';
import 'admin_settings_screen.dart';
import 'admin_users_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_add_user_screen.dart';
import '../../classes/screens/classes_page.dart';
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Column(
            children: [
              const SizedBox(height: 5),

              // ─── Header ───────────────────────────────────────────────
              _AdminHeader(),

              const SizedBox(height: 50),

              // ─── Mon Profil ───────────────────────────────────────────
              _AdminMenuItem(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
                  );
                },
                child: Row(
                  children: [
                    // Purple avatar circle with initial "G"
                    Container(
                      width: 61,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6868E1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text(
                        'Mon Profil',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0x40000000),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ─── Gérer les classes ────────────────────────────────────
              _AdminMenuItem(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
                  );
                },
                child: Row(
                  children: [
                    // Backpack icon (from Material Icons as a close equivalent)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.backpack_outlined,
                        size: 50,
                        color: Color(0xFF5BA5C8),
                      ),
                    ),
                    const SizedBox(width: 31),
                    const Expanded(
                      child: Text(
                        'Gérer les classes',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0x40000000),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ─── Gérer les utilisateurs ───────────────────────────────
              _AdminMenuItem(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
                  );
                },
                child: Row(
                  children: [
                    // Users icon
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: Icon(
                        Icons.group_outlined,
                        size: 50,
                        color: Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(width: 30),
                    const Expanded(
                      child: Text(
                        'Gérer les\nutilisateurs',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0x40000000),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ─── Dashboard ────────────────────────────────────────────
              _AdminMenuItem(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                  );
                },
                child: Row(
                  children: [
                    // Dashboard / layout icon
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: Icon(
                        Icons.dashboard_outlined,
                        size: 50,
                        color: Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(width: 30),
                    const Expanded(
                      child: Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0x40000000),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ─── Créer un Utilisateur ────────────────────────────────────────────
              _AdminMenuItem(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminAddUserScreen()),
                  );
                },
                child: Row(
                  children: [
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: Icon(
                        Icons.person_add_outlined,
                        size: 50,
                        color: Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(width: 30),
                    const Expanded(
                      child: Text(
                        'Créer Utilisateur',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0x40000000),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header widget: back arrow + title
// ─────────────────────────────────────────────────────────────────────────────
class _AdminHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 42),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x80000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button circle
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x20000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(color: const Color(0x1F000000)),
              ),
              child: const Center(
                child: Icon(Icons.arrow_back, size: 24, color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          const Expanded(
            child: Text(
              'Bienvenue dans le mode admin !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable menu item card
// ─────────────────────────────────────────────────────────────────────────────
class _AdminMenuItem extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AdminMenuItem({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFBFF),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0x38000000)),
        ),
        child: child,
      ),
    );
  }
}
