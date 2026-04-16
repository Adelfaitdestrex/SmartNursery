import 'package:flutter/material.dart';
import 'package:smartnursery/design_system/design_tokens.dart';

class FeedPostCard extends StatefulWidget {
  final String authorName;
  final String timeAgo;
  final List<String> imageUrls;
  final int likesCount;
  final int commentsCount;

  const FeedPostCard({
    super.key,
    this.authorName = "Mme Dupond",          // Plus de 'required', valeur par défaut
    this.timeAgo = "il y a 2h",             // Plus de 'required', valeur par défaut
    this.imageUrls = const [                // Plus de 'required', liste par défaut
      'assets/images/feedimageExemple.jpg',
      'assets/images/feedimageExemple2.jpg',
      'assets/images/feedimageExemple1.jpg',
    ],
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Si la liste d'images est vide, on évite un crash en ne dessinant rien
    if (widget.imageUrls.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.feedCard,
      ),
      child: Column(
        children: [
          // --- HEADER DU POST ---
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22.5,
                  backgroundColor: AppColors.headerTop,
                  child: Text('+', style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Utilisation de la variable authorName
                    Text(
                      widget.authorName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    // Utilisation de la variable timeAgo
                    Text(
                      widget.timeAgo,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.more_horiz, size: 25),
              ],
            ),
          ),

          // --- ZONE D'IMAGES ---
          AspectRatio(
            aspectRatio: 4 / 5,
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: widget.imageUrls.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    // Utilisation de Image.network car les liens viendront d'internet (Firebase)
                    return Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.cover,
                      // Petit bonus : affiche un indicateur de chargement le temps que l'image arrive
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    );
                  },
                ),

                // --- COMPTEUR D'IMAGES ---
                if (widget.imageUrls.length > 1)
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentImageIndex + 1}/${widget.imageUrls.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                // --- LES PETITS POINTS EN BAS ---
                if (widget.imageUrls.length > 1)
                  Positioned(
                    bottom: 15,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.imageUrls.length,
                            (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ... (Le reste du code pour les boutons reste identique)
        ],
      ),
    );
  }
}