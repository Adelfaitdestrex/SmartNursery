import 'package:flutter/material.dart';
import 'package:smartnursery/features/activities/models/activity_model.dart';

class ActivityCard extends StatelessWidget {
  final ActivityModel activity;

  const ActivityCard({super.key, required this.activity});

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
          ],
        ),
      ),
    );
  }
}
