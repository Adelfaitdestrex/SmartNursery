// One-off migration script
// Usage:
//  node migrate_children_to_class.js --targetId=NEW_CLASS_ID --from=oldId1,oldId2 --dry
// Requires: functions/temp_service_account.json or proper environment credentials

const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");

// Initialize admin with service account if available
const saPath = path.join(__dirname, "temp_service_account.json");
console.log(`Looking for service account at: ${saPath}`);

if (fs.existsSync(saPath)) {
  console.log("✓ Service account found, initializing...");
  try {
    admin.initializeApp({
      credential: admin.credential.cert(require(saPath)),
    });
    console.log("✓ Firebase initialized with service account");
  } catch (e) {
    console.error("✗ Failed to initialize with service account:", e.message);
    process.exit(1);
  }
} else {
  console.log("⚠ No service account file found, using default credentials...");
  try {
    admin.initializeApp();
    console.log("✓ Firebase initialized with default credentials");
  } catch (e) {
    console.error("✗ Failed to initialize Firebase:", e.message);
    process.exit(1);
  }
}

const db = admin.firestore();

function parseArgs() {
  const args = process.argv.slice(2);
  const out = {};
  args.forEach((arg) => {
    const [k, v] = arg.split("=");
    const key = k.replace(/^--/, "");
    out[key] = v === undefined ? true : v;
  });
  return out;
}

(async () => {
  try {
    const args = parseArgs();
    const targetId = args.targetId || args.targetid;
    const from = args.from || "";
    const dry = args.dry || false;

    if (!targetId) {
      console.error("Missing --targetId=NEW_CLASS_ID");
      process.exit(1);
    }

    const fromList = from
      .split(",")
      .map((s) => s.trim())
      .filter(Boolean);
    if (fromList.length === 0) {
      console.error("Missing --from=oldId1,oldId2 (one or more old class ids)");
      process.exit(1);
    }

    const classRef = db.collection("classes").doc(targetId);
    const classSnap = await classRef.get();
    if (!classSnap.exists) {
      console.error(
        `Target class ${targetId} not found in "classes" collection.`,
      );
      process.exit(1);
    }

    console.log(
      `Target class found: ${targetId} (${classSnap.data().name || "no-name"})`,
    );

    let totalUpdated = 0;

    for (const oldId of fromList) {
      console.log(
        `\nProcessing children with classId=="${oldId}" OR classID=="${oldId}"`,
      );

      const q1 = db.collection("enfants").where("classId", "==", oldId).get();
      const q2 = db.collection("enfants").where("classID", "==", oldId).get();

      const [snap1, snap2] = await Promise.all([q1, q2]);

      const docs = new Map();
      snap1.docs.forEach((d) => docs.set(d.id, d));
      snap2.docs.forEach((d) => docs.set(d.id, d));

      console.log(`Found ${docs.size} unique enfants to migrate from ${oldId}`);

      if (docs.size === 0) continue;

      if (dry) {
        docs.forEach((d, id) =>
          console.log(`DRY-RUN: would update child ${id}`),
        );
        totalUpdated += docs.size;
        continue;
      }

      const batch = db.batch();
      let updatedCount = 0;

      for (const [id, doc] of docs.entries()) {
        const childRef = db.collection("enfants").doc(id);
        batch.update(childRef, { classId: targetId, classID: targetId });
        updatedCount++;
      }

      console.log(`Committing batch update for ${updatedCount} children...`);
      await batch.commit();
      console.log(`✓ Batch committed successfully`);

      // Update class document to include migrated children
      const childIds = Array.from(docs.keys());
      console.log(`Adding ${childIds.length} children to class childrenIds...`);

      await classRef.set(
        {
          childrenIds: admin.firestore.FieldValue.arrayUnion(...childIds),
          currentSize: admin.firestore.FieldValue.increment(childIds.length),
        },
        { merge: true },
      );
      console.log(`✓ Class document updated`);

      console.log(
        `Migrated ${updatedCount} enfants from ${oldId} → ${targetId}`,
      );
      totalUpdated += updatedCount;
    }

    console.log(
      `\nMigration complete. Total enfants migrated: ${totalUpdated}`,
    );
    process.exit(0);
  } catch (e) {
    console.error("\n✗ Migration error:", e.message);
    console.error("Stack:", e.stack);
    process.exit(2);
  }
})();
