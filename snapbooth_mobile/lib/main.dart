import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with safety for UI-only testing
  try {
    await Supabase.initialize(
      url: 'https://sdvgbmoahxkrwwwpzrsp.supabase.co',
      anonKey: 'sb_publishable_USLNuaE5N03UhIZ-JDIrCw_zrlvAnvV',
    );
  } catch (e) {
    debugPrint('Supabase initialization failed: $e. App will run in UI-only mode.');
  }

  // Initialize Cameras
  try {
    _cameras = await availableCameras();
  } catch (e) {
    debugPrint('Error initializing cameras: $e');
    _cameras = [];
  }

  runApp(const SnapBoothApp());
}

class SnapBoothApp extends StatelessWidget {
  const SnapBoothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapBooth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF741E31),
          primary: const Color(0xFF741E31),
          secondary: const Color(0xFFF6BAD6),
          surface: const Color(0xFFF1D3DF),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF420D19),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF741E31),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SnapBooth Mobile'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF1D3DF),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 100,
                color: Color(0xFF420D19),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Welcome to SnapBooth',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF420D19),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Capture your moments with style',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BoothScreen()),
                );
              },
              child: const Text('Enter Booth'),
            ),
          ],
        ),
      ),
    );
  }
}

class BoothScreen extends StatefulWidget {
  const BoothScreen({super.key});

  @override
  State<BoothScreen> createState() => _BoothScreenState();
}

class _BoothScreenState extends State<BoothScreen> {
  CameraController? _controller;
  int _selectedFrameIndex = 0;
  bool _isCapturing = false;

  final List<Map<String, dynamic>> _frames = [
    {'name': 'Classic', 'color': Colors.black.withAlpha(128)},
    {'name': 'Vintage', 'color': Colors.brown.withAlpha(102)},
    {'name': 'Pinkish', 'color': const Color(0xFFF6BAD6).withAlpha(102)},
    {'name': 'Bold', 'color': const Color(0xFF741E31).withAlpha(102)},
  ];

  @override
  void initState() {
    super.initState();
    if (_cameras.isNotEmpty) {
      _controller = CameraController(_cameras[0], ResolutionPreset.high);
      _controller!.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isCapturing = true);

    try {
      final XFile photo = await _controller!.takePicture();
      final String fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Upload to Supabase Storage (assuming bucket 'photos' exists and is public)
      final supabase = Supabase.instance.client;
      await supabase.storage.from('photos').upload(fileName, File(photo.path));
      
      final String publicUrl = supabase.storage.from('photos').getPublicUrl(fileName);

      if (!mounted) return;
      _showResultDialog(publicUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Ensure "photos" bucket exists in Supabase. $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  void _showResultDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF1D3DF),
        title: const Text('Photo Captured!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Scan to download your photo:'),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 200,
              child: QrImageView(
                data: url,
                version: QrVersions.auto,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF420D19),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF420D19),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SelectableText(
              url,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF741E31))),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booth Side'),
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: () {
              // Camera toggle logic could go here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Camera Preview
                Center(
                  child: AspectRatio(
                    aspectRatio: 1 / _controller!.value.aspectRatio,
                    child: CameraPreview(_controller!),
                  ),
                ),
                // Frame Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _frames[_selectedFrameIndex]['color'],
                        width: 40,
                      ),
                    ),
                  ),
                ),
                // Shutter Button
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _isCapturing
                        ? const CircularProgressIndicator()
                        : FloatingActionButton.large(
                            onPressed: _takePicture,
                            backgroundColor: const Color(0xFF741E31),
                            child: const Icon(Icons.camera, size: 40),
                          ),
                  ),
                ),
              ],
            ),
          ),
          // Frame Selector
          Container(
            height: 120,
            color: const Color(0xFFF1D3DF),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _frames.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedFrameIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFrameIndex = index;
                    });
                  },
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF6BAD6) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF741E31) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_frames,
                          color: isSelected ? const Color(0xFF741E31) : Colors.grey,
                        ),
                        Text(
                          _frames[index]['name'],
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF741E31) : Colors.grey,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
