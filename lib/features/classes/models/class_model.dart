class ClassModel {
  final String classId;
  final String name;
  final String ageRange; // "5-24 months", "2-4 years", "4-6 years"
  final String?
  classTemplate; // "Little Angel", "Future Star", "Little Explorer"
  final int capacity;
  final int currentSize;
  final List<String> childrenIds;
  final List<String> educatorIds;
  final String? color; // Hex color code
  final String nurseryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClassModel({
    required this.classId,
    required this.name,
    required this.ageRange,
    this.classTemplate,
    required this.capacity,
    this.currentSize = 0,
    this.childrenIds = const [],
    this.educatorIds = const [],
    this.color,
    required this.nurseryId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'name': name,
      'ageRange': ageRange,
      'classTemplate': classTemplate,
      'capacity': capacity,
      'currentSize': currentSize,
      'childrenIds': childrenIds,
      'educatorIds': educatorIds,
      'color': color,
      'nurseryId': nurseryId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create from Firestore document
  factory ClassModel.fromMap(Map<String, dynamic> map, String docId) {
    return ClassModel(
      classId: map['classId'] ?? docId,
      name: map['name'] ?? '',
      ageRange: map['ageRange'] ?? '',
      classTemplate: map['classTemplate'],
      capacity: map['capacity'] ?? 0,
      currentSize: map['currentSize'] ?? 0,
      childrenIds: List<String>.from(map['childrenIds'] ?? []),
      educatorIds: List<String>.from(map['educatorIds'] ?? []),
      color: map['color'],
      nurseryId: map['nurseryId'] ?? '',
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  // Copy with modifications
  ClassModel copyWith({
    String? classId,
    String? name,
    String? ageRange,
    String? classTemplate,
    int? capacity,
    int? currentSize,
    List<String>? childrenIds,
    List<String>? educatorIds,
    String? color,
    String? nurseryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassModel(
      classId: classId ?? this.classId,
      name: name ?? this.name,
      ageRange: ageRange ?? this.ageRange,
      classTemplate: classTemplate ?? this.classTemplate,
      capacity: capacity ?? this.capacity,
      currentSize: currentSize ?? this.currentSize,
      childrenIds: childrenIds ?? this.childrenIds,
      educatorIds: educatorIds ?? this.educatorIds,
      color: color ?? this.color,
      nurseryId: nurseryId ?? this.nurseryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
