import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:smartnursery/features/classes/screens/time_selection.dart';
import 'package:smartnursery/features/classes/screens/heure_de_ramassage.dart'; // N'oublie pas d'importer la nouvelle page !

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final String _selectedChild = "Léo";

  // 1. Liste des jours marqués comme absents
  final Set<DateTime> _absentDays = {};

  // NOUVEAU : Dictionnaire pour associer une date à une heure de ramassage
  final Map<DateTime, TimeOfDay> _pickupTimes = {};

  void _goToPreviousMonth() => setState(
    () => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1),
  );
  void _goToNextMonth() => setState(
    () => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1),
  );

  String _monthName(DateTime date) {
    String name = DateFormat.MMMM('fr').format(date);
    return name[0].toUpperCase() + name.substring(1);
  }

  // Fonction existante pour l'absence
  void _navigateToAbsencePage(DateTime date) async {
    final confirmed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TimeSelectionPage(selectedDate: date, childName: _selectedChild),
      ),
    );

    if (confirmed == true) {
      setState(() {
        _absentDays.add(DateTime(date.year, date.month, date.day));
      });
    }
  }

  // NOUVEAU : Fonction pour naviguer vers la page de ramassage
  void _navigateToPickupPage(DateTime date) async {
    final TimeOfDay? pickedTime = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PickupTimePage(selectedDate: date, childName: _selectedChild),
      ),
    );

    // Si l'utilisateur a choisi une heure, on la sauvegarde
    if (pickedTime != null) {
      setState(() {
        // On normalise la date (sans les heures/minutes) pour la clé
        DateTime normalizedDate = DateTime(date.year, date.month, date.day);
        _pickupTimes[normalizedDate] = pickedTime;

        // Optionnel : Si l'enfant est absent ce jour-là, on le retire des absents
        _absentDays.remove(normalizedDate);
      });
    }
  }

  // NOUVEAU : Fonction pour récupérer l'heure de ramassage d'un jour précis
  TimeOfDay? _getPickupTimeForDay(DateTime day) {
    DateTime normalizedDate = DateTime(day.year, day.month, day.day);
    return _pickupTimes[normalizedDate];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFD7),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              left: 16,
              right: 16,
              bottom: 30,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF0B511B),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(56)),
            ),
            child: const Text(
              "Smart Nursery",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header mois
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: _goToPreviousMonth,
                            ),
                            Text(
                              _monthName(_focusedDay),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: _goToNextMonth,
                            ),
                          ],
                        ),
                        // Calendrier
                        TableCalendar(
                          locale: 'fr',
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          headerVisible: false,
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                              if (_absentDays.any((d) => isSameDay(d, day))) {
                                return _buildAbsentDay(day);
                              }
                              return null;
                            },
                            selectedBuilder: (context, day, focusedDay) {
                              if (_absentDays.any((d) => isSameDay(d, day))) {
                                return _buildAbsentDay(day);
                              }
                              return Container(
                                margin: const EdgeInsets.all(4.0),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0B511B),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            },
                            // NOUVEAU : Ajout d'un petit point si une heure de ramassage est prévue
                            markerBuilder: (context, day, events) {
                              if (_getPickupTimeForDay(day) != null) {
                                return Positioned(
                                  bottom: 1,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF468B5A),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              }
                              return null;
                            },
                          ),
                          calendarStyle: const CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: Color(0xFFD4E7A2),
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: TextStyle(color: Color(0xFF0B511B)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // NOUVEAU : Affichage de l'heure de ramassage pour le jour sélectionné
                  if (_selectedDay != null &&
                      _getPickupTimeForDay(_selectedDay!) != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          border: Border.all(color: const Color(0xFF468B5A)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Color(0xFF0B511B),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Ramassage prévu à ${_getPickupTimeForDay(_selectedDay!)!.format(context)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B511B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // NOUVEAU : Zone des boutons (Absence + Ramassage)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Bouton Ramassage
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFABD64B),
                    foregroundColor: const Color(0xFF0B511B),
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    if (_selectedDay != null) {
                      _navigateToPickupPage(_selectedDay!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Veuillez sélectionner une date"),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.schedule),
                  label: const Text(
                    "Fixer l'heure de ramassage",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                // Bouton Absence
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFD32F2F,
                    ), // Rouge pour absence
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    if (_selectedDay != null) {
                      _navigateToAbsencePage(_selectedDay!);
                    }
                  },
                  icon: const Icon(Icons.event_busy),
                  label: const Text(
                    "Marquer comme absent",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsentDay(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFD32F2F),
        shape: BoxShape.circle,
      ),
      child: Text(
        '${day.day}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
