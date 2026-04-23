import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smartnursery/features/classes/models/class_model.dart';

class ClassService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===========================
  // CREATE
  // ===========================

  Future<ClassModel> createClass(ClassModel classData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get nursery ID from user data
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final nurseryId = userDoc.data()?['nurseryId'] ?? '';

      if (nurseryId.isEmpty) {
        throw Exception('User does not belong to a nursery');
      }

      final now = DateTime.now();
      final newClass = classData.copyWith(
        nurseryId: nurseryId,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('classes')
          .doc(newClass.classId)
          .set(newClass.toMap());

      debugPrint('✅ Class created: ${newClass.name}');
      return newClass;
    } catch (e) {
      debugPrint('❌ Error creating class: $e');
      rethrow;
    }
  }

  // ===========================
  // READ
  // ===========================

  /// Get all classes for the current user's nursery
  Stream<List<ClassModel>> getClassesStream() {
    try {
      return _firestore
          .collection('classes')
          .orderBy('name')
          .snapshots()
          .asyncMap((snapshot) async {
            final user = _auth.currentUser;
            if (user == null) return [];

            final userDoc = await _firestore
                .collection('users')
                .doc(user.uid)
                .get();
            final nurseryId = userDoc.data()?['nurseryId'] ?? '';

            return snapshot.docs
                .where((doc) => doc.data()['nurseryId'] == nurseryId)
                .map((doc) => ClassModel.fromMap(doc.data(), doc.id))
                .toList();
          });
    } catch (e) {
      debugPrint('❌ Error fetching classes: $e');
      return Stream.value([]);
    }
  }

  /// Get a single class by ID
  Future<ClassModel?> getClassById(String classId) async {
    try {
      final doc = await _firestore.collection('classes').doc(classId).get();
      if (!doc.exists) return null;
      return ClassModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      debugPrint('❌ Error fetching class: $e');
      return null;
    }
  }

  // ===========================
  // UPDATE
  // ===========================

  Future<void> updateClass(ClassModel classData) async {
    try {
      final updatedClass = classData.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection('classes')
          .doc(classData.classId)
          .update(updatedClass.toMap());
      debugPrint('✅ Class updated: ${classData.name}');
    } catch (e) {
      debugPrint('❌ Error updating class: $e');
      rethrow;
    }
  }

  // ===========================
  // CHILD & EDUCATOR MANAGEMENT
  // ===========================

  /// Add a child to a class
  Future<void> addChildToClass(String classId, String childId) async {
    try {
      final classDoc = await _firestore
          .collection('classes')
          .doc(classId)
          .get();
      if (!classDoc.exists) throw Exception('Class not found');

      final currentChildren = List<String>.from(
        classDoc.data()?['childrenIds'] ?? [],
      );
      if (!currentChildren.contains(childId)) {
        currentChildren.add(childId);
      }

      await _firestore.collection('classes').doc(classId).update({
        'childrenIds': currentChildren,
        'currentSize': currentChildren.length,
        'updatedAt': DateTime.now(),
      });

      // Also update the child document
      await _firestore.collection('enfants').doc(childId).update({
        'classId': classId,
      });

      debugPrint('✅ Child $childId added to class $classId');
    } catch (e) {
      debugPrint('❌ Error adding child to class: $e');
      rethrow;
    }
  }

  /// Remove a child from a class
  Future<void> removeChildFromClass(String classId, String childId) async {
    try {
      final classDoc = await _firestore
          .collection('classes')
          .doc(classId)
          .get();
      if (!classDoc.exists) throw Exception('Class not found');

      final currentChildren = List<String>.from(
        classDoc.data()?['childrenIds'] ?? [],
      );
      currentChildren.removeWhere((id) => id == childId);

      await _firestore.collection('classes').doc(classId).update({
        'childrenIds': currentChildren,
        'currentSize': currentChildren.length,
        'updatedAt': DateTime.now(),
      });

      debugPrint('✅ Child $childId removed from class $classId');
    } catch (e) {
      debugPrint('❌ Error removing child from class: $e');
      rethrow;
    }
  }

  /// Add an educator to a class
  Future<void> addEducatorToClass(String classId, String educatorId) async {
    try {
      final classDoc = await _firestore
          .collection('classes')
          .doc(classId)
          .get();
      if (!classDoc.exists) throw Exception('Class not found');

      final currentEducators = List<String>.from(
        classDoc.data()?['educatorIds'] ?? [],
      );
      if (!currentEducators.contains(educatorId)) {
        currentEducators.add(educatorId);
      }

      await _firestore.collection('classes').doc(classId).update({
        'educatorIds': currentEducators,
        'updatedAt': DateTime.now(),
      });

      debugPrint('✅ Educator $educatorId added to class $classId');
    } catch (e) {
      debugPrint('❌ Error adding educator to class: $e');
      rethrow;
    }
  }

  /// Remove an educator from a class
  Future<void> removeEducatorFromClass(
    String classId,
    String educatorId,
  ) async {
    try {
      final classDoc = await _firestore
          .collection('classes')
          .doc(classId)
          .get();
      if (!classDoc.exists) throw Exception('Class not found');

      final currentEducators = List<String>.from(
        classDoc.data()?['educatorIds'] ?? [],
      );
      currentEducators.removeWhere((id) => id == educatorId);

      await _firestore.collection('classes').doc(classId).update({
        'educatorIds': currentEducators,
        'updatedAt': DateTime.now(),
      });

      debugPrint('✅ Educator $educatorId removed from class $classId');
    } catch (e) {
      debugPrint('❌ Error removing educator from class: $e');
      rethrow;
    }
  }

  // ===========================
  // DELETE
  // ===========================

  Future<void> deleteClass(String classId) async {
    try {
      // Remove all children from this class
      final classDoc = await _firestore
          .collection('classes')
          .doc(classId)
          .get();
      if (classDoc.exists) {
        final childrenIds = List<String>.from(
          classDoc.data()?['childrenIds'] ?? [],
        );
        for (final childId in childrenIds) {
          await _firestore.collection('enfants').doc(childId).update({
            'classId': null,
          });
        }
      }

      await _firestore.collection('classes').doc(classId).delete();
      debugPrint('✅ Class deleted: $classId');
    } catch (e) {
      debugPrint('❌ Error deleting class: $e');
      rethrow;
    }
  }

  // ===========================
  // HELPERS
  // ===========================

  /// Get educators available for assignment
  Future<List<Map<String, String>>> getAvailableEducators() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final nurseryId = userDoc.data()?['nurseryId'] ?? '';

      final snapshot = await _firestore
          .collection('users')
          .where('nurseryId', isEqualTo: nurseryId)
          .where('role', whereIn: ['educator', 'director'])
          .get();

      return snapshot.docs
          .map(
            (doc) => {
              'id': doc.id,
              'name':
                  '${doc.data()['firstName'] ?? ''} ${doc.data()['lastName'] ?? ''}',
            },
          )
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching educators: $e');
      return [];
    }
  }

  /// Get children available for assignment
  Future<List<Map<String, String>>> getAvailableChildren() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final nurseryId = userDoc.data()?['nurseryId'] ?? '';

      final snapshot = await _firestore
          .collection('enfants')
          .where('nurseryId', isEqualTo: nurseryId)
          .get();

      return snapshot.docs
          .map(
            (doc) => {
              'id': doc.id,
              'name':
                  '${doc.data()['firstName'] ?? ''} ${doc.data()['lastName'] ?? ''}',
            },
          )
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching children: $e');
      return [];
    }
  }

  /// Class templates with predefined colors
  static const Map<String, Map<String, String>> classTemplates = {
    'Little Angel': {'description': '5 mois - 2 ans', 'color': '0xFF7DF0FC'},
    'Future Star': {'description': '4 - 6 ans', 'color': '0xFFFF8B9E'},
    'Little Explorer': {'description': '2 - 4 ans', 'color': '0xFFFEE34F'},
  };
}
