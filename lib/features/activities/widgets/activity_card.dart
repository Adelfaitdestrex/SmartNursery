import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartnursery/features/activities/models/activity_model.dart';

class ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final String userRole;
  final String userId;
  final String nurseryId;
  final bool showManageButton;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.userRole,
    required this.userId,
    required this.nurseryId,
    this.showManageButton = true,
  });

  String _getStatusText() {
    switch (activity.status) {
      case ActivityStatus.enCours:
        return 'En cours';
      case ActivityStatus.terminee:
        return 'Terminée';
      case ActivityStatus.aVenir:
        return 'À venir';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: activity.theme.backgroundColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: activity.theme.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(21.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row (Icon & Status Badge)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: activity.theme.iconBackgroundColor,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Center(
                    child: Icon(Icons.category, color: Colors.black26), // placeholder icon
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                      decoration: BoxDecoration(
                        color: activity.theme.statusBadgeBg,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: activity.theme.statusBadgeBorder),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: activity.theme.statusBadgeText,
                        ),
                      ),
                    ),
                    if (activity.status == ActivityStatus.enCours) ...[
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFECDD3),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.65,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF43F5E),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              activity.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF28352E),
              ),
            ),
            const SizedBox(height: 8),
            // Date & Time
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 12, color: Color(0xFF546259)),
                const SizedBox(width: 8),
                Text(
                  '${activity.date.day.toString().padLeft(2, '0')}/${activity.date.month.toString().padLeft(2, '0')}/${activity.date.year}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF546259),
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 12, color: Color(0xFF546259)),
                const SizedBox(width: 8),
                Text(
                  activity.time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF546259),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              activity.description,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF546259),
                fontStyle: activity.status == ActivityStatus.terminee ? FontStyle.italic : FontStyle.normal,
              ),
            ),
            const SizedBox(height: 16),
            // Separator & Author
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: activity.theme.separatorColor)),
              ),
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: activity.theme.iconBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, size: 12, color: Colors.black26),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      activity.author,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF28352E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showManageButton && activity.id != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showParticipantsSheet(context),
                  icon: const Icon(Icons.people_alt_outlined, size: 18),
                  label: const Text('Gérer les participants'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: activity.theme.statusBadgeText,
                    side: BorderSide(color: activity.theme.statusBadgeText),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showParticipantsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _ParticipantsSheet(
          activity: activity,
          userRole: userRole,
          userId: userId,
          nurseryId: nurseryId,
        );
      },
    );
  }
}

class _ParticipantsSheet extends StatefulWidget {
  final ActivityModel activity;
  final String userRole;
  final String userId;
  final String nurseryId;

  const _ParticipantsSheet({
    required this.activity,
    required this.userRole,
    required this.userId,
    required this.nurseryId,
  });

  @override
  State<_ParticipantsSheet> createState() => _ParticipantsSheetState();
}

class _ParticipantsSheetState extends State<_ParticipantsSheet> {
  List<Map<String, dynamic>> _children = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    try {
      final isParent = widget.userRole == 'parent';
      QuerySnapshot query;
      
      if (isParent) {
        query = await FirebaseFirestore.instance
            .collection('enfants')
            .where('parentIds', arrayContains: widget.userId)
            .get();
      } else {
        query = await FirebaseFirestore.instance
            .collection('enfants')
            .where('nurseryId', isEqualTo: widget.nurseryId)
            .get();
      }
      
      if (mounted) {
        setState(() {
          _children = query.docs.map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>}).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching children: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleParticipant(String childId, bool isParticipating) async {
    if (widget.activity.id == null) return;
    
    final docRef = FirebaseFirestore.instance.collection('activities').doc(widget.activity.id);
    if (isParticipating) {
      await docRef.update({
        'participants': FieldValue.arrayUnion([childId])
      });
    } else {
      await docRef.update({
        'participants': FieldValue.arrayRemove([childId])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activity.id == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('activities').doc(widget.activity.id).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final participants = data != null ? List<String>.from(data['participants'] ?? []) : widget.activity.participants;
        
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grip
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Participants - ${widget.activity.title}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans'),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_children.isEmpty)
                const Center(child: Text('Aucun enfant trouvé.', style: TextStyle(color: Colors.grey)))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _children.length,
                    itemBuilder: (context, index) {
                      final child = _children[index];
                      final childId = child['id'] as String;
                      final firstName = child['firstName'] as String? ?? '';
                      final lastName = child['lastName'] as String? ?? '';
                      final isParticipating = participants.contains(childId);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4FBF4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5F8E5)),
                        ),
                        child: CheckboxListTile(
                          activeColor: const Color(0xFF006F1D),
                          title: Text('$firstName $lastName', style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                          value: isParticipating,
                          onChanged: (bool? value) {
                            if (value != null) {
                              _toggleParticipant(childId, value);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
