import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayerWidget extends StatefulWidget {
  final String musicUrl;
  final String musicTitle;
  final String musicArtist;
  final int durationSeconds;

  const MusicPlayerWidget({
    super.key,
    required this.musicUrl,
    required this.musicTitle,
    required this.musicArtist,
    this.durationSeconds = 30,
  });

  @override
  State<MusicPlayerWidget> createState() => _MusicPlayerWidgetState();
}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
  }

  Future<void> _setupAudioPlayer() async {
    try {
      // Extraire l'ID vidéo YouTube de l'URL
      final youtubeUrl = widget.musicUrl;

      // Convertir l'URL YouTube pour accéder à l'audio via yt-dlp ou direct stream
      // Pour une solution simple, on utilise l'URL directe YouTube
      await _audioPlayer.setUrl(youtubeUrl);

      // Écouter les changements de durée
      _audioPlayer.durationStream.listen((duration) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      });

      // Écouter les changements de position
      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _position = position;

          // Arrêter après 30 secondes
          if (position.inSeconds >= widget.durationSeconds) {
            _audioPlayer.stop();
            setState(() {
              _isPlaying = false;
            });
          }
        });
      });

      // Écouter l'état de lecture
      _audioPlayer.playingStream.listen((playing) {
        setState(() {
          _isPlaying = playing;
        });
      });
    } catch (e) {
      debugPrint('❌ Erreur initialisation audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: impossible de charger l\'audio ($e)'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint('❌ Erreur lecture/pause: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre et artiste
          Row(
            children: [
              Icon(Icons.music_note, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.musicTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.musicArtist,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Barre de progression
          Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4.0,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                ),
                child: Slider(
                  value: _position.inSeconds.toDouble(),
                  max: (_duration.inSeconds > 0 ? _duration.inSeconds : 1)
                      .toDouble(),
                  activeColor: Colors.blue.shade700,
                  inactiveColor: Colors.blue.shade200,
                  onChanged: (value) async {
                    await _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    Text(
                      '${widget.durationSeconds}s',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Boutons de contrôle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 40,
                  color: Colors.blue.shade700,
                ),
                onPressed: _togglePlayPause,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
