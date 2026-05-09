import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:snapbooth_mobile/providers/photobooth_provider.dart';
import 'package:snapbooth_mobile/screens/result_screen.dart';

class PhotoboothScreen extends StatefulWidget {
  const PhotoboothScreen({super.key});

  @override
  State<PhotoboothScreen> createState() => _PhotoboothScreenState();
}

class _PhotoboothScreenState extends State<PhotoboothScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final status = await Permission.camera.request();
      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera permission is required')),
          );
        }
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No cameras found on this device')),
          );
        }
        return;
      }

      // Default to front camera if available
      final frontCameraIndex = _cameras.indexWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
      );
      _selectedCameraIndex = frontCameraIndex != -1 ? frontCameraIndex : 0;

      await _setupController();
    } catch (e) {
      debugPrint('Camera Initialization Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize camera: $e')),
        );
      }
    }
  }

  Future<void> _setupController() async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void _switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    setState(() => _isInitialized = false);
    await _setupController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _handleCapture(PhotoboothProvider provider) async {
    if (_controller == null || !_isInitialized) return;

    await provider.startCaptureSession(_controller!);

    if (mounted && provider.capturedPhotos.length == provider.selectedTemplate?.slotCount) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResultScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<PhotoboothProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Main Camera Preview
                    Expanded(
                      flex: 4,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isInitialized)
                            ClipRect(
                              child: Transform.scale(
                                scale: 1.0,
                                child: Center(
                                  child: AspectRatio(
                                    aspectRatio: 1 / _controller!.value.aspectRatio,
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.rotationY(provider.isMirrorMode ? math.pi : 0),
                                      child: CameraPreview(_controller!),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            const Center(child: CircularProgressIndicator()),
                          
                          // Countdown Overlay
                          if (provider.countdownValue > 0)
                            Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                              ),
                              child: Text(
                                '${provider.countdownValue}',
                                style: const TextStyle(
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Side Panel (Slot Previews)
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: const Color(0xFF1A1A1A),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'Slots',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: provider.selectedTemplate?.slotCount ?? 0,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                itemBuilder: (context, index) {
                                  final photo = index < provider.capturedPhotos.length
                                      ? provider.capturedPhotos[index]
                                      : null;
                                  final isCurrent = index == provider.currentSlotIndex && provider.isCapturing;
                                  
                                  return Container(
                                    height: 100,
                                    margin: const EdgeInsets.only(bottom: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isCurrent ? const Color(0xFFF6BAD6) : Colors.transparent,
                                        width: 3,
                                      ),
                                    ),
                                    child: photo != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.file(
                                              File(photo.path),
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Center(
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom Controls
              Container(
                height: 150,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF420D19),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Timer Setting
                    _ControlItem(
                      icon: Icons.timer,
                      label: '${provider.timerDuration}s',
                      onTap: provider.isCapturing 
                          ? null 
                          : () => _showTimerPicker(context, provider),
                    ),
                    
                    // Capture Button
                    GestureDetector(
                      onTap: provider.isCapturing ? null : () => _handleCapture(provider),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: provider.isCapturing ? Colors.grey : Colors.white,
                          child: Icon(
                            provider.isCapturing ? Icons.hourglass_empty : Icons.camera,
                            size: 40,
                            color: const Color(0xFF420D19),
                          ),
                        ),
                      ),
                    ),
                    
                    // Mirror Mode
                    _ControlItem(
                      icon: provider.isMirrorMode ? Icons.flip_camera_ios : Icons.camera_front,
                      label: 'Mirror',
                      onTap: provider.isCapturing ? null : provider.toggleMirrorMode,
                    ),
                    
                    // Switch Camera
                    _ControlItem(
                      icon: Icons.switch_camera,
                      label: 'Switch',
                      onTap: provider.isCapturing ? null : _switchCamera,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTimerPicker(BuildContext context, PhotoboothProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF1D3DF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Timer Delay',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [3, 5, 10].map((d) {
                  return ChoiceChip(
                    label: Text('${d}s'),
                    selected: provider.timerDuration == d,
                    onSelected: (selected) {
                      if (selected) {
                        provider.setTimerDuration(d);
                        Navigator.pop(context);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _ControlItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ControlItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: onTap == null ? Colors.grey : Colors.white, size: 30),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: onTap == null ? Colors.grey : Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
