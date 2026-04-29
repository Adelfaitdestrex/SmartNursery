import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // 📦 IMPORT AJOUTÉ

// ── Modèles de données (Conservés intacts) ──

class FaceRecognitionResult {
  final bool recognized;
  final String personId;
  final String personName;
  final String message;

  FaceRecognitionResult({
    required this.recognized,
    required this.personId,
    required this.personName,
    required this.message,
  });
}

class FaceUserMatch {
  final String uid;
  final String displayName;
  final String role;

  const FaceUserMatch({
    required this.uid,
    required this.displayName,
    required this.role,
  });
}

class FaceIdentificationResult {
  final bool identified;
  final String userId;
  final String userDisplayName;
  final String userRole;
  final double confidence;
  final String message;

  FaceIdentificationResult({
    required this.identified,
    required this.userId,
    required this.userDisplayName,
    required this.userRole,
    required this.confidence,
    required this.message,
  });
}

class FaceRecognitionService {
  // 🚀 L'URL pointe vers ton serveur Python Cloud Run
  static const String _cloudRunUrl =
      'https://smartnursery-face-recognition-1023759846976.europe-west1.run.app/recognize';

  // URL locale pour développement (serveur Python)
  static const String _localServerUrl = String.fromEnvironment(
    'SMARTNURSERY_FACE_SERVER_URL',
    defaultValue: 'http://10.0.2.2:5000/recognize',
  );

  // Flag pour forcer l'utilisation d'une API spécifique.
  static const bool _useLocalServer = bool.fromEnvironment(
    'SMARTNURSERY_USE_LOCAL_FACE_SERVER',
    defaultValue: false,
  );

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isAuthorizedRole(String role) {
    final normalized = role.toLowerCase();
    return normalized == 'parent' ||
        normalized == 'admin' ||
        normalized == 'educateur' ||
        normalized == 'educator';
  }

  Future<List<FaceUserMatch>> findAuthorizedUsersByName({
    required String firstName,
    required String lastName,
  }) async {
    final normalizedFirst = firstName.trim();
    final normalizedLast = lastName.trim();

    if (normalizedFirst.isEmpty || normalizedLast.isEmpty) {
      return [];
    }

    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = [];

    try {
      final query = await _firestore
          .collection('users')
          .where('firstName', isEqualTo: normalizedFirst)
          .where('lastName', isEqualTo: normalizedLast)
          .get();
      docs = query.docs;
    } catch (_) {
      final fullName = '${normalizedFirst} ${normalizedLast}'.trim();
      final query = await _firestore
          .collection('users')
          .where('name', isEqualTo: fullName)
          .get();
      docs = query.docs;
    }

    return docs
        .map((doc) {
          final data = doc.data();
          final role = (data['role'] ?? '').toString();
          if (!_isAuthorizedRole(role)) return null;
          final displayName =
              (data['name'] ??
                      '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}')
                  .toString()
                  .trim();
          return FaceUserMatch(
            uid: doc.id,
            displayName: displayName.isEmpty ? doc.id : displayName,
            role: role,
          );
        })
        .whereType<FaceUserMatch>()
        .toList();
  }

  /// 🎯 CORRECTIF : Compression ajoutée et délai d'attente (timeout) augmenté
  Future<FaceRecognitionResult> recognizeFace(File imageFile) async {
    try {
      // 🗜️ 1. COMPRESSION DE L'IMAGE
      // On crée un chemin pour la nouvelle image allégée
      final String targetPath = '${imageFile.absolute.path}_compressed.jpg';

      final XFile? compressedXFile =
          await FlutterImageCompress.compressAndGetFile(
            imageFile.absolute.path,
            targetPath,
            quality: 70, // Qualité à 70% (Divise la taille par 10)
            minWidth: 800, // Réduit la taille pour aider l'IA
            minHeight: 800,
          );

      // Si la compression échoue, on garde l'image originale par sécurité
      final File fileToUpload = compressedXFile != null
          ? File(compressedXFile.path)
          : imageFile;

      // 📤 2. Upload de l'image allégée dans Firebase Storage
      final String filename =
          'temp_faces/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref(filename);
      await ref.putFile(fileToUpload);

      final imageUrl = await ref.getDownloadURL();

      // ⏳ 3. Appel API avec Timeout augmenté (60 secondes au lieu de 30)
      final response = await _callRecognitionEndpoint(
        imageUrl,
      ).timeout(const Duration(seconds: 60)); // <--- Timeout augmenté ici

      // 🗑️ 4. Nettoyage : Supprime l'image temporaire Firebase
      ref.delete().catchError((_) => null);

      // Nettoyage : Supprime l'image compressée du téléphone
      if (compressedXFile != null && await File(targetPath).exists()) {
        await File(targetPath).delete();
      }

      return _parseRecognitionResponse(response);
    } catch (e) {
      return FaceRecognitionResult(
        recognized: false,
        personId: '',
        personName: '',
        message: 'Erreur système/réseau : $e',
      );
    }
  }

  Future<http.Response> _callRecognitionEndpoint(String imageUrl) async {
    if (_useLocalServer) {
      return http.post(
        Uri.parse(_localServerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'imageUrl': imageUrl}),
      );
    } else {
      return http.post(
        Uri.parse(_cloudRunUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'imageUrl': imageUrl}),
      );
    }
  }

  FaceRecognitionResult _parseRecognitionResponse(http.Response response) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        final resultStr = (data['result'] as String? ?? '').toLowerCase();
        final recognized =
            (data['recognized'] as bool?) ?? resultStr.contains('autoris');

        if (recognized) {
          final personName =
              (data['personName'] ??
                      data['parentName'] ??
                      data['name'] ??
                      'Personne identifiée')
                  .toString();
          final personId =
              (data['personId'] ??
                      data['parentId'] ??
                      data['childId'] ??
                      'unknown')
                  .toString();

          return FaceRecognitionResult(
            recognized: true,
            personId: personId,
            personName: personName,
            message:
                data['message'] as String? ?? 'Visage reconnu avec succès ✅',
          );
        }

        return FaceRecognitionResult(
          recognized: false,
          personId: '',
          personName: '',
          message:
              (data['message'] as String?) ??
              (data['result'] as String?) ??
              'Visage non reconnu',
        );
      }

      return FaceRecognitionResult(
        recognized: false,
        personId: '',
        personName: '',
        message: 'Erreur serveur Cloud Run : Code ${response.statusCode}',
      );
    } catch (e) {
      return FaceRecognitionResult(
        recognized: false,
        personId: '',
        personName: '',
        message: 'Erreur de parsing JSON: $e',
      );
    }
  }

  Future<Map<String, List<String>>> getRegisteredFaces() async {
    try {
      final users = await _firestore.collection('users').get();
      final faces = <String, List<String>>{};

      for (final user in users.docs) {
        final personId = user.id;
        final role = (user.data()['role'] ?? '').toString();
        final isPickupPerson = _isAuthorizedRole(role);

        if (isPickupPerson) {
          try {
            final listResult = await _storage
                .ref('faces/parents/$personId')
                .listAll();
            faces[personId] = listResult.items.map((e) => e.name).toList();
          } catch (_) {
            faces[personId] = [];
          }
        }
      }

      return faces;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des visages : $e');
      return {};
    }
  }

  Future<bool> registerFace(String personId, File imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'faces/parents/$personId/$timestamp.jpg';
      final ref = _storage.ref(filename);
      await ref.putFile(imageFile);

      await _markPersonHasFaceData(personId);

      return true;
    } catch (e) {
      debugPrint('Erreur lors de l\'enregistrement du visage : $e');
      return false;
    }
  }

  Future<bool> registerFaceFromXFile(String personId, XFile imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'faces/parents/$personId/$timestamp.jpg';
      final ref = _storage.ref(filename);
      final Uint8List bytes = await imageFile.readAsBytes();

      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));

      await _markPersonHasFaceData(personId);

      return true;
    } catch (e) {
      debugPrint('Erreur lors de l\'enregistrement du visage (XFile) : $e');
      return false;
    }
  }

  Future<void> _markPersonHasFaceData(String personId) async {
    final payload = {
      'lastFaceRegisteredAt': FieldValue.serverTimestamp(),
      'hasFaceData': true,
    };
    await _firestore
        .collection('users')
        .doc(personId)
        .set(payload, SetOptions(merge: true));
  }

  Future<bool> deleteFaces(String personId) async {
    try {
      final listResult = await _storage
          .ref('faces/parents/$personId')
          .listAll();
      for (final item in listResult.items) {
        await item.delete();
      }

      await _firestore.collection('users').doc(personId).set({
        'hasFaceData': false,
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugPrint('Erreur lors de la suppression des visages : $e');
      return false;
    }
  }

  Future<FaceIdentificationResult> identifyUserFromAllFaces(
    File imageFile,
  ) async {
    try {
      final String tempFilename =
          'temp_faces/identify_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempRef = _storage.ref(tempFilename);
      await tempRef.putFile(imageFile);
      final capturedImageUrl = await tempRef.getDownloadURL();

      final usersSnapshot = await _firestore
          .collection('users')
          .where('hasFaceData', isEqualTo: true)
          .get();

      if (usersSnapshot.docs.isEmpty) {
        await tempRef.delete().catchError((_) => null);
        return FaceIdentificationResult(
          identified: false,
          userId: '',
          userDisplayName: '',
          userRole: '',
          confidence: 0.0,
          message: 'Aucun utilisateur avec visage enregistré',
        );
      }

      double bestConfidence = 0.0;
      String bestUserId = '';
      String bestUserName = '';
      String bestUserRole = '';

      for (final userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final userData = userDoc.data();
        final userName =
            (userData['name'] ??
                    '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}')
                .toString()
                .trim();
        final userRole = (userData['role'] ?? '').toString();

        try {
          final listResult = await _storage
              .ref('faces/parents/$userId')
              .listAll();
          for (final faceRef in listResult.items) {
            try {
              final registeredFaceUrl = await faceRef.getDownloadURL();
              final confidence = await _compareFaces(
                capturedImageUrl,
                registeredFaceUrl,
              );

              if (confidence > bestConfidence) {
                bestConfidence = confidence;
                bestUserId = userId;
                bestUserName = userName;
                bestUserRole = userRole;
              }
            } catch (e) {
              debugPrint('⚠️ Erreur comparaison visage: $e');
            }
          }
        } catch (e) {
          debugPrint('⚠️ Erreur récupération visages de $userId: $e');
        }
      }

      await tempRef.delete().catchError((_) => null);

      if (bestConfidence >= 0.7) {
        final userExists = await _firestore
            .collection('users')
            .doc(bestUserId)
            .get()
            .then((doc) => doc.exists);
        if (userExists) {
          return FaceIdentificationResult(
            identified: true,
            userId: bestUserId,
            userDisplayName: bestUserName,
            userRole: bestUserRole,
            confidence: bestConfidence,
            message:
                'Utilisateur identifié: $bestUserName (${(bestConfidence * 100).toStringAsFixed(1)}%)',
          );
        } else {
          return FaceIdentificationResult(
            identified: false,
            userId: '',
            userDisplayName: '',
            userRole: '',
            confidence: 0.0,
            message: 'Utilisateur trouvé par visage, mais absent de la bdd',
          );
        }
      }

      return FaceIdentificationResult(
        identified: false,
        userId: '',
        userDisplayName: '',
        userRole: '',
        confidence: bestConfidence,
        message: bestConfidence > 0.0
            ? 'Visage similaire trouvé (${(bestConfidence * 100).toStringAsFixed(1)}%), mais non concluant'
            : 'Aucun visage correspondant trouvé',
      );
    } catch (e) {
      return FaceIdentificationResult(
        identified: false,
        userId: '',
        userDisplayName: '',
        userRole: '',
        confidence: 0.0,
        message: 'Erreur lors de l\'identification: $e',
      );
    }
  }

  Future<double> _compareFaces(String imageUrl1, String imageUrl2) async {
    try {
      if (_useLocalServer) {
        final response = await http
            .post(
              Uri.parse(
                '${_localServerUrl.replaceAll('/recognize', '')}/compare',
              ),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'image_url_1': imageUrl1,
                'image_url_2': imageUrl2,
              }),
            )
            // ⏳ Timeout augmenté à 30 secondes pour les comparaisons multiples
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;
          return confidence.clamp(0.0, 1.0);
        }
      } else {
        final response = await http
            .post(
              Uri.parse(_cloudRunUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'imageUrl': imageUrl1}),
            )
            // ⏳ Timeout augmenté à 30 secondes pour la sécurité du réseau
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final recognized = (data['recognized'] as bool?) ?? false;
          return recognized ? 0.85 : 0.0;
        }
      }
      return 0.0;
    } catch (e) {
      debugPrint('⚠️ Erreur lors de la comparaison: $e');
      return 0.0;
    }
  }
}
