import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';

class MusicTrack {
  final String id;
  final String title;
  final String artist;
  final String? imageUrl;
  final String previewUrl;
  final String spotifyUrl;

  MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    this.imageUrl,
    required this.previewUrl,
    required this.spotifyUrl,
  });

  factory MusicTrack.fromJson(Map<String, dynamic> json) {
    return MusicTrack(
      id: json['id'] ?? '',
      title: json['name'] ?? 'Sans titre',
      artist: (json['artists'] as List?)?.isNotEmpty == true
          ? (json['artists'][0]['name'] ?? 'Artiste inconnu')
          : 'Artiste inconnu',
      imageUrl: (json['album']?['images'] as List?)?.isNotEmpty == true
          ? json['album']['images'][0]['url']
          : null,
      previewUrl: json['preview_url'] ?? '',
      spotifyUrl: json['external_urls']?['spotify'] ?? '',
    );
  }
}

class MusicService {
  /// IMPORTANT: Utilise YouTube Data API via Cloud Functions
  /// Accès à toute la musique disponible sur YouTube
  /// https://developers.google.com/youtube/v3

  /// Recherche de la musique sur YouTube
  Future<List<MusicTrack>> searchMusic(String query) async {
    try {
      if (query.isEmpty) return [];

      debugPrint('🔍 Recherche de musique YouTube: $query');
      return await _searchYouTube(query);
    } catch (e) {
      debugPrint('❌ Erreur recherche musique: $e');
      return [];
    }
  }

  /// Recherche YouTube via Cloud Function Firebase
  Future<List<MusicTrack>> _searchYouTube(String query) async {
    try {
      debugPrint('🎵 Appel de la Cloud Function YouTube...');

      // Appeler la Cloud Function Firebase qui gère la recherche YouTube
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'youtubeSearch',
      );

      final response = await callable.call({'query': query});

      if (response.data != null && response.data['tracks'] != null) {
        final List<dynamic> tracksData =
            response.data['tracks'] as List<dynamic>;
        final tracks = tracksData
            .map(
              (track) => MusicTrack(
                id: track['id'] ?? '',
                title: track['name'] ?? 'Sans titre',
                artist: track['artist'] ?? 'Artiste inconnu',
                imageUrl: track['imageUrl'],
                previewUrl: track['previewUrl'] ?? '',
                spotifyUrl: track['spotifyUrl'] ?? '',
              ),
            )
            .toList();

        debugPrint('✅ ${tracks.length} musiques trouvées');
        return tracks;
      }

      return [];
    } catch (e) {
      debugPrint('❌ Erreur YouTube: $e');
      return [];
    }
  }

  /// Musiques populaires par défaut
  Future<List<MusicTrack>> getPopularTracks() async {
    return [
      MusicTrack(
        id: 'dQw4w9WgXcQ',
        title: 'Never Gonna Give You Up',
        artist: 'Rick Astley',
        imageUrl: null,
        previewUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        spotifyUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      ),
      MusicTrack(
        id: 'e-IWRmpefzE',
        title: 'Twinkle, Twinkle, Little Star',
        artist: 'Traditional',
        imageUrl: null,
        previewUrl: 'https://www.youtube.com/watch?v=e-IWRmpefzE',
        spotifyUrl: 'https://www.youtube.com/watch?v=e-IWRmpefzE',
      ),
      MusicTrack(
        id: 'K5tYzZgQAQQ',
        title: 'Old MacDonald Had a Farm',
        artist: 'Traditional',
        imageUrl: null,
        previewUrl: 'https://www.youtube.com/watch?v=K5tYzZgQAQQ',
        spotifyUrl: 'https://www.youtube.com/watch?v=K5tYzZgQAQQ',
      ),
    ];
  }
}
