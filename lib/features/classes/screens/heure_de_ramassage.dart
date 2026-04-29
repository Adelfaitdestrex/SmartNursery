import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PickupTimePage extends StatefulWidget {
  final DateTime selectedDate;
  final String childName;

  const PickupTimePage({
    super.key,
    required this.selectedDate,
    required this.childName,
  });

  @override
  State<PickupTimePage> createState() => _PickupTimePageState();
}

class _PickupTimePageState extends State<PickupTimePage> {
  // J'ai initialisé à 16:30, une heure classique de ramassage,
  // mais tu peux remettre 8:30 si tu préfères !
  int selectedHour = 16;
  int selectedMinute = 30;

  @override
  Widget build(BuildContext context) {
    // Formatage de la date pour l'afficher subtilement
    String formattedDate = DateFormat(
      'dd MMMM',
      'fr',
    ).format(widget.selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFD6E6B5),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 12,
              right: 24,
              top: 60,
              bottom: 50,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF0B511B),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(56)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 4),
                const Text(
                  "Sélectionner l'heure",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -32,
                  left: 24,
                  right: 24,
                  bottom:
                      0, // Pour s'assurer que le contenu scroll si l'écran est petit
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(48),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // J'ai intégré le nom de l'enfant et la date ici pour garder ton design intact
                          Text(
                            "Ramassage de ${widget.childName} le $formattedDate",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B511B),
                            ),
                          ),

                          // Décalage avant le picker
                          const SizedBox(height: 40),

                          // CupertinoPicker interactif
                          SizedBox(
                            height: 200,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: CupertinoPicker(
                                    scrollController: FixedExtentScrollController(
                                      initialItem: selectedHour,
                                    ),
                                    itemExtent: 40,
                                    selectionOverlay:
                                        const CupertinoPickerDefaultSelectionOverlay(
                                          background: Colors
                                              .transparent, // Retire le fond gris par défaut du picker
                                        ),
                                    onSelectedItemChanged: (value) {
                                      setState(() {
                                        selectedHour = value;
                                      });
                                    },
                                    children: List.generate(24, (index) {
                                      return Center(
                                        child: Text(
                                          index.toString().padLeft(2, '0'),
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF0B511B),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                const Text(
                                  ":",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B511B),
                                  ),
                                ),
                                Expanded(
                                  child: CupertinoPicker(
                                    scrollController: FixedExtentScrollController(
                                      initialItem: selectedMinute,
                                    ),
                                    itemExtent: 40,
                                    selectionOverlay:
                                        const CupertinoPickerDefaultSelectionOverlay(
                                          background: Colors.transparent,
                                        ),
                                    onSelectedItemChanged: (value) {
                                      setState(() {
                                        selectedMinute = value;
                                      });
                                    },
                                    children: List.generate(60, (index) {
                                      return Center(
                                        child: Text(
                                          index.toString().padLeft(2, '0'),
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF0B511B),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Status pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 18,
                                  color: Color(0xFF0B511B),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Horaire standard de la crèche",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF0B511B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B511B),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  elevation: 4,
                ),
                onPressed: () {
                  // C'est ICI que la magie opère !
                  // On crée l'objet TimeOfDay et on le renvoie à la page Calendrier
                  final selectedTime = TimeOfDay(
                    hour: selectedHour,
                    minute: selectedMinute,
                  );
                  Navigator.pop(context, selectedTime);
                },
                child: const Text(
                  "Confirmer l'heure",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
