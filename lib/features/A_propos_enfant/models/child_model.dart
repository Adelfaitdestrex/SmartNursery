import 'package:cloud_firestore/cloud_firestore.dart';

class ChildModel {
  final String childId;
  final String firstName;
  final String lastName;
  final String gender; // 'M', 'F', 'Other'
  final DateTime dateOfBirth;
  final String? classId; // ID de la classe assignée
  final List<String> parentIds; // IDs des parents
  final List<String> guardiansList; // Liste des tuteurs
  final List<String> allergies; // Listes des allergies
  final Map<String, dynamic>? medicinalInfo; // Informations médicales
  final List<String> authorizedPickup; // Personnes autorisées
  final List<String> photoGallery; // URLs des photos
  final Map<String, dynamic>? emergencyContact; // Contact d'urgence
  final DateTime enrollmentDate;
  final bool isActive;
  final String nurseryId;

  ChildModel({
    required this.childId,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    this.classId,
    this.parentIds = const [],
    this.guardiansList = const [],
    this.allergies = const [],
    this.medicinalInfo,
    this.authorizedPickup = const [],
    this.photoGallery = const [],
    this.emergencyContact,
    required this.enrollmentDate,
    this.isActive = true,
    required this.nurseryId,
  });

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'classId': classId,
      'parentIds': parentIds,
      'guardiansList': guardiansList,
      'allergies': allergies,
      'medicinalInfo': medicinalInfo,
      'authorizedPickup': authorizedPickup,
      'photoGallery': photoGallery,
      'emergencyContact': emergencyContact,
      'enrollmentDate': Timestamp.fromDate(enrollmentDate),
      'isActive': isActive,
      'nurseryId': nurseryId,
    };
  }

  // Create from Firestore map
  factory ChildModel.fromMap(Map<String, dynamic> map, String childId) {
    return ChildModel(
      childId: childId,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      gender: map['gender'] ?? 'Other',
      dateOfBirth:
          (map['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      classId: map['classId'],
      parentIds: List<String>.from(map['parentIds'] ?? []),
      guardiansList: List<String>.from(map['guardiansList'] ?? []),
      allergies: List<String>.from(map['allergies'] ?? []),
      medicinalInfo: map['medicinalInfo'],
      authorizedPickup: List<String>.from(map['authorizedPickup'] ?? []),
      photoGallery: List<String>.from(map['photoGallery'] ?? []),
      emergencyContact: map['emergencyContact'],
      enrollmentDate:
          (map['enrollmentDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      nurseryId: map['nurseryId'] ?? '',
    );
  }

  // Copy with method
  ChildModel copyWith({
    String? childId,
    String? firstName,
    String? lastName,
    String? gender,
    DateTime? dateOfBirth,
    String? classId,
    List<String>? parentIds,
    List<String>? guardiansList,
    List<String>? allergies,
    Map<String, dynamic>? medicinalInfo,
    List<String>? authorizedPickup,
    List<String>? photoGallery,
    Map<String, dynamic>? emergencyContact,
    DateTime? enrollmentDate,
    bool? isActive,
    String? nurseryId,
  }) {
    return ChildModel(
      childId: childId ?? this.childId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      classId: classId ?? this.classId,
      parentIds: parentIds ?? this.parentIds,
      guardiansList: guardiansList ?? this.guardiansList,
      allergies: allergies ?? this.allergies,
      medicinalInfo: medicinalInfo ?? this.medicinalInfo,
      authorizedPickup: authorizedPickup ?? this.authorizedPickup,
      photoGallery: photoGallery ?? this.photoGallery,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      isActive: isActive ?? this.isActive,
      nurseryId: nurseryId ?? this.nurseryId,
    );
  }
}
