// lib/screens/camera_screen.dart

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/reference_object.dart';
import 'measurement_screen.dart';

class CameraScreen extends StatefulWidget {
  final ReferenceObject selectedReference;
  
  const CameraScreen({
    super.key,
    required this.selectedReference,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _showGuide = true;
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }
  
  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  
  Future<void> _takePicture() async {
    if (!_isInitialized || _isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final XFile photo = await _controller!.takePicture();
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MeasurementScreen(
              imagePath: photo.path,
              selectedReference: widget.selectedReference,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Center(
            child: CameraPreview(_controller!),
          ),
          
          // Reference Guide Overlay
          if (_showGuide)
            Center(
              child: Container(
                width: 200,
                height: 126,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.yellow.withOpacity(0.7),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.credit_card,
                      color: Colors.yellow.withOpacity(0.7),
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Place ${widget.selectedReference.name} here',
                      style: TextStyle(
                        color: Colors.yellow.withOpacity(0.9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Top Bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.black54,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showGuide = !_showGuide;
                      });
                    },
                    icon: Icon(
                      _showGuide ? Icons.grid_on : Icons.grid_off,
                      color: Colors.white,
                    ),
                    label: Text(
                      _showGuide ? 'Hide Guide' : 'Show Guide',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePicture,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: _isProcessing
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}