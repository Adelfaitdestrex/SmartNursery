const admin = require("firebase-admin");
const serviceAccount = require("./temp_service_account.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function listSubcollections(docRef, level = 1) {
  const subcols = await docRef.listCollections();
  const indent = "  ".repeat(level);
  for (let subcol of subcols) {
    console.log(`${indent}► Sous-collection: ${subcol.id}`);
    const snapshot = await subcol.limit(1).get();
    if (!snapshot.empty) {
      console.log(`${indent}  Champs:`, snapshot.docs[0].data());
      await listSubcollections(snapshot.docs[0].ref, level + 1);
    } else {
      console.log(`${indent}  (Vide)`);
    }
  }
}

async function listAllCollections() {
  try {
    const collections = await db.listCollections();
    console.log("\n=== ARBORESCENCE FIRESTORE COMPLETE ===\n");
    for (let collection of collections) {
      console.log("📁 Collection Mondiale: " + collection.id);
      
      const snapshot = await collection.limit(5).get(); 
      let foundSubcol = false;
      
      if (!snapshot.empty) {
        console.log("  📄 Structure du document:", snapshot.docs[0].data());
        
        for (let doc of snapshot.docs) {
          const subcols = await doc.ref.listCollections();
          if (subcols.length > 0 && !foundSubcol) {
            console.log("\n  [Sous-collections détectées]:");
            await listSubcollections(doc.ref, 2);
            foundSubcol = true; 
          }
        }
      } else {
        console.log("  (Collection vide)");
      }
      console.log("-----------------------------------------");
    }
  } catch(e) {
    console.error(e);
  } finally {
    process.exit(0);
  }
}

listAllCollections();
