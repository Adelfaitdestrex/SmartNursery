import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeSelectionPage extends StatelessWidget {
  final DateTime selectedDate;
  final String childName;

  const TimeSelectionPage({
    super.key,
    required this.selectedDate,
    required this.childName,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat(
      'dd MMMM yyyy',
      'fr',
    ).format(selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F0),
      appBar: AppBar(
        title: const Text("Confirmation d'absence"),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, size: 100, color: Color(0xFFD32F2F)),
            const SizedBox(height: 24),
            Text(
              "Marquer $childName absent pour le",
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD32F2F),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                // IMPORTANT : On renvoie "true" pour dire au calendrier de devenir rouge
                Navigator.pop(context, true);
              },
              child: const Text(
                "Confirmer l'absence",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Annuler",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
