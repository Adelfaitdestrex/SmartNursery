import 'package:flutter/material.dart';
import 'package:smartnursery/features/classes/models/class_model.dart';
import 'package:smartnursery/shared/widgets/shared_bottom_navbar.dart';
import 'package:smartnursery/features/news-feed/screen/feed_page.dart';
import 'package:smartnursery/features/classes/screens/instance_classe.dart';
import 'package:smartnursery/features/classes/services/class_service.dart';
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
              child: StreamBuilder<List<ClassModel>>(
                stream: ClassService().getClassesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Impossible de charger les classes.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final classes = snapshot.data ?? [];

                  if (classes.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Aucune classe disponible pour le moment.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    itemCount: classes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      final classData = classes[index];
                      final visual = _ClassVisual.fromClass(classData, index);

                      return _ClassCard(
                        title: classData.name,
                        ageGroup: classData.ageRange,
                        backgroundColor: visual.backgroundColor,
                        titleColor: visual.titleColor,
                        subtitleColor: visual.subtitleColor,
                        imagePath: visual.imagePath,
                        classId: classData.classId,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SmartNurseryClassPage(
                                classId: classData.classId,
                                className: classData.name,
                                classColor: visual.classColor,
                                classBgColor: visual.classBgColor,
                              ),
                            ),
                          );
                        },
                      );
                    },
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

class _ClassVisual {
  final Color backgroundColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color classColor;
  final Color classBgColor;
  final String imagePath;

  const _ClassVisual({
    required this.backgroundColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.classColor,
    required this.classBgColor,
    required this.imagePath,
  });

  static const List<String> _fallbackImages = [
    'assets/icons/enfant_classe1.png',
    'assets/icons/enfant-classe2.png',
    'assets/icons/jeux-classe3.png',
  ];

  static _ClassVisual fromClass(ClassModel classData, int index) {
    final bg = _hexToColor(classData.color) ?? _fallbackBg(index);
    
    Color title;
    final hexColor = classData.color?.toUpperCase() ?? '';
    if (hexColor == '#7DF0FC') {
      title = const Color(0xFF0F5A4D);
    } else if (hexColor == '#FEE34F') {
      title = const Color(0xFF6B5A00);
    } else if (hexColor == '#FF8B9E') {
      title = const Color(0xFF7A1D1D);
    } else {
      title = _isDark(bg) ? Colors.white : const Color(0xFF1C1C1C);
    }

    final subtitle = title.withValues(alpha: 0.8);
    final classColor = _darken(bg, 0.30);
    final classBgColor = _lighten(bg, 0.35);

    return _ClassVisual(
      backgroundColor: bg,
      titleColor: title,
      subtitleColor: subtitle,
      classColor: classColor,
      classBgColor: classBgColor,
      imagePath: _imageForTemplate(classData.classTemplate, index),
    );
  }

  static String _imageForTemplate(String? template, int index) {
    final key = (template ?? '').toLowerCase();
    if (key.contains('angel')) return _fallbackImages[0];
    if (key.contains('explorer')) return _fallbackImages[1];
    if (key.contains('star')) return _fallbackImages[2];
    return _fallbackImages[index % _fallbackImages.length];
  }

  static Color? _hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceFirst('#', '').trim();
    if (cleaned.length != 6) return null;
    return Color(int.parse('0xFF$cleaned'));
  }

  static Color _fallbackBg(int index) {
    const colors = [Color(0xFF7DF0FC), Color(0xFFFEE34F), Color(0xFFFF8B9E)];
    return colors[index % colors.length];
  }

  static bool _isDark(Color color) {
    return color.computeLuminance() < 0.55;
  }

  static Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final darker = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darker.toColor();
  }

  static Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lighter = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return lighter.toColor();
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
