import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedMonth = DateTime.now();
  bool showAttendance = true;

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    int daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    int startWeekday =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;

    return Scaffold(
      body: Column(
        children: [
          // Fond vert avec flèche retour + toggle
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFCDE0A7), Color(0xFFAACB6A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.green),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => showAttendance = true),
                            child: Container(
                              decoration: BoxDecoration(
                                color: showAttendance
                                    ? Colors.white
                                    : Colors.green,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "ATTENDANCE",
                                  style: TextStyle(
                                    color: showAttendance
                                        ? Colors.green
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => showAttendance = false),
                            child: Container(
                              decoration: BoxDecoration(
                                color: showAttendance
                                    ? Colors.green
                                    : Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),),
                              child: Center(
                                child: Text(
                                  "HOLIDAY",
                                  style: TextStyle(
                                    color: showAttendance
                                        ? Colors.white
                                        : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Navigation mois
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _prevMonth,
                ),
                Text(
                  DateFormat.yMMMM().format(_focusedMonth),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),

          // En-tête jours
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text("Mo"),
              Text("Tu"),
              Text("We"),
              Text("Th"),
              Text("Fr"),
              Text("Sa"),
              Text("Su"),
            ],
          ),

          const SizedBox(height: 8),

          // Grille calendrier
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: daysInMonth + startWeekday,
              itemBuilder: (context, index) {
                if (index < startWeekday) return const SizedBox();
                int day = index - startWeekday + 1;

                Color? circleColor;
                if (day == 8 || day == 23) {
                  circleColor = Colors.red;
                } else if (day == 20) {
                  circleColor = Colors.green;
                } else if (DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month,
                      day,
                    ).weekday ==
                    DateTime.sunday) {
                  circleColor = Colors.blue;
                }

                return GestureDetector(
                  onTap: () {
                    String msg;
                    if (circleColor == Colors.red) {
                      msg =
                          "Absent le $day ${DateFormat.MMMM().format(_focusedMonth)}";
                    } else if (circleColor == Colors.green) {
                      msg =
                          "Holiday le $day ${DateFormat.MMMM().format(_focusedMonth)}";
                    } else {
                      msg =
                          "Jour normal : $day ${DateFormat.MMMM().format(_focusedMonth)}";
                    }
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(msg)));
                  },
                  child: CircleAvatar(
                    backgroundColor: circleColor ?? Colors.transparent,
                    child: Text(
                      "$day",
                      style: TextStyle(
                        color: circleColor != null
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Légende en colonne pleine largeur
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: const [
                LegendBox(
                  color: Colors.red,
                  label: "Absent",
                  count: 2,
                  fullWidth: true,
                ),
                SizedBox(height: 12),
                LegendBox(
                  color: Colors.green,
                  label: "Festival & Holidays",
                  count: 1,
                  fullWidth: true,
                ),
              ],
            ),
          ),

          // Image décorative
          Container(
            height: 120,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/vector.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Légende corrigée pleine largeur
class LegendBox extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final bool fullWidth;
  const LegendBox({
    super.key,
    required this.color,
    required this.label,
    required this.count,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Text(
              count.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}