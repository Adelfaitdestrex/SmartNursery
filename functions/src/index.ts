/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {setGlobalOptions} from "firebase-functions";
import {onRequest} from "firebase-functions/https";
import {onCall} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as https from "https";
import axios from "axios";
import * as admin from "firebase-admin";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// ✅ YOUTUBE DATA API INTEGRATION
const YOUTUBE_API_KEY = process.env.YOUTUBE_API_KEY || "";

export const youtubeSearch = onRequest(
  {cors: true, memory: "256MB"},
  async (request, response) => {
    const {query} = request.query;

    if (!query || typeof query !== "string") {
      response.status(400).json({error: "Missing query parameter"});
      return;
    }

    if (!YOUTUBE_API_KEY) {
      logger.error("YouTube API Key not configured");
      response.status(500).json({
        error: "YouTube API not configured. Set YOUTUBE_API_KEY env var.",
      });
      return;
    }

    try {
      logger.info(`Searching YouTube for: ${query}`);

      // Appeler YouTube Data API v3
      const youtubeUrl = "https://www.googleapis.com/youtube/v3/search";
      const params = {
        q: `${query} music audio`,
        part: "snippet",
        type: "video",
        maxResults: 10,
        key: YOUTUBE_API_KEY,
        videoCategoryId: "10", // Music category
      };

      const youtubeResponse = await axios.get(youtubeUrl, {params});

      const tracks = youtubeResponse.data.items.map((item: any) => ({
        id: item.id.videoId,
        name: item.snippet.title,
        artist: item.snippet.channelTitle,
        imageUrl: item.snippet.thumbnails.medium?.url || null,
        previewUrl: `https://www.youtube.com/watch?v=${item.id.videoId}`,
        spotifyUrl: `https://www.youtube.com/watch?v=${item.id.videoId}`,
      }));

      logger.info(`Found ${tracks.length} tracks`);
      response.json({tracks});
    } catch (error) {
      logger.error("YouTube API error", error);
      response.status(500).json({
        error: error instanceof Error ? error.message : "Unknown error",
      });
    }
  }
);

// ✅ PUSH NOTIFICATION FUNCTION
export const sendPushNotification = onCall(
  {memory: "256MB"},
  async (request) => {
    // Initialiser Firebase Admin si pas déjà fait
    if (!admin.apps.length) {
      admin.initializeApp();
    }

    const {userId, title, message, data} = request.data;

    if (!userId || !title || !message) {
      logger.error("Missing required fields: userId, title, message");
      throw new Error("Missing required fields");
    }

    try {
      // Récupérer le token FCM de l'utilisateur depuis Firestore
      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(userId)
        .get();

      if (!userDoc.exists) {
        logger.warn(`User ${userId} not found`);
        return {success: false, message: "User not found"};
      }

      const fcmToken = userDoc.data()?.fcmToken;

      if (!fcmToken) {
        logger.warn(`No FCM token for user ${userId}`);
        return {success: false, message: "No FCM token available"};
      }

      // Envoyer la notification push via Firebase Cloud Messaging
      const response = await admin.messaging().send({
        notification: {
          title: title,
          body: message,
        },
        data: data || {},
        token: fcmToken,
      });

      logger.info(`Push notification sent to ${userId}: ${response}`);
      return {success: true, messageId: response};
    } catch (error) {
      logger.error(`Error sending push notification: ${error}`);
      // Ne pas lever l'erreur, juste logger
      // Car si la notification push échoue, la notification Firestore est déjà créée
      return {success: false, error: error instanceof Error ? error.message : "Unknown error"};
    }
  }
);


