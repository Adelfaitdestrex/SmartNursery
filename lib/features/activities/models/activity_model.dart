import 'package:flutter/material.dart';

enum ActivityStatus { enCours, terminee, aVenir }

// ─── Theme data ──────────────────────────────────────────────────────────────

class ActivityTheme {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;
  final Color statusBadgeBg;
  final Color statusBadgeText;
  final Color statusBadgeBorder;
  final Color separatorColor;

  const ActivityTheme({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    required this.statusBadgeBg,
    required this.statusBadgeText,
    required this.statusBadgeBorder,
    required this.separatorColor,
  });
}

/// Catalogue centralisé des thèmes visuels.
/// Chaque clé correspond à la valeur stockée dans Firestore : `themeKey`.
class ActivityThemes {
  static const Map<String, ActivityTheme> _themes = {
    'red': ActivityTheme(
      backgroundColor: Color(0xA6FF6B6A),
      borderColor: Color(0xFFFFE4E6),
      iconBackgroundColor: Color(0xFFFECDD3),
      statusBadgeBg: Color(0xFFFFE4E6),
      statusBadgeText: Color(0xFFBE123C),
      statusBadgeBorder: Color(0xFFFECDD3),
      separatorColor: Color(0x80FFE4E6),
    ),
    'blue': ActivityTheme(
      backgroundColor: Color(0xFF55AAD8),
      borderColor: Color(0xFF4CCDC5),
      iconBackgroundColor: Color(0xFFBAE6FD),
      statusBadgeBg: Color(0xFFC0E8FC),
      statusBadgeText: Color(0xFF1C78A9),
      statusBadgeBorder: Color(0x33006F1D),
      separatorColor: Color(0x80E0F2FE),
    ),
    'purple': ActivityTheme(
      backgroundColor: Color(0xCCD4ABFD),
      borderColor: Color(0xFFF3E8FF),
      iconBackgroundColor: Color(0xFFE9D5FF),
      statusBadgeBg: Color(0xFFE9D5FF),
      statusBadgeText: Color(0xFF7E22CE),
      statusBadgeBorder: Color(0xFFC8ADE0),
      separatorColor: Color(0x80F3E8FF),
    ),
    'orange': ActivityTheme(
      backgroundColor: Color(0xFFFEDB53),
      borderColor: Color(0xFFFFEDD5),
      iconBackgroundColor: Color(0xFFFED7AA),
      statusBadgeBg: Color(0xFFFFEDD5),
      statusBadgeText: Color(0xFFC2410C),
      statusBadgeBorder: Color(0xFFFED7AA),
      separatorColor: Color(0x80FFEDD5),
    ),
    'green': ActivityTheme(
      backgroundColor: Color(0xCC61FCB3),
      borderColor: Color(0xFF95F1C2),
      iconBackgroundColor: Color(0xFFA7F3D0),
      statusBadgeBg: Color(0xFFD1FAE5),
      statusBadgeText: Color(0xFF047857),
      statusBadgeBorder: Color(0xFFA7F3D0),
      separatorColor: Color(0x80D1FAE5),
    ),
    'amber': ActivityTheme(
      backgroundColor: Color(0xCCFAE07B),
      borderColor: Color(0xFFFEF3C7),
      iconBackgroundColor: Color(0xFFFDE68A),
      statusBadgeBg: Color(0xFFFEF3C7),
      statusBadgeText: Color(0xFFB45309),
      statusBadgeBorder: Color(0xFFFDE68A),
      separatorColor: Color(0x80FEF3C7),
    ),
  };

  static ActivityTheme fromKey(String key) =>
      _themes[key] ?? _themes['green']!;

  /// Toutes les clés disponibles (utile pour un sélecteur de thème).
  static List<String> get keys => _themes.keys.toList();
}

// ─── Model ───────────────────────────────────────────────────────────────────

class ActivityModel {
  /// Identifiant du document Firestore (null pour les données locales/dummy).
  final String? id;
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String description;
  final String author;

  /// Clé de thème visuel (ex. 'green', 'red', 'blue' ...).
  /// C'est cette valeur qui est stockée dans Firestore.
  final String themeKey;

  ActivityModel({
    this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.author,
    this.themeKey = 'green',
  });

  // ── Getters dérivés ──────────────────────────────────────────────────────

  ActivityTheme get theme => ActivityThemes.fromKey(themeKey);

  ActivityStatus get status {
    final now = DateTime.now();
    final actDate = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    if (actDate.isBefore(today)) {
      return ActivityStatus.terminee;
    } else if (actDate.isAfter(today)) {
      return ActivityStatus.aVenir;
    } else {
      final start = DateTime(
          now.year, now.month, now.day, startTime.hour, startTime.minute);
      final end =
          DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);
      if (now.isBefore(start)) return ActivityStatus.aVenir;
      if (now.isAfter(end)) return ActivityStatus.terminee;
      return ActivityStatus.enCours;
    }
  }

  String get time =>
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}'
      ' - '
      '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

  // ── Sérialisation Firestore ──────────────────────────────────────────────

  /// Convertit le modèle en Map de types primitifs compatibles Firestore.
  /// La date est stockée en millisecondes (int) pour éviter toute dépendance
  /// directe à `cloud_firestore.Timestamp` dans le modèle.
  /// Côté repository, vous pouvez remplacer `date` par `Timestamp.fromMillisecondsSinceEpoch(map['date'])`.
  Map<String, dynamic> toMap() => {
        'title': title,
        'date': date.millisecondsSinceEpoch, // int → Timestamp Firestore-compatible
        'startHour': startTime.hour,
        'startMinute': startTime.minute,
        'endHour': endTime.hour,
        'endMinute': endTime.minute,
        'description': description,
        'author': author,
        'themeKey': themeKey,
      };

  /// Reconstruit un [ActivityModel] depuis un document Firestore.
  /// [id] correspond à `doc.id`.
  /// Si la date vient d'un Timestamp Firestore, passez `timestamp.millisecondsSinceEpoch`.
  factory ActivityModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ActivityModel(
      id: id,
      title: map['title'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      startTime: TimeOfDay(
        hour: map['startHour'] as int,
        minute: map['startMinute'] as int,
      ),
      endTime: TimeOfDay(
        hour: map['endHour'] as int,
        minute: map['endMinute'] as int,
      ),
      description: map['description'] as String,
      author: map['author'] as String,
      themeKey: (map['themeKey'] as String?) ?? 'green',
    );
  }

  // ── copyWith ─────────────────────────────────────────────────────────────

  ActivityModel copyWith({
    String? id,
    String? title,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? description,
    String? author,
    String? themeKey,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      author: author ?? this.author,
      themeKey: themeKey ?? this.themeKey,
    );
  }
}

// ─── Données de démonstration ────────────────────────────────────────────────

final _now = DateTime.now();

final List<ActivityModel> dummyActivities = [
  ActivityModel(
    title: 'Atelier Dessin & Coloriage 🎨',
    date: _now,
    startTime: TimeOfDay(hour: _now.hour, minute: _now.minute >= 30 ? 0 : 30),
    endTime: TimeOfDay(hour: _now.hour + 1, minute: 30),
    description:
        'Exploration des couleurs primaires et\ncréation d\'une fresque murale collective.',
    author: 'Mme. Sophie — Littel Angels',
    themeKey: 'red',
  ),
  ActivityModel(
    title: 'Heure du Conte 📖',
    date: _now.subtract(const Duration(days: 1)),
    startTime: const TimeOfDay(hour: 8, minute: 30),
    endTime: const TimeOfDay(hour: 9, minute: 30),
    description:
        '"Le Petit Nuage Voyageur" : lecture\ninteractive et questions-réponses.',
    author: 'M. Thomas — Young Explorers',
    themeKey: 'blue',
  ),
  ActivityModel(
    title: 'Éveil Musical & Chant 🎵',
    date: _now.add(const Duration(days: 1)),
    startTime: const TimeOfDay(hour: 14, minute: 30),
    endTime: const TimeOfDay(hour: 15, minute: 30),
    description:
        'Découverte des percussions et\napprentissage de comptines rythmées.',
    author: 'Mme. Claire — Future Stars',
    themeKey: 'purple',
  ),
  ActivityModel(
    title: 'Jeux Extérieurs ⚽',
    date: _now.add(const Duration(days: 1)),
    startTime: const TimeOfDay(hour: 15, minute: 45),
    endTime: const TimeOfDay(hour: 16, minute: 30),
    description:
        'Parcours de motricité et jeux de ballon dans\nla cour de récréation.',
    author: 'M. Thomas — Littel Angel',
    themeKey: 'orange',
  ),
  ActivityModel(
    title: 'Puzzles & Logique 🧩',
    date: _now.add(const Duration(days: 2)),
    startTime: const TimeOfDay(hour: 16, minute: 30),
    endTime: const TimeOfDay(hour: 17, minute: 15),
    description:
        'Atelier de manipulation pour développer la\nconcentration et la résolution de problèmes.',
    author: 'Mme. Sophie — Future Stars',
    themeKey: 'green',
  ),
  ActivityModel(
    title: 'Chiffres & Lettres 🔤',
    date: _now.add(const Duration(days: 2)),
    startTime: const TimeOfDay(hour: 17, minute: 15),
    endTime: const TimeOfDay(hour: 18, minute: 0),
    description:
        'Introduction ludique à l\'alphabet et aux\npremiers nombres via des jeux sensoriels.',
    author: 'Mme. Claire — Young Explorers',
    themeKey: 'amber',
  ),
];
