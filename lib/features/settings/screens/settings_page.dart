import 'package:flutter/material.dart';
import 'package:smartnursery/features/profile/screens/profile_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool pushEnabled = true;
  bool soundEnabled = true;
  bool profileVisible = true;
  bool parentalControlEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF3E8E2),
              Color(0xFFC0E4D0),
              Color(0xFFE0E6E2),
            ],
            stops: [0.0, 0.23558, 0.47115],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 18),
                const _Header(),
                const SizedBox(height: 18),
                const _TopActions(),
                const SizedBox(height: 22),
                _SectionCard(
                  title: 'Notification',
                  icon: Icons.notifications_active,
                  children: [
                    _SettingTile(
                      icon: Icons.notifications_none,
                      title: 'Notification\npush',
                      subtitle: 'Soyez informée des\nnouveautés',
                      value: pushEnabled,
                      onChanged: (v) => setState(() => pushEnabled = v),
                      outlined: true,
                    ),
                    const SizedBox(height: 12),
                    _SettingTile(
                      icon: Icons.volume_up_outlined,
                      title: 'Bruitage',
                      subtitle: 'Des sons et de la\nmusique amusants',
                      value: soundEnabled,
                      onChanged: (v) => setState(() => soundEnabled = v),
                      outlined: true,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  title: 'Confidentialité',
                  icon: Icons.lock,
                  children: [
                    _SettingTile(
                      icon: Icons.remove_red_eye_outlined,
                      title: 'Profil visible',
                      subtitle: 'Autoriser vos amis à\nvoir votre profil',
                      value: profileVisible,
                      onChanged: (v) => setState(() => profileVisible = v),
                      outlined: true,
                    ),
                    const SizedBox(height: 12),
                    _SettingTile(
                      icon: Icons.security_outlined,
                      title: 'Contrôle\nparental',
                      subtitle: 'Que tout reste sur et\namusant',
                      value: parentalControlEnabled,
                      onChanged: (v) => setState(() => parentalControlEnabled = v),
                      outlined: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, color: Color(0xFF63A6E8), size: 44),
            SizedBox(width: 10),
            Text(
              'Paramétres',
              style: TextStyle(
                fontSize: 48 / 1.4,
                fontWeight: FontWeight.w700,
                color: Color(0xCC000000),
                shadows: [Shadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 4)],
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.build, color: Color(0xFF63A6E8), size: 38),
          ],
        ),
        SizedBox(height: 6),
        Text(
          'Personnalisez votre expérience',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0x4D000000)),
        ),
      ],
    );
  }
}

class _TopActions extends StatelessWidget {
  const _TopActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: Container(
                height: 93,
                decoration: BoxDecoration(
                  color: const Color(0xE0FFFFFF),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: const [BoxShadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 4)],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_outline, size: 28),
                    SizedBox(width: 8),
                    Text('Mon\nprofil', style: TextStyle(fontSize: 36 / 1.8, fontWeight: FontWeight.w600, color: Color(0xA3000000))),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFF89B832),
                borderRadius: BorderRadius.circular(40),
                boxShadow: const [BoxShadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 4)],
              ),
              child: const Center(
                child: Text('Paramétres', style: TextStyle(fontSize: 16, color: Colors.black)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 348,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 4)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFF3C21D), size: 34),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xB8000000),
                  shadows: [Shadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 4)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool outlined;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 274,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFF),
        borderRadius: BorderRadius.circular(30),
        border: outlined ? Border.all(color: const Color(0x38000000)) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF23C9CF), size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 38 / 1.9, fontWeight: FontWeight.w700, color: Color(0xB3000000))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0x40000000))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF89B832),
            activeThumbColor: const Color(0xFFF5F8FF),
          ),
        ],
      ),
    );
  }
}
