import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/features/A_propos_enfant/models/child_model.dart';
import 'package:smartnursery/features/A_propos_enfant/services/child_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddChildrenFlowPage extends StatefulWidget {
  final String parentId;
  final int numberOfChildren;
  final String nurseryId;

  const AddChildrenFlowPage({
    super.key,
    required this.parentId,
    required this.numberOfChildren,
    required this.nurseryId,
  });

  @override
  State<AddChildrenFlowPage> createState() => _AddChildrenFlowPageState();
}

class _AddChildrenFlowPageState extends State<AddChildrenFlowPage> {
  late PageController _pageController;
  late List<Map<String, dynamic>> _childrenData;
  late List<TextEditingController> _firstNameControllers;
  late List<TextEditingController> _lastNameControllers;
  final ChildService _childService = ChildService();
  List<Map<String, dynamic>> _availableClasses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeChildrenData();
    debugPrint(
      '📄 AddChildrenFlowPage initialized for ${widget.numberOfChildren} children',
    );
    debugPrint('👤 Parent ID: ${widget.parentId}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAvailableClasses();
    });
  }

  void _initializeChildrenData() {
    _childrenData = List.generate(
      widget.numberOfChildren,
      (index) => {
        'gender': 'Garçon', // valeur par défaut
        'dateOfBirth': DateTime.now().subtract(const Duration(days: 365 * 3)),
        'classId': null,
      },
    );
    _firstNameControllers = List.generate(
      widget.numberOfChildren,
      (_) => TextEditingController(),
    );
    _lastNameControllers = List.generate(
      widget.numberOfChildren,
      (_) => TextEditingController(),
    );
  }

  Future<void> _loadAvailableClasses() async {
    try {
      debugPrint('📚 Loading classes for nursery: ${widget.nurseryId}');
      final classes = await _childService.getAvailableClassesForNursery(
        widget.nurseryId,
      );
      debugPrint('✅ Loaded ${classes.length} available classes');
      if (mounted) {
        setState(() {
          _availableClasses = classes;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading classes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des classes: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _firstNameControllers) {
      controller.dispose();
    }
    for (var controller in _lastNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveChild(int index) async {
    if (_firstNameControllers[index].text.isEmpty ||
        _lastNameControllers[index].text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir le prénom et le nom'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final childRef = FirebaseFirestore.instance.collection('enfants').doc();
      final childId = childRef.id;

      final child = ChildModel(
        childId: childId,
        firstName: _firstNameControllers[index].text,
        lastName: _lastNameControllers[index].text,
        gender: _childrenData[index]['gender'],
        dateOfBirth: _childrenData[index]['dateOfBirth'],
        classId: _childrenData[index]['classId'],
        parentIds: [widget.parentId],
        enrollmentDate: DateTime.now(),
        nurseryId: widget.nurseryId,
      );

      debugPrint('💾 Saving child ${index + 1}/${widget.numberOfChildren}...');
      await _childService.createChildWithNursery(
        childData: child,
        nurseryId: widget.nurseryId,
      );

      if (_childrenData[index]['classId'] != null) {
        await _childService.assignChildToClass(
          childId,
          _childrenData[index]['classId'],
        );
      }

      if (!mounted) return;

      if (index < widget.numberOfChildren - 1) {
        setState(() => _isLoading = false);
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted && _pageController.hasClients) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tous les enfants ont été créés avec succès !'),
              backgroundColor: Color(0xFF006F1D),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.numberOfChildren,
                itemBuilder: (context, index) {
                  return _buildChildForm(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFD6E6DB),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.arrow_back, color: Color(0xFF006F1D), size: 24),
          ),
          const SizedBox(width: 8),
          const Text(
            'Ajout des enfants',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006F1D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildForm(int index) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Indicateur de progression
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enfant ${index + 1} sur ${widget.numberOfChildren}',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF546259),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (index + 1) / widget.numberOfChildren,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFD6E6DB),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF006F1D)),
                ),
              ],
            ),
          ),
          // Formulaire
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF28352E).withValues(alpha: 0.05),
                  offset: const Offset(0, 4),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Informations de l'enfant",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF28352E),
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  label: 'Prénom',
                  hint: 'Ex: Sophie',
                  controller: _firstNameControllers[index],
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Nom',
                  hint: 'Ex: Martin',
                  controller: _lastNameControllers[index],
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildGenderSelector(index),
                const SizedBox(height: 16),
                _buildDateOfBirthField(index),
                const SizedBox(height: 16),
                _buildClassSelector(index),
                const SizedBox(height: 32),
                // Boutons navigation
                Row(
                  children: [
                    if (index > 0) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE5F8E5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: const BorderSide(color: Color(0xFF006F1D)),
                            ),
                          ),
                          child: const Text(
                            'Précédent',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF006F1D),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _saveChild(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006F1D),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                index < widget.numberOfChildren - 1 ? 'Suivant' : 'Terminer',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets auxiliaires ────────────────────────────────────────────────────

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF546259),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFF4FBF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD6E6DB)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: const Color(0x66546259), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Color(0x66546259),
                    ),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Color(0xFF28352E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Sélecteur de genre : uniquement "Garçon" et "Fille"
  Widget _buildGenderSelector(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Genre',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF546259),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            {'label': 'Garçon', 'icon': '♂'},
            {'label': 'Fille', 'icon': '♀'},
          ].map((item) {
            final gender = item['label'] as String;
            final icon = item['icon'] as String;
            final isSelected = _childrenData[index]['gender'] == gender;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => _childrenData[index]['gender'] = gender);
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF006F1D) : const Color(0xFFF4FBF4),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? null : Border.all(color: const Color(0xFFD6E6DB)),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        icon,
                        style: TextStyle(
                          fontSize: 20,
                          color: isSelected ? Colors.white : const Color(0xFF546259),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gender,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF546259),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateOfBirthField(int index) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date de naissance',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF546259),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _childrenData[index]['dateOfBirth'],
              firstDate: DateTime(2010),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() => _childrenData[index]['dateOfBirth'] = picked);
                }
              });
            }
          },
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF4FBF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD6E6DB)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Color(0x66546259), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dateFormatter.format(_childrenData[index]['dateOfBirth']),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Color(0xFF28352E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassSelector(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Classe (optionnel)',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF546259),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF4FBF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD6E6DB)),
          ),
          child: DropdownButton<String?>(
            value: _childrenData[index]['classId'],
            isExpanded: true,
            underline: const SizedBox.shrink(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Aucune classe'),
              ),
              ..._availableClasses.map((classData) {
                return DropdownMenuItem<String?>(
                  value: classData['classId'],
                  child: Text(
                    '${classData['name']} (${classData['ageRange']})',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Color(0xFF28352E),
                    ),
                  ),
                );
              }).toList(),
            ],
            onChanged: (value) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() => _childrenData[index]['classId'] = value);
                }
              });
            },
          ),
        ),
      ],
    );
  }
}
