import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';
import 'package:smartnursery/features/classes/models/class_model.dart';
import 'package:smartnursery/features/classes/screens/manage_class_form_page.dart';
import 'package:smartnursery/features/classes/services/class_service.dart';
import 'package:smartnursery/shared/widgets/shared_header.dart';

class AdminManageClassesScreen extends StatefulWidget {
  const AdminManageClassesScreen({super.key});

  @override
  State<AdminManageClassesScreen> createState() =>
      _AdminManageClassesScreenState();
}

class _AdminManageClassesScreenState extends State<AdminManageClassesScreen> {
  final _classService = ClassService();
  String? _expandedClassId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: SharedHeader(
          title: 'Gérer les classes',
          leftWidget: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 32,
          ),
          leftLabel: null,
          onLeftTap: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<ClassModel>>(
        stream: _classService.getClassesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final classes = snapshot.data ?? [];

          if (classes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.class_, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune classe créée',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Créez votre première classe',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classData = classes[index];
              final isExpanded = _expandedClassId == classData.classId;

              return _ClassCard(
                classData: classData,
                isExpanded: isExpanded,
                onTap: () {
                  setState(() {
                    _expandedClassId = isExpanded ? null : classData.classId;
                  });
                },
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManageClassFormPage(
                        existingClass: classData,
                        onSaved: () {
                          setState(() {});
                        },
                      ),
                    ),
                  );
                },
                onDelete: () {
                  _showDeleteConfirmation(context, classData);
                },
                classService: _classService,
                onRefresh: () {
                  setState(() {});
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManageClassFormPage(
                onSaved: () {
                  setState(() {});
                },
              ),
            ),
          );
        },
        backgroundColor: AppColors.primaryButton,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ClassModel classData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la classe?'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${classData.name}"? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _classService.deleteClass(classData.classId);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Classe supprimée')),
                  );
                  setState(() {});
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('❌ Erreur: $e')));
                }
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CLASS CARD WITH EXPANSION
// =============================================================================

class _ClassCard extends StatefulWidget {
  final ClassModel classData;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ClassService classService;
  final VoidCallback onRefresh;

  const _ClassCard({
    required this.classData,
    required this.isExpanded,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.classService,
    required this.onRefresh,
  });

  @override
  State<_ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<_ClassCard> {
  List<Map<String, String>> _children = [];
  List<Map<String, String>> _educators = [];
  List<Map<String, String>> _availableChildren = [];
  List<Map<String, String>> _availableEducators = [];
  bool _isLoadingChildren = false;
  bool _isLoadingEducators = false;

  @override
  void didUpdateWidget(_ClassCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded && !oldWidget.isExpanded) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (!widget.isExpanded) return;

    setState(() {
      _isLoadingChildren = true;
      _isLoadingEducators = true;
    });

    // Load available children and educators
    final availableChildren = await widget.classService.getAvailableChildren();
    final availableEducators = await widget.classService
        .getAvailableEducators();

    // Filter already assigned ones
    _children = availableChildren
        .where((child) => widget.classData.childrenIds.contains(child['id']))
        .toList();
    _educators = availableEducators
        .where(
          (educator) => widget.classData.educatorIds.contains(educator['id']),
        )
        .toList();
    _availableChildren = availableChildren
        .where((child) => !widget.classData.childrenIds.contains(child['id']))
        .toList();
    _availableEducators = availableEducators
        .where(
          (educator) => !widget.classData.educatorIds.contains(educator['id']),
        )
        .toList();

    setState(() {
      _isLoadingChildren = false;
      _isLoadingEducators = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorHex = widget.classData.color ?? '#7DF0FC';
    final color = Color(int.parse('0xFF${colorHex.substring(1)}'));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.feedCard,
      ),
      child: Column(
        children: [
          // === HEADER ===
          GestureDetector(
            onTap: () {
              widget.onTap();
              if (widget.isExpanded) {
                _loadData();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(widget.isExpanded ? 0 : 16),
                  bottomRight: Radius.circular(widget.isExpanded ? 0 : 16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.classData.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.classData.ageRange,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.classData.currentSize}/${widget.classData.capacity} enfants',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: widget.onEdit,
                        color: color,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: widget.onDelete,
                        color: Colors.red,
                      ),
                    ],
                  ),
                  Icon(
                    widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: color,
                  ),
                ],
              ),
            ),
          ),
          // === EXPANDED CONTENT ===
          if (widget.isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === CHILDREN SECTION ===
                  _buildSection(
                    title: 'Enfants (${widget.classData.currentSize})',
                    icon: Icons.child_care,
                    items: _children,
                    isLoading: _isLoadingChildren,
                    onAdd: () {
                      _showAddChildDialog();
                    },
                    onRemove: (childId) async {
                      await widget.classService.removeChildFromClass(
                        widget.classData.classId,
                        childId,
                      );
                      widget.onRefresh();
                      _loadData();
                    },
                    emptyMessage: 'Aucun enfant assigné',
                  ),
                  const SizedBox(height: 24),
                  // === EDUCATORS SECTION ===
                  _buildSection(
                    title: 'Éducateurs',
                    icon: Icons.school,
                    items: _educators,
                    isLoading: _isLoadingEducators,
                    onAdd: () {
                      _showAddEducatorDialog();
                    },
                    onRemove: (educatorId) async {
                      await widget.classService.removeEducatorFromClass(
                        widget.classData.classId,
                        educatorId,
                      );
                      widget.onRefresh();
                      _loadData();
                    },
                    emptyMessage: 'Aucun éducateur assigné',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Map<String, String>> items,
    required bool isLoading,
    required VoidCallback onAdd,
    required Function(String) onRemove,
    required String emptyMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryButton, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          )
        else if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              emptyMessage,
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
        else
          Column(
            children: items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['name'] ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        onRemove(item['id'] ?? '');
                      },
                      color: Colors.red,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _showAddChildDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un enfant'),
        content: _availableChildren.isEmpty
            ? const Text('Aucun enfant disponible')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableChildren.length,
                  itemBuilder: (context, index) {
                    final child = _availableChildren[index];
                    return ListTile(
                      title: Text(child['name'] ?? ''),
                      onTap: () async {
                        await widget.classService.addChildToClass(
                          widget.classData.classId,
                          child['id'] ?? '',
                        );
                        widget.onRefresh();
                        _loadData();
                        if (mounted) Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }

  void _showAddEducatorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un éducateur'),
        content: _availableEducators.isEmpty
            ? const Text('Aucun éducateur disponible')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableEducators.length,
                  itemBuilder: (context, index) {
                    final educator = _availableEducators[index];
                    return ListTile(
                      title: Text(educator['name'] ?? ''),
                      onTap: () async {
                        await widget.classService.addEducatorToClass(
                          widget.classData.classId,
                          educator['id'] ?? '',
                        );
                        widget.onRefresh();
                        _loadData();
                        if (mounted) Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }
}
