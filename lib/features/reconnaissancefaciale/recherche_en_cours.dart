import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../services/face_recognition_service.dart';
import 'reconnaissance_faciale.dart';
import 'visage_non_reconnue.dart';

class IdentificationScreen extends StatefulWidget {
  const IdentificationScreen({super.key});

  @override
  State<IdentificationScreen> createState() => _IdentificationScreenState();
}

class _IdentificationScreenState extends State<IdentificationScreen> {
  late FaceRecognitionService _faceService;
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String? _cameraError;

  bool isFaceValid = false;
  bool _isAnalyzing = false;
  bool _cameraHasError = false;
  String _statusMessage = 'La capture se fait automatiquement';
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _faceService = FaceRecognitionService();
    initCamera();
  }

  // 🎥 Initialisation caméra avec écoute d'erreurs matérielles
  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() => _cameraError = 'Aucune caméra disponible');
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      // 🚨 Écoute les erreurs matérielles (code 4/5 = crash caméra Android)
      _controller!.addListener(() {
        if (_controller != null &&
            _controller!.value.hasError &&
            !_cameraHasError &&
            mounted) {
          setState(() => _cameraHasError = true);
          _reinitCamera();
        }
      });

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
      if (!mounted) return;
      setState(() => _cameraHasError = false);

      simulateAnalysis();
    } catch (e) {
      if (!mounted) return;
      setState(() => _cameraError = 'Impossible d\'initialiser la caméra');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // 🔄 Réinitialise la caméra après erreur matérielle
  Future<void> _reinitCamera() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    try {
      await _controller?.dispose();
    } catch (_) {}
    _controller = null;
    _initializeControllerFuture = null;
    if (mounted) {
      setState(() {
        _cameraHasError = false;
        _isAnalyzing = false;
      });
      await initCamera();
    }
  }

  // 🎯 Capture automatique après 3 secondes
  void simulateAnalysis() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted && !_isAnalyzing) {
      await sendToBackend();
    }
  }

  Future<void> sendToBackend() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _controller!.value.hasError ||
        _cameraHasError ||
        _isAnalyzing) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _statusMessage = '📷 Capture de la photo...';
      _debugInfo = '';
    });

    try {
      final image = await _controller!.takePicture();
      final imageFile = File(image.path);

      if (mounted)
        setState(() => _statusMessage = '☁️ Envoi vers le serveur...');

      // 🔍 Appel reconnaissance faciale
      final result = await _faceService.recognizeFace(imageFile);

      if (!mounted) return;

      // Affiche le message exact reçu du serveur
      setState(() => _debugInfo = '→ ${result.message}');

      if (result.recognized) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => FaceRecognitionPage(
              childName: result.personName,
              confidenceLabel: result.message,
            ),
          ),
        );
        return;
      }

      // Petite pause pour lire le message debug avant de naviguer
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => FaceNotRecognizedScreen(message: result.message),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _debugInfo = '❌ Exception: $e');
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => FaceNotRecognizedScreen(message: 'Erreur: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _statusMessage = 'La capture se fait automatiquement';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Identification"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _cameraError != null
          ? Center(child: Text(_cameraError!))
          : _controller == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      // 🎥 Caméra — ratio natif, pas d'étirement
                      Positioned.fill(
                        child: ClipRect(
                          child: OverflowBox(
                            alignment: Alignment.center,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: 1,
                                height: _controller!.value.aspectRatio,
                                child: CameraPreview(_controller!),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 🎯 Cercle de cadrage
                      Center(
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isAnalyzing ? Colors.amber : Colors.white,
                              width: 3,
                            ),
                          ),
                          child: _isAnalyzing
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.amber,
                                    strokeWidth: 3,
                                  ),
                                )
                              : null,
                        ),
                      ),

                      // 📊 Infos + boutons en bas
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Fond semi-transparent
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _isAnalyzing
                                      ? "🔍 Reconnaissance en cours..."
                                      : "📸 Positionnez votre visage dans le cadre",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _isAnalyzing
                                      ? _statusMessage
                                      : _statusMessage,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                // ── Message debug serveur ────────────────
                                if (_debugInfo.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.amber),
                                    ),
                                    child: Text(
                                      _debugInfo,
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                LinearProgressIndicator(
                                  backgroundColor: Colors.white24,
                                  color: _isAnalyzing
                                      ? Colors.amber
                                      : Colors.greenAccent,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton.icon(
                                      onPressed: _isAnalyzing
                                          ? null
                                          : () => Navigator.pop(context),
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white70,
                                      ),
                                      label: const Text(
                                        "Annuler",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _isAnalyzing
                                          ? null
                                          : sendToBackend,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.greenAccent[700],
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        "Scanner maintenant",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }
}
