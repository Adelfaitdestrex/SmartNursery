import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smartnursery/features/A_propos_enfant/models/child_model.dart';

class ChildService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===========================
  // CREATE
  // ===========================

  /// Create child with explicit nursery ID (used when admin creates child for parent)
  Future<ChildModel> createChildWithNursery({
    required ChildModel childData,
    required String nurseryId,
  }) async {
    try {
      if (nurseryId.isEmpty) {
        throw Exception('Nursery ID cannot be empty');
      }

      final newChild = childData.copyWith(
        nurseryId: nurseryId,
        enrollmentDate: DateTime.now(),
      );

      await _firestore
          .collection('enfants')
          .doc(newChild.childId)
          .set(newChild.toMap());

      debugPrint(
        '✅ Child created: ${newChild.firstName} ${newChild.lastName} in nursery $nurseryId',
      );
      return newChild;
    } catch (e) {
      debugPrint('❌ Error creating child: $e');
      rethrow;
    }
  }

  Future<ChildModel> createChild(ChildModel childData) async {
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
      final newChild = childData.copyWith(
        nurseryId: nurseryId,
        enrollmentDate: now,
      );

      await _firestore
          .collection('enfants')
          .doc(newChild.childId)
          .set(newChild.toMap());

      debugPrint('✅ Child created: ${newChild.firstName} ${newChild.lastName}');
      return newChild;
    } catch (e) {
      debugPrint('❌ Error creating child: $e');
      rethrow;
    }
  }

  // ===========================
  // READ
  // ===========================

  /// Get all children for the current user's nursery
  Stream<List<ChildModel>> getChildrenStream() {
    try {
      return _firestore
          .collection('enfants')
          .orderBy('firstName')
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
                .map((doc) => ChildModel.fromMap(doc.data(), doc.id))
                .toList();
          });
    } catch (e) {
      debugPrint('❌ Error fetching children: $e');
      return Stream.value([]);
    }
  }

  /// Get children for a specific parent
  Stream<List<ChildModel>> getChildrenByParentStream(String parentId) {
    try {
      return _firestore
          .collection('enfants')
          .where('parentIds', arrayContains: parentId)
          .orderBy('firstName')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => ChildModel.fromMap(doc.data(), doc.id))
                .toList(),
          );
    } catch (e) {
      debugPrint('❌ Error fetching children by parent: $e');
      return Stream.value([]);
    }
  }

  /// Get a single child by ID
  Future<ChildModel?> getChildById(String childId) async {
    try {
      final doc = await _firestore.collection('enfants').doc(childId).get();
      if (!doc.exists) return null;
      return ChildModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      debugPrint('❌ Error fetching child: $e');
      return null;
    }
  }

  // ===========================
  // UPDATE
  // ===========================

  Future<void> updateChild(ChildModel childData) async {
    try {
      await _firestore
          .collection('enfants')
          .doc(childData.childId)
          .update(childData.toMap());
      debugPrint(
        '✅ Child updated: ${childData.firstName} ${childData.lastName}',
      );
    } catch (e) {
      debugPrint('❌ Error updating child: $e');
      rethrow;
    }
  }

  // ===========================
  // DELETE
  // ===========================

  Future<void> deleteChild(String childId) async {
    try {
      // Get child data first
      final childDoc = await _firestore
          .collection('enfants')
          .doc(childId)
          .get();

      if (childDoc.exists) {
        final classId = childDoc.data()?['classId'];

        // Remove child from class if assigned
        if (classId != null && classId.isNotEmpty) {
          await _firestore.collection('classes').doc(classId).update({
            'childrenIds': FieldValue.arrayRemove([childId]),
            'currentSize': FieldValue.increment(-1),
          });
        }
      }

      // Delete the child document
      await _firestore.collection('enfants').doc(childId).delete();
      debugPrint('✅ Child deleted: $childId');
    } catch (e) {
      debugPrint('❌ Error deleting child: $e');
      rethrow;
    }
  }

  // ===========================
  // PARENT MANAGEMENT
  // ===========================

  /// Add parent to child
  Future<void> addParentToChild(String childId, String parentId) async {
    try {
      final childDoc = await _firestore
          .collection('enfants')
          .doc(childId)
          .get();
      if (!childDoc.exists) throw Exception('Child not found');

      final parentIds = List<String>.from(childDoc.data()?['parentIds'] ?? []);
      if (!parentIds.contains(parentId)) {
        parentIds.add(parentId);
        await _firestore.collection('enfants').doc(childId).update({
          'parentIds': parentIds,
        });
      }

      debugPrint('✅ Parent $parentId added to child $childId');
    } catch (e) {
      debugPrint('❌ Error adding parent to child: $e');
      rethrow;
    }
  }

  /// Remove parent from child
  Future<void> removeParentFromChild(String childId, String parentId) async {
    try {
      final childDoc = await _firestore
          .collection('enfants')
          .doc(childId)
          .get();
      if (!childDoc.exists) throw Exception('Child not found');

      final parentIds = List<String>.from(childDoc.data()?['parentIds'] ?? []);
      parentIds.removeWhere((id) => id == parentId);

      await _firestore.collection('enfants').doc(childId).update({
        'parentIds': parentIds,
      });

      debugPrint('✅ Parent $parentId removed from child $childId');
    } catch (e) {
      debugPrint('❌ Error removing parent from child: $e');
      rethrow;
    }
  }

  // ===========================
  // CLASS MANAGEMENT
  // ===========================

  /// Assign child to class
  Future<void> assignChildToClass(String childId, String classId) async {
    try {
      // 1. Mettre à jour le document de l'enfant (classId)
      await _firestore.collection('enfants').doc(childId).update({
        'classId': classId,
      });

      // 2. Mettre à jour le document de la classe (merge:true = crée si absent)
      await _firestore.collection('classes').doc(classId).set({
        'childrenIds': FieldValue.arrayUnion([childId]),
        'currentSize': FieldValue.increment(1),
      }, SetOptions(merge: true));

      debugPrint('✅ Child $childId assigned to class $classId');
    } catch (e) {
      debugPrint('❌ Error assigning child to class: $e');
      rethrow;
    }
  }

  /// Remove child from class
  Future<void> removeChildFromClass(String childId) async {
    try {
      final childDoc = await _firestore
          .collection('enfants')
          .doc(childId)
          .get();
      if (!childDoc.exists) throw Exception('Child not found');

      final classId = childDoc.data()?['classId'];

      if (classId != null && classId.isNotEmpty) {
        // Update class document
        await _firestore.collection('classes').doc(classId).update({
          'childrenIds': FieldValue.arrayRemove([childId]),
          'currentSize': FieldValue.increment(-1),
        });

        // Update child document
        await _firestore.collection('enfants').doc(childId).update({
          'classId': null,
        });
      }

      debugPrint('✅ Child $childId removed from class');
    } catch (e) {
      debugPrint('❌ Error removing child from class: $e');
      rethrow;
    }
  }

  // ===========================
  // UTILITIES
  // ===========================

  /// Get available classes for a specific nursery
  Future<List<Map<String, dynamic>>> getAvailableClassesForNursery(
    String nurseryId,
  ) async {
    try {
      if (nurseryId.isEmpty) {
        debugPrint('⚠️ Nursery ID is empty, returning empty classes list');
        return [];
      }

      final snapshot = await _firestore
          .collection('classes')
          .where('nurseryId', isEqualTo: nurseryId)
          .get();

      debugPrint(
        '✅ Found ${snapshot.docs.length} classes for nursery $nurseryId',
      );
      return snapshot.docs
          .map(
            (doc) => {
              'classId': doc.id,
              'name': doc.data()['name'] ?? '',
              'ageRange': doc.data()['ageRange'] ?? '',
            },
          )
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching classes for nursery: $e');
      return [];
    }
  }

  /// Get available classes
  Future<List<Map<String, dynamic>>> getAvailableClasses() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final nurseryId = userDoc.data()?['nurseryId'] ?? '';

      final snapshot = await _firestore
          .collection('classes')
          .where('nurseryId', isEqualTo: nurseryId)
          .get();

      return snapshot.docs
          .map(
            (doc) => {
              'classId': doc.id,
              'name': doc.data()['name'] ?? '',
              'ageRange': doc.data()['ageRange'] ?? '',
            },
          )
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching available classes: $e');
      return [];
    }
  }
}
