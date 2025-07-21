import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

List<CameraDescription> cameras = [];

class KtpCameraScreen extends StatefulWidget {
  const KtpCameraScreen({super.key});

  @override
  State<KtpCameraScreen> createState() => _KtpCameraScreenState();
}

class _KtpCameraScreenState extends State<KtpCameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Pastikan daftar kamera sudah diinisialisasi
    if (cameras.isEmpty) {
      cameras = await availableCameras();
    }

    if (cameras.isNotEmpty) {
      // Cari kamera belakang (rear camera) jika ada
      CameraDescription? rearCamera;
      for (var camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.back) {
          rearCamera = camera;
          break;
        }
      }

      final camera = rearCamera ?? cameras.first;

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller
          ?.initialize()
          .then((_) {
            if (!mounted) {
              return;
            }
            setState(() {});
          })
          .catchError((e) {
            if (e is CameraException) {
              switch (e.code) {
                case 'CameraAccessDenied':
                  // Handle access errors here.
                  print('Access to the camera was denied!');
                  break;
                default:
                  print('Error initializing camera: ${e.description}');
                  break;
              }
            }
          });
    } else {
      // Tangani kasus di mana tidak ada kamera yang tersedia
      print('No cameras found.');
      _initializeControllerFuture = Future.error('No cameras found');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada kamera yang tersedia pada perangkat ini.'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Kamera belum diinisialisasi.')),
      );
      return;
    }

    try {
      final XFile image = await _controller!.takePicture();
      if (mounted) {
        Navigator.pop(context, File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil gambar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambil Foto KTP'),
        backgroundColor: Color(0xFFE30031),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_controller != null && _controller!.value.isInitialized) {
              final size = MediaQuery.of(context).size;
              final double scale =
                  size.aspectRatio * _controller!.value.aspectRatio;

              return Stack(
                children: [
                  Positioned.fill(
                    child: Transform.scale(
                      scale: scale < 1 ? 1 / scale : scale,
                      child: Center(child: CameraPreview(_controller!)),
                    ),
                  ),
                  // Overlay untuk border KTP
                  Center(
                    child: Container(
                      width: size.width * 0.8, // Lebar 80% dari layar
                      height:
                          size.width *
                          0.8 *
                          (2 / 3), // Rasio standar KTP (sekitar 3:2)
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 3.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Sesuaikan KTP Anda di dalam bingkai ini',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 5.0,
                                  color: Colors.black.withOpacity(0.7),
                                  offset: Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: FloatingActionButton(
                        onPressed: _takePicture,
                        child: const Icon(Icons.camera_alt),
                        backgroundColor: Color(0xFFE30031),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return const Center(
                child: Text('Tidak ada kamera yang tersedia.'),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
