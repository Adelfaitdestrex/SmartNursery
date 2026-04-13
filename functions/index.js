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
