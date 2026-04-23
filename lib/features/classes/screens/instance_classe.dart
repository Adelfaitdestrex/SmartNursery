import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartnursery/features/classes/screens/heure_de_ramassage.dart';
import 'package:smartnursery/features/classes/screens/incident_page.dart';
import 'package:smartnursery/features/classes/screens/calendier_abscence.dart';

/// Page qui affiche les enfants d'une classe en temps réel.
///
/// Stratégie :
///   - StreamBuilder sur le doc de la classe → écoute childrenIds en live
///   - À chaque mise à jour de ce tableau, on recharge les enfants correspondants
///   - Fallback : query where classId == classId (pour les enfants sans classId)
class SmartNurseryClassPage extends StatefulWidget {
  final String classId;
  final String className;
  final Color classColor;
  final Color classBgColor;

  const SmartNurseryClassPage({
    super.key,
    required this.classId,
    required this.className,
    required this.classColor,
    required this.classBgColor,
  });

  @override
  State<SmartNurseryClassPage> createState() => _SmartNurseryClassPageState();
}

class _SmartNurseryClassPageState extends State<SmartNurseryClassPage> {
  String _searchQuery = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _defaultAvatar(String gender) {
    final g = gender.toLowerCase();
    if (g == 'm' || g == 'garçon' || g == 'male') {
      return 'https://img.freepik.com/vecteurs-libre/illustration-personnage-anime-garcon-mignon_23-2151199341.jpg';
    } else if (g == 'f' || g == 'fille' || g == 'female') {
      return 'https://img.freepik.com/vecteurs-libre/illustration-personnage-anime-fille-mignonne_23-2151211110.jpg';
    }
    return 'https://img.freepik.com/vecteurs-libre/petit-garcon-souriant-illustration-style-dessin-anime_1308-154942.jpg';
  }

  /// Charge tous les enfants de la classe de manière robuste :
  ///   1. Via childrenIds dans le doc de la classe
  ///   2. Via classId champ dans chaque enfant (fallback minuscule)
  ///   3. Via classID champ dans chaque enfant (fallback majuscule, héritage)
  Future<List<Map<String, dynamic>>> _fetchChildren(
    List<String> childrenIds,
  ) async {
    final result = <Map<String, dynamic>>[];
    final seenIds = <String>{};

    // ── 1. Par childrenIds (source de vérité principale) ──────────────────
    if (childrenIds.isNotEmpty) {
      // Firestore limite whereIn à 30 éléments
      for (var i = 0; i < childrenIds.length; i += 30) {
        final batch = childrenIds.sublist(
          i,
          (i + 30) > childrenIds.length ? childrenIds.length : (i + 30),
        );
        final snap = await _firestore
            .collection('enfants')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        for (final doc in snap.docs) {
          if (seenIds.add(doc.id)) {
            result.add({...doc.data(), '_id': doc.id});
          }
        }
      }
    }

    // ── 2. Fallback classId (minuscule) ────────────────────────────────────
    final q1 = await _firestore
        .collection('enfants')
        .where('classId', isEqualTo: widget.classId)
        .get();
    for (final doc in q1.docs) {
      if (seenIds.add(doc.id)) {
        result.add({...doc.data(), '_id': doc.id});
      }
    }

    // ── 3. Fallback classID (majuscule, ancienne notation) ─────────────────
    final q2 = await _firestore
        .collection('enfants')
        .where('classID', isEqualTo: widget.classId)
        .get();
    for (final doc in q2.docs) {
      if (seenIds.add(doc.id)) {
        result.add({...doc.data(), '_id': doc.id});
      }
    }

    debugPrint(
      '✅ Enfants trouvés pour "${widget.className}": ${result.length}',
    );
    return result;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.classBgColor,
      appBar: AppBar(
        backgroundColor: widget.classColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.className,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            // ── Écoute le doc de la classe en temps réel ──────────────────
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('classes')
                  .doc(widget.classId)
                  .snapshots(),
              builder: (context, classSnap) {
                if (classSnap.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: widget.classColor),
                  );
                }

                // Extraire childrenIds du document de la classe
                final classData = classSnap.data?.data();
                final childrenIds = classData != null
                    ? List<String>.from(classData['childrenIds'] ?? [])
                    : <String>[];

                debugPrint(
                  '🔄 Stream update — "${widget.className}" childrenIds: $childrenIds',
                );

                // ── Charger les enfants correspondants (robuste & live)
                // Strategy: use the class' childrenIds as source of truth (one-shot fetch),
                // then listen live to any enfants documents that have classId == widget.classId
                // and merge both sets so new children appear immediately even if one side
                // has a propagation delay.
                return FutureBuilder<List<Map<String, dynamic>>>(
                  key: ValueKey(childrenIds.join(',')),
                  future: _fetchChildren(childrenIds),
                  builder: (context, childSnap) {
                    if (childSnap.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: widget.classColor,
                        ),
                      );
                    }

                    if (childSnap.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Erreur : ${childSnap.error}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final initialChildren = childSnap.data ?? [];

                    // Listen live to enfants documents where classId == widget.classId
                    // Also listen to the legacy field `classID` (uppercase) and merge both
                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _firestore
                          .collection('enfants')
                          .where('classId', isEqualTo: widget.classId)
                          .snapshots(),
                      builder: (context, liveSnapLower) {
                        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: _firestore
                              .collection('enfants')
                              .where('classID', isEqualTo: widget.classId)
                              .snapshots(),
                          builder: (context, liveSnapUpper) {
                            // Merge initialChildren (from childrenIds + fallbacks)
                            // with live children coming from both queries.
                            final merged = <Map<String, dynamic>>[];
                            final seen = <String>{};

                            for (final c in initialChildren) {
                              final id = c['_id'] as String? ?? '';
                              if (id.isNotEmpty && seen.add(id)) merged.add(c);
                            }

                            if (liveSnapLower.hasData) {
                              for (final doc in liveSnapLower.data!.docs) {
                                final id = doc.id;
                                if (seen.add(id)) {
                                  merged.add({...doc.data(), '_id': id});
                                }
                              }
                            }

                            if (liveSnapUpper.hasData) {
                              for (final doc in liveSnapUpper.data!.docs) {
                                final id = doc.id;
                                if (seen.add(id)) {
                                  merged.add({...doc.data(), '_id': id});
                                }
                              }
                            }

                            if (merged.isEmpty) return _buildEmptyState();

                            // Filtrage recherche
                            final filtered = merged.where((data) {
                              final first =
                                  (data['firstName'] ?? '').toString().toLowerCase();
                              final last =
                                  (data['lastName'] ?? '').toString().toLowerCase();
                              return first.contains(_searchQuery) ||
                                  last.contains(_searchQuery);
                            }).toList();

                            if (filtered.isEmpty && _searchQuery.isNotEmpty) {
                              return Center(
                                child: Text(
                                  'Aucun résultat pour "$_searchQuery"',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 15,
                                    color: widget.classColor,
                                  ),
                                ),
                              );
                            }

                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 0.72,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 15,
                                  ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final data = filtered[index];
                                final firstName = data['firstName'] as String? ?? '';
                                final lastName = data['lastName'] as String? ?? '';
                                final gender = data['gender'] as String? ?? '';
                                final avatarUrl =
                                    data['avatarImageUrl'] as String? ??
                                    _defaultAvatar(gender);
                                return _buildChildCard(
                                  firstName: firstName,
                                  lastName: lastName,
                                  gender: gender,
                                  avatarUrl: avatarUrl,
                                );
                              },
                            );
                          },
                        );
                      },
                    );

                      },
                    );
                  },
                )

            ),

        ],
      ),
    );
  }

  // ── Widgets utilitaires ───────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.child_care,
            size: 72,
            color: widget.classColor.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun enfant dans cette classe',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.classColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Assignez des enfants via la création d'un parent",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: widget.classColor.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ── Action bottom sheet ────────────────────────────────────────────────────

  void _showChildActions(BuildContext context, String childName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ChildActionsSheet(
        childName: childName,
        classColor: widget.classColor,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Rechercher un enfant...',
          hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14),
          prefixIcon: Icon(Icons.search, color: widget.classColor),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildChildCard({
    required String firstName,
    required String lastName,
    required String gender,
    required String avatarUrl,
  }) {
    final g = gender.toLowerCase();
    final genderIcon = (g == 'm' || g == 'garçon' || g == 'male')
        ? '♂'
        : (g == 'f' || g == 'fille' || g == 'female')
        ? '♀'
        : '';
    final fullName = '$firstName $lastName'.trim();

    return GestureDetector(
      onTap: () => _showChildActions(context, fullName),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(avatarUrl),
                onBackgroundImageError: (_, e) {
                  debugPrint('Avatar load error: $e');
                },
              ),
              if (genderIcon.isNotEmpty)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: widget.classColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        genderIcon,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            firstName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            lastName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: Colors.black.withValues(alpha: 0.5),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Bottom sheet avec les deux actions ────────────────────────────────────────

class _ChildActionsSheet extends StatelessWidget {
  final String childName;
  final Color classColor;

  const _ChildActionsSheet({required this.childName, required this.classColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),

          // En-tête : avatar + nom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: classColor.withValues(alpha: 0.15),
                  child: Text(
                    childName.isNotEmpty ? childName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: classColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        childName,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2E1A),
                        ),
                      ),
                      Text(
                        'Que voulez-vous faire ?',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, indent: 24, endIndent: 24),
          const SizedBox(height: 12),

          // Bouton 1 — Heure de ramassage
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ActionButton(
              icon: Icons.directions_bus_rounded,
              label: 'Noter Abscence',
              sublabel: 'Définir l\'abscence',
              color: const Color(0xFF0B511B),
              bgColor: const Color(0xFFE8F5E9),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CalendarPage(

                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Bouton 2 — Signaler un incident
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ActionButton(
              icon: Icons.warning_amber_rounded,
              label: 'Signaler un incident',
              sublabel: 'Créer un rapport d\'incident',
              color: const Color(0xFFB71C1C),
              bgColor: const Color(0xFFFFEBEE),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IncidentReportPage()),
                );
              },
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: color.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: color.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
