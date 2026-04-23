import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/features/classes/models/class_model.dart';
import 'package:smartnursery/features/classes/services/class_service.dart';

class ManageClassFormPage extends StatefulWidget {
  final ClassModel? existingClass;
  final VoidCallback onSaved;

  const ManageClassFormPage({
    super.key,
    this.existingClass,
    required this.onSaved,
  });

  @override
  State<ManageClassFormPage> createState() => _ManageClassFormPageState();
}

class _ManageClassFormPageState extends State<ManageClassFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _classService = ClassService();

  late TextEditingController _nameController;
  late TextEditingController _capacityController;
  String? _selectedTemplate;
  String? _selectedAgeRange;
  String? _selectedColor;
  bool _isLoading = false;

  final List<Map<String, String>> templates = [
    {
      'name': 'Little Angels',
      'ageRange': '5 mois - 2 ans',
      'color': '#7DF0FC',
      'titleColor': '#0F5A4D',
      'imagePath': 'assets/icons/enfant_classe1.png',
    },
    {
      'name': 'Young Explorers',
      'ageRange': '2 - 4 ans',
      'color': '#FEE34F',
      'titleColor': '#6B5A00',
      'imagePath': 'assets/icons/enfant-classe2.png',
    },
    {
      'name': 'Future Stars',
      'ageRange': '4 - 6 ans',
      'color': '#FF8B9E',
      'titleColor': '#7A1D1D',
      'imagePath': 'assets/icons/jeux-classe3.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingClass?.name ?? '',
    );
    _capacityController = TextEditingController(
      text: widget.existingClass?.capacity.toString() ?? '',
    );
    _selectedTemplate = widget.existingClass?.classTemplate;
    _selectedAgeRange = widget.existingClass?.ageRange;
    _selectedColor = widget.existingClass?.color;
    if (_selectedTemplate != null) {
      _nameController.text = _selectedTemplate!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTemplate == null || _selectedAgeRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un modèle de classe'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.existingClass != null) {
        // Update existing class
        final updatedClass = widget.existingClass!.copyWith(
          name: _selectedTemplate!,
          capacity: int.parse(_capacityController.text),
          classTemplate: _selectedTemplate,
          ageRange: _selectedAgeRange,
          color: _selectedColor,
        );
        await _classService.updateClass(updatedClass);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Classe modifiée avec succès')),
          );
        }
      } else {
        // Create new class
        final newClass = ClassModel(
          classId:
              '${DateTime.now().millisecondsSinceEpoch}_${_selectedTemplate?.replaceAll(' ', '_')}',
          name: _selectedTemplate!,
          capacity: int.parse(_capacityController.text),
          ageRange: _selectedAgeRange!,
          classTemplate: _selectedTemplate,
          color: _selectedColor,
          nurseryId: '', // Will be set by service
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _classService.createClass(newClass);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Classe créée avec succès')),
          );
        }
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Erreur: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.headerTop,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.existingClass != null
              ? 'Modifier la classe'
              : 'Créer une classe',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === SECTION: Template Selection ===
              const Text(
                'Sélectionnez un modèle de classe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1C),
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 2.2,
                  mainAxisSpacing: 12,
                ),
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  final isSelected = _selectedTemplate == template['name'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTemplate = template['name'];
                        _selectedAgeRange = template['ageRange'];
                        _selectedColor = template['color'];
                        _nameController.text = template['name']!;
                      });
                    },
                    child: _TemplateCard(
                      title: template['name']!,
                      ageGroup: template['ageRange']!,
                      backgroundColor: _parseHex(template['color']!),
                      titleColor: _parseHex(template['titleColor']!),
                      subtitleColor: _parseHex(
                        template['titleColor']!,
                      ).withValues(alpha: 0.8),
                      imagePath: template['imagePath']!,
                      isSelected: isSelected,
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // === SECTION: Class Details ===
              const Text(
                'Détails de la classe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1C),
                ),
              ),
              const SizedBox(height: 16),

              // Name field
              TextFormField(
                controller: _nameController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Nom de la classe (template)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le modèle de classe est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Capacity field
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Capacité maximale',
                  hintText: 'Ex: 15',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryButton,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La capacité est requise';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // === SUBMIT BUTTON ===
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          widget.existingClass != null
                              ? 'Modifier la classe'
                              : 'Créer la classe',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              if (widget.existingClass != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Supprimer la classe',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Supprimer la classe'),
                                content: const Text(
                                  'Confirmer la suppression de cette classe?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true &&
                                widget.existingClass != null) {
                              setState(() => _isLoading = true);
                              try {
                                await _classService.deleteClass(
                                  widget.existingClass!.classId,
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('✅ Classe supprimée'),
                                    ),
                                  );
                                }
                                widget.onSaved();
                                if (mounted) Navigator.pop(context);
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('❌ Erreur: $e')),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                }
                              }
                            }
                          },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _parseHex(String hex) {
    return Color(int.parse('0xFF${hex.substring(1)}'));
  }
}

class _TemplateCard extends StatelessWidget {
  final String title;
  final String ageGroup;
  final Color backgroundColor;
  final Color titleColor;
  final Color subtitleColor;
  final String imagePath;
  final bool isSelected;

  const _TemplateCard({
    required this.title,
    required this.ageGroup,
    required this.backgroundColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.imagePath,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isSelected ? Colors.black87 : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 8),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ageGroup,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: subtitleColor,
                  ),
                ),
                const SizedBox(height: 18),
                UnconstrainedBox(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: Text(
                      'Choisir',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.5),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  offset: const Offset(0, 6),
                  blurRadius: 12,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ClipOval(child: Image.asset(imagePath, fit: BoxFit.cover)),
          ),
        ],
      ),
    );
  }
}
