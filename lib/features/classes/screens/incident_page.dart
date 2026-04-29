import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/features/news-feed/screen/feed_page.dart';
import 'package:smartnursery/shared/widgets/shared_bottom_navbar.dart';
import 'package:smartnursery/shared/widgets/shared_header.dart';

class IncidentReportPage extends StatefulWidget {
  final String classId;
  final String? initialChildId;

  const IncidentReportPage({super.key, required this.classId, this.initialChildId});

  @override
  State<IncidentReportPage> createState() => _IncidentReportPageState();
}

class _IncidentReportPageState extends State<IncidentReportPage> {
  String selectedPriority = 'Faible';
  String? _selectedChildId;
  List<Map<String, dynamic>> _children = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedChildId = widget.initialChildId;
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    try {
      final classDoc = await FirebaseFirestore.instance.collection('classes').doc(widget.classId).get();
      final childrenIds = List<String>.from(classDoc.data()?['childrenIds'] ?? []);
      
      List<Map<String, dynamic>> loadedChildren = [];
      if (childrenIds.isNotEmpty) {
        for (var i = 0; i < childrenIds.length; i += 30) {
          final batch = childrenIds.sublist(i, (i + 30) > childrenIds.length ? childrenIds.length : (i + 30));
          final snap = await FirebaseFirestore.instance.collection('enfants').where(FieldPath.documentId, whereIn: batch).get();
          for (var doc in snap.docs) {
            loadedChildren.add({...doc.data(), 'id': doc.id});
          }
        }
      }
      
      if (loadedChildren.isEmpty) {
         final snap2 = await FirebaseFirestore.instance.collection('enfants').where('classId', isEqualTo: widget.classId).get();
         for (var doc in snap2.docs) {
           if (!loadedChildren.any((c) => c['id'] == doc.id)) {
             loadedChildren.add({...doc.data(), 'id': doc.id});
           }
         }
      }

      setState(() {
        _children = loadedChildren;
        _isLoading = false;
        if (_selectedChildId == null && _children.isNotEmpty) {
          _selectedChildId = _children.first['id'];
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("Error fetching children: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ألوان أغمق وأكثر حدة
    const Color sendButtonColor = Color(0xFF004D1A); // لون زر الإرسال

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      bottomNavigationBar: const SafeArea(
        top: false,
        child: SharedBottomNavbar(currentIndex: 4),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SharedHeader(
              title: 'Rapport d\'incident',
              leftWidget: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 32,
              ),
              leftLabel: null,
              onLeftTap: () {
                Navigator.pop(context);
              },
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "SÉLECTIONNER L'ENFANT",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF424242),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // قائمة الأطفال
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _children.map((child) {
                                final name = child['firstName'] ?? '';
                                final avatarUrl = child['avatarImageUrl'] as String?;
                                final isSelected = _selectedChildId == child['id'];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedChildId = child['id'];
                                      });
                                    },
                                    child: _childAvatar(name, isSelected, avatarUrl),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                    const SizedBox(height: 25),

                    // البطاقة البيضاء
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel("Titre de l'incident"),
                          _customTextField("Titre de l'incident"),
                          const SizedBox(height: 20),
                          _fieldLabel("Description"),
                          _customTextField(
                            "Décrivez ce qu'il s'est passé...",
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // التاريخ والوقت
                    Row(
                      children: [
                        Expanded(
                          child: _infoBox(
                            Icons.calendar_today,
                            "DATE",
                            "24 Oct, 2023",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoBox(Icons.access_time, "HEURE", "10:45"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      "Priorité",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // اختيار الأولوية
                    Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          _priorityOption("Faible"),
                          _priorityOption("Moyen"),
                          _priorityOption("Élevé"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20), // زر إضافة صورة
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black12,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF8BC34A),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Ajouter une photo",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // زر الإرسال
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sendButtonColor,
                        minimumSize: const Size(double.infinity, 65),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                      onPressed: () {},
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Envoyer le rapport",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.send, color: Colors.white),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // مكوّن العناوين داخل البطاقة
  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 5),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.grey,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // مكوّن حقول الإدخال
  Widget _customTextField(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFE8F0E3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // مكوّن صور الأطفال
  Widget _childAvatar(String name, bool isSelected, String? avatarUrl) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.green : Colors.transparent,
              width: 3,
            ),
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : const NetworkImage('https://via.placeholder.com/100'),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          name,
          style: TextStyle(
            color: isSelected ? Colors.green[900] : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  } // صناديق التاريخ والوقت

  Widget _infoBox(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.green[700]),
              const SizedBox(width: 5),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // مكوّن خيارات الأولوية
  Widget _priorityOption(String title) {
    bool isSelected = selectedPriority == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedPriority = title),
        child: Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected
                ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.green[800] : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
