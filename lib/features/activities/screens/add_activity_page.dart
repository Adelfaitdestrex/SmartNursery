import 'package:flutter/material.dart';
import 'package:smartnursery/shared/widgets/shared_header.dart';
import 'package:smartnursery/features/activities/models/activity_model.dart';
import 'package:smartnursery/features/activities/widgets/activity_card.dart';

class AddActivityPage extends StatefulWidget {
  const AddActivityPage({super.key});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  int _selectedTabIndex = 0; // 0 for Predéfinie, 1 for Custom

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF4),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SharedHeader(
              title: 'Nouvelle Activité',
              leftWidget: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
              leftLabel: null,
              onLeftTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 24),
            // Custom Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: const [
                    BoxShadow(color: Color(0x20000000), offset: Offset(0, 2), blurRadius: 4),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildTab('Préexistantes', 0)),
                    Expanded(child: _buildTab('Customisée', 1)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _selectedTabIndex == 0 ? const _PreexistingActivitiesView() : const _CustomActivityForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isActive = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF006F1D) : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

class _PreexistingActivitiesView extends StatelessWidget {
  const _PreexistingActivitiesView();

  @override
  Widget build(BuildContext context) {
    final terminies = dummyActivities.where((a) => a.status == ActivityStatus.terminee).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              'Sélectionnez une activité terminée à relancer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF28352E)),
            ),
          ),
          if (terminies.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Aucune activité terminée pour le moment."),
            )
          else
            ...terminies.map((activity) => GestureDetector(
                  onTap: () async {
                    final result = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _RelaunchSheet(activity: activity),
                    );
                    if (result == true && context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: AbsorbPointer(
                    child: ActivityCard(activity: activity),
                  ),
                )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _CustomActivityForm extends StatefulWidget {
  const _CustomActivityForm();

  @override
  State<_CustomActivityForm> createState() => _CustomActivityFormState();
}

class _CustomActivityFormState extends State<_CustomActivityForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descController = TextEditingController();

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF006F1D)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? (_startTime ?? TimeOfDay.now()) : (_endTime ?? TimeOfDay.now()),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF006F1D)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Créer une nouvelle activité',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF28352E)),
            ),
            const SizedBox(height: 24),
            _buildInputField('Titre de l\'activité', Icons.title, controller: _titleController),
            const SizedBox(height: 16),
            _buildDateTimePicker(),
            const SizedBox(height: 16),
            _buildInputField('Éducateur(rice) assigné(e)', Icons.person, controller: _authorController),
            const SizedBox(height: 16),
            _buildInputField('Description', Icons.description, maxLines: 3, controller: _descController),
            if (_selectedDate == null || _startTime == null || _endTime == null)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Veuillez sélectionner la date et les horaires.', style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                if (_formKey.currentState!.validate() && _selectedDate != null && _startTime != null && _endTime != null) {
                  final newActivity = ActivityModel(
                    title: _titleController.text,
                    date: _selectedDate!,
                    startTime: _startTime!,
                    endTime: _endTime!,
                    description: _descController.text,
                    author: _authorController.text,
                    themeKey: 'green',
                  );
                  dummyActivities.add(newActivity);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Activité créée avec succès !')),
                  );
                  Navigator.pop(context, true);
                } else {
                  setState(() {}); // refresh to show error text
                }
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF89B832),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [BoxShadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 4)],
                ),
                child: const Center(
                  child: Text(
                    'Enregistrer l\'activité',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 2))],
              border: _selectedDate == null ? Border.all(color: Colors.red.shade200) : null,
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF006F1D)),
                const SizedBox(width: 12),
                Text(
                  _selectedDate == null 
                      ? 'Sélectionner une date' 
                      : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                  style: TextStyle(
                    color: _selectedDate == null ? Colors.black38 : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 2))],
                    border: _startTime == null ? Border.all(color: Colors.red.shade200) : null,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF006F1D)),
                      const SizedBox(width: 12),
                      Text(
                        _startTime == null ? 'Début' : _startTime!.format(context),
                        style: TextStyle(
                          color: _startTime == null ? Colors.black38 : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 2))],
                    border: _endTime == null ? Border.all(color: Colors.red.shade200) : null,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF006F1D)),
                      const SizedBox(width: 12),
                      Text(
                        _endTime == null ? 'Fin' : _endTime!.format(context),
                        style: TextStyle(
                          color: _endTime == null ? Colors.black38 : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField(String hint, IconData icon, {int maxLines = 1, TextEditingController? controller}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          prefixIcon: maxLines == 1 ? Icon(icon, color: const Color(0xFF006F1D)) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez remplir ce champ';
          }
          return null;
        },
      ),
    );
  }
}

// ─── Bottom sheet de relancement ──────────────────────────────────────────────

class _RelaunchSheet extends StatefulWidget {
  final ActivityModel activity;
  const _RelaunchSheet({required this.activity});

  @override
  State<_RelaunchSheet> createState() => _RelaunchSheetState();
}

class _RelaunchSheetState extends State<_RelaunchSheet> {
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late TextEditingController _authorController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _startTime = widget.activity.startTime;
    _endTime = widget.activity.endTime;
    _authorController = TextEditingController(text: widget.activity.author);
  }

  @override
  void dispose() {
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF006F1D)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF006F1D)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF4FBF4),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grip
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Titre activité (non éditable)
            Text(
              widget.activity.title,
              style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF28352E),
              ),
            ),
            const SizedBox(height: 24),
            // Professeur
            const Text('Professeur / Éducateur(rice)', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF28352E))),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 6)],
              ),
              child: TextField(
                controller: _authorController,
                decoration: const InputDecoration(
                  hintText: 'Nom du professeur / classe',
                  hintStyle: TextStyle(color: Colors.black38),
                  prefixIcon: Icon(Icons.person, color: Color(0xFF006F1D)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Date
            const Text('Date', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF28352E))),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 6)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF006F1D), size: 20),
                    const SizedBox(width: 12),
                    Text(_fmtDate(_selectedDate),
                        style: const TextStyle(fontSize: 16, color: Colors.black87)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Heure début / fin
            const Text('Horaires', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF28352E))),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 6)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Color(0xFF006F1D), size: 20),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Début', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              Text(_fmtTime(_startTime),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 6)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_filled, color: Color(0xFF006F1D), size: 20),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Fin', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              Text(_fmtTime(_endTime),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Bouton confirmer
            GestureDetector(
              onTap: () {
                final newActivity = ActivityModel(
                  title: widget.activity.title,
                  date: _selectedDate,
                  startTime: _startTime,
                  endTime: _endTime,
                  description: widget.activity.description,
                  author: _authorController.text.trim().isEmpty
                      ? widget.activity.author
                      : _authorController.text.trim(),
                  themeKey: widget.activity.themeKey,
                );
                dummyActivities.add(newActivity);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${widget.activity.title}" relancée !')),
                );
                Navigator.pop(context, true);
              },
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF006F1D),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [BoxShadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 4)],
                ),
                child: const Center(
                  child: Text(
                    'Confirmer le relancement',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
