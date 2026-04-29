/**
 * Cloud Function pour la reconnaissance faciale
 * Intégration avec Firebase Storage et Firestore
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require("cors")({ origin: true });

if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * Récupère les enfants avec leurs images de visage
 */
async function getRegisteredChildren() {
  try {
    const childrenSnap = await admin.firestore().collection("children").get();

    const children = [];
    for (const doc of childrenSnap.docs) {
      const childData = doc.data();
      if (childData.name) {
        children.push({
          id: doc.id,
          name: childData.name,
          hasRegisteredFaces: !!childData.hasFaceData,
        });
      }
    }

    return children;
  } catch (error) {
    console.error("Erreur récupération enfants:", error);
    return [];
  }
}

/**
 * Vérifie si une image contient un visage
 * Pour le développement, on retourne un mock
 * En production, intégrer avec une API de reconnaissance faciale
 */
function validateFaceInImage(imageUrl) {
  // TODO: Intégrer avec Google Cloud Vision API ou similaire
  // Pour maintenant, on considère que l'image est valide si elle existe

  return {
    hasFace: !!imageUrl,
    confidence: 0.85,
  };
}

/**
 * Compare deux images de visages
 * Retourne un score de similarité entre 0 et 1
 */
function compareFaces(unknownImageUrl, registeredImageUrl) {
  // TODO: Intégrer avec une API de reconnaissance faciale (face_recognition.py, TensorFlow, etc.)
  // Pour maintenant, on retourne un mock
  // Score minimum pour une correspondance: 0.6

  // Simulation: si les deux images existent, score aléatoire
  if (unknownImageUrl && registeredImageUrl) {
    return Math.random() * 0.4 + 0.6; // Entre 0.6 et 1.0
  }
  return 0;
}

/**
 * Cloud Function HTTP: Reconnaissance faciale
 * POST /recognizeFace
 * Body: { imageUrl: string }
 * Response: { recognized: boolean, childId?: string, childName?: string, message: string }
 */
exports.recognizeFace = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      if (req.method !== "POST") {
        return res.status(405).json({
          error: "Method not allowed. Use POST.",
        });
      }

      const { imageUrl } = req.body;

      if (!imageUrl) {
        return res.status(400).json({
          recognized: false,
          message: "imageUrl est requise",
        });
      }

      // Valider que l'image contient un visage
      const faceValidation = validateFaceInImage(imageUrl);
      if (!faceValidation.hasFace) {
        return res.status(200).json({
          recognized: false,
          message: "Aucun visage détecté dans l'image",
        });
      }

      // Récupérer les enfants enregistrés
      const children = await getRegisteredChildren();

      if (
        children.length === 0 ||
        children.every((c) => !c.hasRegisteredFaces)
      ) {
        return res.status(200).json({
          recognized: false,
          message: "Aucun visage enregistré dans la base de données",
        });
      }

      // Simuler la comparaison de visages
      // En production, on comparera réellement les encodages de visage
      let bestMatch = null;
      let bestScore = 0;

      for (const child of children) {
        if (!child.hasRegisteredFaces) continue;

        // TODO: Récupérer les URLs des visages enregistrés depuis Storage
        // const registeredImages = await getChildFaceImages(child.id);
        // Comparar cada imagen registrada

        // Pour la démo: simuler une correspondance aléatoire
        const score = Math.random();
        if (score > bestScore && score > 0.6) {
          bestScore = score;
          bestMatch = child;
        }
      }

      if (bestMatch && bestScore > 0.6) {
        return res.status(200).json({
          recognized: true,
          childId: bestMatch.id,
          childName: bestMatch.name,
          confidence: bestScore,
          message: `Enfant reconnu: ${bestMatch.name}`,
        });
      }

      return res.status(200).json({
        recognized: false,
        message: "Visage non reconnu - Aucune correspondance trouvée",
      });
    } catch (error) {
      console.error("Erreur reconnaissance faciale:", error);

      return res.status(500).json({
        recognized: false,
        message: `Erreur serveur: ${error.message}`,
      });
    }
  });
});

/**
 * Cloud Function Callable: Enregistrer un visage pour un enfant
 * Data: { childId: string, imageUrl: string }
 * Response: { success: boolean, message: string }
 */
exports.registerChildFace = functions.https.onCall(async (data, context) => {
  // Vérifier l'authentification
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentification requise",
    );
  }

  try {
    const { childId, imageUrl } = data;

    if (!childId || !imageUrl) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "childId et imageUrl sont requis",
      );
    }

    // Mettre à jour Firestore pour marquer que l'enfant a des données faciales
    await admin.firestore().collection("children").doc(childId).update({
      hasFaceData: true,
      lastFaceRegisteredAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      message: "Visage enregistré avec succès",
    };
  } catch (error) {
    console.error("Erreur enregistrement visage:", error);

    throw new functions.https.HttpsError(
      "internal",
      error.message || "Erreur lors de l'enregistrement du visage",
    );
  }
});

module.exports = { recognizeFace, registerChildFace };
