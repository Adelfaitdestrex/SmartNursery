/**
 * SmartNursery Cloud Functions
 *
 * Envoie des emails OTP pour la réinitialisation de mot de passe
 *
 * Déploiement:
 * 1. cd functions
 * 2. npm install
 * 3. firebase functions:config:set gmail.user="your-email@gmail.com" gmail.password="app-password"
 * 4. firebase deploy --only functions
 *
 * Utilisation depuis Flutter:
 * EmailService.sendOtpEmail(email: "user@example.com", otp: "123456")
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const cors = require("cors")({ origin: true });
const axios = require("axios");

// Initialiser Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp();
}

// ============================================================================
// CONFIGURATION EMAIL
// ============================================================================

/**
 * Configuration Nodemailer avec Gmail
 *
 * Pour utiliser:
 * 1. Aller à https://myaccount.google.com/apppasswords
 * 2. Sélectionner Mail + Custom (Cloud Function)
 * 3. Générer un mot de passe
 * 4. Configurer les variables:
 *    firebase functions:config:set gmail.user="your-email@gmail.com" gmail.password="app-password"
 */
const getTransporter = () => {
  const config = functions.config();

  // Utiliser les variables d'environnement ou .env.local
  const emailUser = config.gmail?.user || process.env.GMAIL_USER;
  const emailPassword = config.gmail?.password || process.env.GMAIL_PASSWORD;

  if (!emailUser || !emailPassword) {
    console.error("❌ Email configuration missing! Set:");
    console.error(
      '   firebase functions:config:set gmail.user="email@gmail.com" gmail.password="app-password"',
    );
    throw new Error("Email configuration not set");
  }

  return nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: emailUser,
      pass: emailPassword,
    },
  });
};

// ============================================================================
// CLOUD FUNCTION: sendOTP
// ============================================================================

/**
 * Envoie un email OTP
 *
 * Requête POST:
 * {
 *   "email": "user@example.com",
 *   "otp": "123456",
 *   "subject": "Code de réinitialisation",
 *   "body": "Votre code..."
 * }
 *
 * Réponse:
 * {
 *   "success": true,
 *   "message": "Email envoyé avec succès"
 * }
 */
exports.sendOTP = functions.https.onRequest(async (req, res) => {
  // CORS
  cors(req, res, async () => {
    // Vérifier que c'est POST
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Method not allowed. Use POST." });
    }

    try {
      const { email, otp, subject, body } = req.body;

      // Validation
      if (!email || !otp) {
        return res.status(400).json({
          success: false,
          message: "Email et OTP sont requis",
        });
      }

      // Validation email basique
      if (!email.includes("@")) {
        return res.status(400).json({
          success: false,
          message: "Email invalide",
        });
      }

      // Valider OTP (6 chiffres)
      if (!/^\d{6}$/.test(otp)) {
        return res.status(400).json({
          success: false,
          message: "OTP doit être 6 chiffres",
        });
      }

      // Obtenir le transporter email
      const transporter = getTransporter();

      // Préparer l'email
      const mailOptions = {
        from: "SmartNursery <noreply@smartnursery.com>",
        to: email,
        subject: subject || "Code de réinitialisation SmartNursery",
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px; text-align: center; border-radius: 8px 8px 0 0;">
              <h1 style="color: white; margin: 0;">SmartNursery</h1>
            </div>
            
            <div style="background: #f5f5f5; padding: 40px; border-radius: 0 0 8px 8px;">
              <h2 style="color: #333; margin-top: 0;">Code de Réinitialisation</h2>
              
              <p style="color: #666; line-height: 1.6;">
                Vous avez demandé une réinitialisation de mot de passe pour votre compte SmartNursery.
              </p>
              
              <div style="background: white; padding: 30px; border-radius: 8px; text-align: center; margin: 30px 0; border: 2px solid #667eea;">
                <p style="margin: 0; color: #999; font-size: 14px;">Votre code OTP:</p>
                <h1 style="margin: 15px 0 0 0; color: #667eea; font-size: 36px; letter-spacing: 4px; font-weight: bold;">
                  ${otp}
                </h1>
              </div>
              
              <p style="color: #999; font-size: 12px; margin: 30px 0 0 0;">
                ⏰ Ce code expirera dans 15 minutes
              </p>
              
              <p style="color: #666; line-height: 1.6; margin-top: 20px;">
                Si vous n'avez pas demandé cette réinitialisation, veuillez ignorer cet email et votre compte restera sécurisé.
              </p>
              
              <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
              
              <p style="color: #999; font-size: 12px; margin: 0;">
                © 2026 SmartNursery. Tous droits réservés.<br>
                <a href="https://smartnursery.com" style="color: #667eea; text-decoration: none;">smartnursery.com</a>
              </p>
            </div>
          </div>
        `,
        text: `${subject || "Code de réinitialisation"}\n\nVotre code OTP: ${otp}\n\nCe code expirera dans 15 minutes.`,
      };

      // Envoyer l'email
      await transporter.sendMail(mailOptions);

      console.log(`✅ Email sent to ${email}`);

      return res.status(200).json({
        success: true,
        message: "Email envoyé avec succès",
        email: email,
      });
    } catch (error) {
      console.error("❌ Error sending email:", error);

      return res.status(500).json({
        success: false,
        message: "Erreur lors de l'envoi de l'email",
        error:
          process.env.NODE_ENV === "development"
            ? error.message
            : "Contact support",
      });
    }
  });
});

// ============================================================================
// CLOUD FUNCTION: Test (pour vérifier que la fonction fonctionne)
// ============================================================================

exports.testEmail = functions.https.onRequest(async (req, res) => {
  cors(req, res, async () => {
    try {
      const config = functions.config();
      const hasGmailConfig = !!(config.gmail?.user && config.gmail?.password);

      return res.status(200).json({
        status: "ok",
        message: "Cloud Function is running",
        emailConfigured: hasGmailConfig,
        instructions: !hasGmailConfig
          ? [
              "Email configuration is missing!",
              'Run: firebase functions:config:set gmail.user="your-email@gmail.com" gmail.password="app-password"',
              "Then redeploy: firebase deploy --only functions",
            ]
          : null,
      });
    } catch (error) {
      return res.status(500).json({
        status: "error",
        message: error.message,
      });
    }
  });
});

// ============================================================================
// CLOUD FUNCTION: requestPasswordResetCode
// ============================================================================
exports.requestPasswordResetCode = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") {
      return res
        .status(405)
        .json({ success: false, message: "Method not allowed. Use POST." });
    }

    try {
      const { email } = req.body;

      if (!email || !email.includes("@")) {
        return res
          .status(400)
          .json({ success: false, message: "Email invalide" });
      }

      // Check if user exists
      let userRecord;
      try {
        userRecord = await admin.auth().getUserByEmail(email);
      } catch (error) {
        if (error.code === "auth/user-not-found") {
          // Return success anyway for security purposes (to not expose registered emails)
          return res.status(200).json({
            success: true,
            message: "Si l'email existe, un code a été envoyé.",
          });
        }
        throw error;
      }

      // Generate a 6-digit OTP
      const otp = Math.floor(100000 + Math.random() * 900000).toString();

      // Expire in 15 minutes
      const expiresAt = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 15 * 60 * 1000),
      );

      // Save to Firestore
      await admin
        .firestore()
        .collection("password_reset_codes")
        .doc(email)
        .set({
          otp: otp,
          expiresAt: expiresAt,
        });

      const transporter = getTransporter();

      const mailOptions = {
        from: "SmartNursery <noreply@smartnursery.com>",
        to: email,
        subject: "Code de réinitialisation SmartNursery",
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px; text-align: center; border-radius: 8px 8px 0 0;">
              <h1 style="color: white; margin: 0;">SmartNursery</h1>
            </div>
            <div style="background: #f5f5f5; padding: 40px; border-radius: 0 0 8px 8px;">
              <h2 style="color: #333; margin-top: 0;">Code de Réinitialisation</h2>
              <p style="color: #666; line-height: 1.6;">
                Vous avez demandé une réinitialisation de mot de passe pour votre compte SmartNursery.
              </p>
              <div style="background: white; padding: 30px; border-radius: 8px; text-align: center; margin: 30px 0; border: 2px solid #667eea;">
                <p style="margin: 0; color: #999; font-size: 14px;">Votre code OTP:</p>
                <h1 style="margin: 15px 0 0 0; color: #667eea; font-size: 36px; letter-spacing: 4px; font-weight: bold;">
                  ${otp}
                </h1>
              </div>
              <p style="color: #999; font-size: 12px; margin: 30px 0 0 0;">
                ⏰ Ce code expirera dans 15 minutes
              </p>
              <p style="color: #666; line-height: 1.6; margin-top: 20px;">
                Si vous n'avez pas demandé cette réinitialisation, veuillez ignorer cet email.
              </p>
            </div>
          </div>
        `,
        text: `Votre code OTP: ${otp}\n\nCe code expirera dans 15 minutes.`,
      };

      await transporter.sendMail(mailOptions);

      return res.status(200).json({ success: true, message: "Code envoyé" });
    } catch (error) {
      console.error("Error in requestPasswordResetCode:", error);
      return res
        .status(500)
        .json({ success: false, message: "Erreur serveur" });
    }
  });
});

// ============================================================================
// CLOUD FUNCTION: recognizeFace (proxy vers service de reconnaissance)
// ============================================================================

/**
 * Proxy de reconnaissance faciale
 *
 * Configurez l'URL du service externe:
 * firebase functions:config:set facerec.url="https://votre-serveur/recognize"
 */
exports.recognizeFace = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") {
      return res
        .status(405)
        .json({ recognized: false, message: "Method not allowed. Use POST." });
    }

    const config = functions.config();
    const proxyUrl = config.facerec?.url || process.env.FACE_RECO_URL;

    if (!proxyUrl) {
      return res.status(500).json({
        recognized: false,
        message:
          "facerec.url manquant. Configurez: firebase functions:config:set facerec.url=...",
      });
    }

    const imageUrl = req.body?.imageUrl || req.body?.image_url;
    if (!imageUrl) {
      return res
        .status(400)
        .json({ recognized: false, message: "imageUrl manquante" });
    }

    try {
      const response = await axios.post(
        proxyUrl,
        { imageUrl: imageUrl, image_url: imageUrl },
        { headers: { "Content-Type": "application/json" }, timeout: 30000 },
      );

      return res.status(200).json(response.data);
    } catch (error) {
      const status = error.response?.status || 500;
      const message =
        error.response?.data?.message ||
        error.message ||
        "Erreur lors de la reconnaissance";

      return res.status(status).json({ recognized: false, message: message });
    }
  });
});

// ============================================================================
// CLOUD FUNCTION: resetPasswordWithCode
// ============================================================================
exports.resetPasswordWithCode = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") {
      return res
        .status(405)
        .json({ success: false, message: "Method not allowed. Use POST." });
    }

    try {
      const { email, otp, newPassword } = req.body;

      if (!email || !otp || !newPassword) {
        return res
          .status(400)
          .json({ success: false, message: "Données manquantes" });
      }

      if (newPassword.length < 6) {
        return res
          .status(400)
          .json({ success: false, message: "Mot de passe trop court" });
      }

      const docRef = admin
        .firestore()
        .collection("password_reset_codes")
        .doc(email);
      const doc = await docRef.get();

      if (!doc.exists) {
        return res
          .status(400)
          .json({ success: false, message: "Code invalide ou expiré" });
      }

      const data = doc.data();

      // Check expiration
      if (data.expiresAt.toDate() < new Date()) {
        await docRef.delete();
        return res
          .status(400)
          .json({ success: false, message: "Le code est expiré" });
      }

      // Check OTP
      if (data.otp !== otp) {
        return res
          .status(400)
          .json({ success: false, message: "Code invalide" });
      }

      // Reset the password
      const userRecord = await admin.auth().getUserByEmail(email);
      await admin.auth().updateUser(userRecord.uid, { password: newPassword });

      // Delete the consumed OTP code
      await docRef.delete();

      return res
        .status(200)
        .json({ success: true, message: "Mot de passe changé avec succès" });
    } catch (error) {
      console.error("Error in resetPasswordWithCode:", error);
      return res
        .status(500)
        .json({ success: false, message: "Erreur serveur" });
    }
  });
});

// ============================================================================
// CLOUD FUNCTION: createUser (Callable — sécurisé, Admin SDK)
// Crée un utilisateur sans basculer la session côté client.
// Seuls les admins/directeurs peuvent appeler cette fonction.
// ============================================================================

exports.createUser = functions.https.onCall(async (data, context) => {
  // ── 1. Vérification d'authentification ─────────────────────────────────────
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Vous devez être connecté pour effectuer cette opération.",
    );
  }

  // ── 2. Vérification du rôle admin/directeur ────────────────────────────────
  const callerUid = context.auth.uid;
  let callerDoc;
  try {
    callerDoc = await admin
      .firestore()
      .collection("users")
      .doc(callerUid)
      .get();
  } catch (e) {
    throw new functions.https.HttpsError(
      "internal",
      "Impossible de vérifier vos permissions.",
    );
  }

  if (!callerDoc.exists) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Votre compte n'existe pas dans la base de données.",
    );
  }

  const callerRole = callerDoc.data().role;
  if (!["admin", "director"].includes(callerRole)) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Seuls les administrateurs peuvent créer des utilisateurs.",
    );
  }

  // ── 3. Validation des données entrantes ────────────────────────────────────
  const {
    email,
    password,
    name,
    phone,
    role,
    isActive,
    profileImageUrl,
    nurseryId,
  } = data;

  if (!email || !email.includes("@")) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Adresse e-mail invalide.",
    );
  }
  if (!password || password.length < 6) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Le mot de passe doit contenir au moins 6 caractères.",
    );
  }
  if (!name || name.trim().length === 0) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Le nom est obligatoire.",
    );
  }
  const allowedRoles = ["parent", "educator", "admin", "director"];
  if (!role || !allowedRoles.includes(role)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      `Rôle invalide. Valeurs acceptées : ${allowedRoles.join(", ")}.`,
    );
  }

  // ── 4. Création du compte Firebase Auth (Admin SDK = pas de basculement) ───
  let userRecord;
  try {
    userRecord = await admin.auth().createUser({
      email: email.trim(),
      password: password,
      displayName: name.trim(),
    });
  } catch (error) {
    console.error("❌ Error creating auth user:", error);
    if (error.code === "auth/email-already-exists") {
      throw new functions.https.HttpsError(
        "already-exists",
        "Cet email est déjà utilisé par un autre utilisateur.",
      );
    }
    if (error.code === "auth/invalid-email") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "L'adresse e-mail est invalide.",
      );
    }
    if (error.code === "auth/weak-password") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Le mot de passe est trop faible.",
      );
    }
    throw new functions.https.HttpsError(
      "internal",
      error.message || "Erreur lors de la création du compte.",
    );
  }

  const uid = userRecord.uid;
  const nameParts = name.trim().split(" ");
  const firstName = nameParts[0] || "";
  const lastName = nameParts.slice(1).join(" ") || "";

  // ── 5. Écriture Firestore via Admin SDK (bypass des security rules) ─────────
  try {
    await admin
      .firestore()
      .collection("users")
      .doc(uid)
      .set({
        uid: uid,
        name: name.trim(),
        firstName: firstName,
        lastName: lastName,
        email: email.trim(),
        role: role,
        phone: phone || null,
        profileImageUrl: profileImageUrl || null,
        isActive: isActive !== undefined ? isActive : true,
        nurseryId: nurseryId || "1",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: callerUid,
      });
  } catch (error) {
    // Rollback : supprimer le compte Auth si Firestore échoue
    console.error("❌ Firestore write failed, rolling back auth:", error);
    try {
      await admin.auth().deleteUser(uid);
    } catch (e) {
      console.error("❌ Rollback failed:", e);
    }
    throw new functions.https.HttpsError(
      "internal",
      "Erreur lors de la sauvegarde des données utilisateur.",
    );
  }

  console.log(`✅ User created: ${email} (${role}) by admin ${callerUid}`);
  return { success: true, message: "Utilisateur créé avec succès.", uid: uid };
});
