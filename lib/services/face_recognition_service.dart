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

  String _normalizeName(String value) {
    const withDiacritics =
        'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ';
    const withoutDiacritics =
        'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeCcIIIIiiiiUUUUuuuuyNn';

    var normalized = value.trim().toLowerCase();
    for (var i = 0; i < withDiacritics.length; i++) {
      normalized = normalized.replaceAll(
        withDiacritics[i].toLowerCase(),
        withoutDiacritics[i].toLowerCase(),
      );
    }

    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9 ]'), '');
    return normalized;
  }

  bool _isAuthorizedRole(String role) {
    final normalized = role.toLowerCase();
    return normalized == 'parent' ||
        normalized == 'admin' ||
        normalized == 'educateur' ||
        normalized == 'educator';
  }

  // ============================================================================
  // 🗜️ UTILITAIRE COMPRESSION (DRY)
  // ============================================================================

  /// Compresse une image pour réduire la bande passante et éviter OOM sur backend
  /// Retourne le fichier compressé (ou l'original si compression échoue)
  Future<File> _compressImageFile(File imageFile) async {
    try {
      final String targetPath = '${imageFile.absolute.path}_compressed.jpg';

      final XFile? compressedXFile =
          await FlutterImageCompress.compressAndGetFile(
            imageFile.absolute.path,
            targetPath,
            quality: 70, // Qualité à 70% (réduit taille par 10)
            minWidth: 800,
            minHeight: 800,
          );

      if (compressedXFile != null) {
        debugPrint('✅ Image compressée: $targetPath');
        return File(compressedXFile.path);
      }

      // Fallback si compression échoue
      debugPrint('⚠️ Compression échouée, utilisation de l\'original');
      return imageFile;
    } catch (e) {
      debugPrint('⚠️ Erreur compression: $e, utilisation de l\'original');
      return imageFile;
    }
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

  Future<List<FaceUserMatch>> findAuthorizedUsersByNameFlexible({
    required String firstName,
    required String lastName,
  }) async {
    final normalizedFirst = firstName.trim();
    final normalizedLast = lastName.trim();

    if (normalizedFirst.isEmpty || normalizedLast.isEmpty) {
      return [];
    }

    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final wantedFullName = _normalizeName('$normalizedFirst $normalizedLast');

      return usersSnapshot.docs
          .where((doc) {
            final data = doc.data();
            final role = (data['role'] ?? '').toString();
            if (!_isAuthorizedRole(role)) {
              return false;
            }

            final firstNameValue = (data['firstName'] ?? '').toString();
            final lastNameValue = (data['lastName'] ?? '').toString();
            final nameValue = (data['name'] ?? '').toString();

            final docFullName = _normalizeName(
              [
                firstNameValue,
                lastNameValue,
              ].where((part) => part.isNotEmpty).join(' '),
            );
            final docStoredName = _normalizeName(nameValue);

            return docFullName == wantedFullName ||
                docStoredName == wantedFullName ||
                docStoredName.contains(wantedFullName) ||
                wantedFullName.contains(docStoredName);
          })
          .map((doc) {
            final data = doc.data();
            final role = (data['role'] ?? '').toString();
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
          .toList();
    } catch (e) {
      debugPrint('Erreur recherche utilisateur autorisé: $e');
      return [];
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

  // ============================================================================
  // ✨ VERSION PRO: ENREGISTREMENT AVEC ENCODAGE
  // ============================================================================

  Future<bool> registerFaceProWithEncoding(
    String personId,
    XFile imageFile,
  ) async {
    try {
      debugPrint('🚀 [PRO] Enregistrement visage avec encodage pour $personId');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'face_${timestamp}.jpg';

      // 1️⃣ Compression de l'image avant upload
      final imageFileObj = File(imageFile.path);
      final compressedFile = await _compressImageFile(imageFileObj);

      // 2️⃣ Upload temporaire pour calcul backend
      final tempFilename = 'temp_faces/register_${timestamp}.jpg';
      final tempRef = _storage.ref(tempFilename);
      final permanentRef = _storage.ref('faces/parents/$personId/$fileName');

      final Uint8List bytes = await compressedFile.readAsBytes();
      await tempRef.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final imageUrl = await tempRef.getDownloadURL();

      debugPrint('📤 Image uploadée: $imageUrl');

      // 3️⃣ Appel backend PRO: calcul + sauvegarde encodage
      final serverUrl = _useLocalServer
          ? _localServerUrl.replaceAll('/recognize', '/register_parent_face')
          : 'https://smartnursery-face-recognition-1023759846976.europe-west1.run.app/register_parent_face';

      debugPrint('📤 Envoi au backend: $serverUrl');
      debugPrint('📦 Body: imageUrl=$imageUrl, parentId=$personId');

      final response = await http
          .post(
            Uri.parse(serverUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'imageUrl': imageUrl, 'parentId': personId}),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('📥 Réponse backend: statusCode=${response.statusCode}');
      debugPrint('📥 Body: ${response.body}');

      // Suppression du fichier temporaire
      await tempRef.delete().catchError((_) => null);

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final success = (data['success'] as bool?) ?? false;
          final message = (data['message'] as String?) ?? '';

          debugPrint('✅ Backend response: success=$success, message=$message');

          if (success) {
            debugPrint('✅ Encodage calculé et sauvegardé dans Firestore');

            // Sauvegarde permanente de l'image (compressée) pour l'affichage et la suppression
            await permanentRef.putData(
              bytes,
              SettableMetadata(contentType: 'image/jpeg'),
            );
            debugPrint(
              '✅ Photo sauvegardée dans Storage: faces/parents/$personId/$fileName',
            );

            // Note: Le backend a déjà sauvegardé l'encodage dans Firestore
            // On met à jour juste les métadonnées locales
            await _firestore.collection('users').doc(personId).set({
              'hasFaceData': true,
              'lastFaceRegisteredAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            return true;
          } else {
            debugPrint('❌ Backend returned success=false: $message');
            return false;
          }
        } catch (parseError) {
          debugPrint('❌ Erreur parsing JSON: $parseError');
          debugPrint('❌ Body reçu: ${response.body}');
          return false;
        }
      } else {
        debugPrint('❌ HTTP Error: ${response.statusCode}');
        debugPrint('❌ Body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Erreur enregistrement PRO: $e');
      return false;
    }
  }

  // ============================================================================
  // ✨ VERSION PRO: RECONNAISSANCE ULTRA-RAPIDE (+ FALLBACK LENT)
  // ============================================================================

  Future<FaceIdentificationResult> recognizeProWithEncoding(
    File imageFile,
  ) async {
    try {
      debugPrint('🚀 [PRO] Reconnaissance ultra-rapide');

      // 1️⃣ Compression de l'image avant upload
      final compressedFile = await _compressImageFile(imageFile);

      // 2️⃣ Upload temporaire
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFilename = 'temp_faces/recognize_${timestamp}.jpg';
      final tempRef = _storage.ref(tempFilename);

      await tempRef.putFile(compressedFile);
      final imageUrl = await tempRef.getDownloadURL();

      // 3️⃣ Appel backend PRO: comparaison rapide avec encodages Firestore
      final serverUrl = _useLocalServer
          ? _localServerUrl.replaceAll('/recognize', '/recognize_pro')
          : 'https://smartnursery-face-recognition-1023759846976.europe-west1.run.app/recognize_pro';

      debugPrint('📤 Envoi reconnaissance PRO');

      final response = await http
          .post(
            Uri.parse(serverUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'imageUrl': imageUrl}),
          )
          .timeout(const Duration(seconds: 30));

      // Suppression du fichier temporaire
      await tempRef.delete().catchError((_) => null);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final recognized = (data['recognized'] as bool?) ?? false;
        final personId = (data['personId'] as String?) ?? '';
        final personName = (data['personName'] as String?) ?? 'Utilisateur';
        final role = (data['role'] as String?) ?? '';
        final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;
        final distance = (data['distance'] as num?)?.toDouble() ?? 0.0;
        final message = (data['message'] as String?) ?? '';
        final usersWithEncoding = (data['usersWithEncoding'] as int?) ?? 0;

        debugPrint('📥 Réponse backend: $data');
        debugPrint('👥 Utilisateurs avec encodage: $usersWithEncoding');
        debugPrint('📏 Distance: $distance');

        if (recognized && personId.isNotEmpty) {
          debugPrint(
            '✅ Visage reconnu (RAPIDE): $personName (${(confidence * 100).toStringAsFixed(1)}%)',
          );
          return FaceIdentificationResult(
            identified: true,
            userId: personId,
            userDisplayName: personName,
            userRole: role,
            confidence: confidence,
            message: message,
          );
        }

        // ⚠️ RECONNAISSANCE RAPIDE A ÉCHOUÉ → FALLBACK À LA LENTE
        debugPrint(
          '⚠️ [PRO] Reconnaissance rapide échouée, tentative lente...',
        );
        final slowResult = await identifyUserFromAllFaces(imageFile).timeout(
          const Duration(minutes: 1),
          onTimeout: () => FaceIdentificationResult(
            identified: false,
            userId: '',
            userDisplayName: '',
            userRole: '',
            confidence: 0.0,
            message: 'Timeout reconnaissance lente (> 60s)',
          ),
        );

        if (slowResult.identified) {
          debugPrint(
            '✅ Visage reconnu (LENT/FALLBACK): ${slowResult.userDisplayName}',
          );
          return slowResult;
        }
      }

      debugPrint('❌ Visage non reconnu - Response: ${response.body}');
      return FaceIdentificationResult(
        identified: false,
        userId: '',
        userDisplayName: '',
        userRole: '',
        confidence: 0.0,
        message: 'Visage non reconnu - Accès refusé',
      );
    } catch (e) {
      debugPrint('❌ Erreur reconnaissance PRO: $e');
      return FaceIdentificationResult(
        identified: false,
        userId: '',
        userDisplayName: '',
        userRole: '',
        confidence: 0.0,
        message: 'Erreur: $e',
      );
    }
  }
}
