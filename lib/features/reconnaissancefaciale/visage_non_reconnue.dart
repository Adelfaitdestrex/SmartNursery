import 'package:flutter/material.dart';
import 'recherche_en_cours.dart';

class FaceNotRecognizedScreen extends StatelessWidget {
  final String message;

  const FaceNotRecognizedScreen({
    super.key,
    this.message = 'Aucune correspondance trouvée dans la base de données.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // HEADER
      appBar: AppBar(
        title: Text("Reconnaissance faciale"),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      // BODY
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ❌ CARD PRINCIPALE
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  // ❌ ICON
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.pink[100],
                    child: Icon(Icons.close, color: Colors.red, size: 30),
                  ),

                  SizedBox(height: 15),

                  // TITLE
                  Text(
                    "Visage non reconnu",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 10),

                  // DESCRIPTION
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),

                  SizedBox(height: 10),

                  // ICON REFRESH
                  Icon(Icons.refresh, color: Colors.grey),
                ],
              ),
            ),

            SizedBox(height: 20),

            //  CONSEILS
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.grey),
                      SizedBox(width: 10),
                      Text(
                        "Conseils pour réussir",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  Text("• Assurez-vous d’être dans un endroit bien éclairé"),
                  Text("• Retirez vos lunettes de soleil ou chapeau"),
                ],
              ),
            ),

            SizedBox(height: 30),

            // BOUTON RÉESSAYER
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const IdentificationScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text("Réessayer"),
              ),
            ),

            Spacer(),

            // BAS DE PAGE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close),
                  label: Text("Annuler"),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.refresh),
                  label: Text("Annuler"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
