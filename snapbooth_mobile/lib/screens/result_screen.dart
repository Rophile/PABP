import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snapbooth_mobile/providers/photobooth_provider.dart';
import 'package:snapbooth_mobile/services/image_service.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Uint8List? _generatedImage;
  bool _isGenerating = true;

  @override
  void initState() {
    super.initState();
    _generatePhotostrip();
  }

  Future<void> _generatePhotostrip() async {
    final provider = Provider.of<PhotoboothProvider>(context, listen: false);
    if (provider.selectedTemplate == null || provider.capturedPhotos.isEmpty) return;

    try {
      final image = await ImageService.generatePhotostrip(
        photos: provider.capturedPhotos,
        template: provider.selectedTemplate!,
      );
      if (mounted) {
        setState(() {
          _generatedImage = image;
          _isGenerating = false;
        });
      }
    } catch (e) {
      debugPrint('Error generating photostrip: $e');
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate photostrip')),
        );
      }
    }
  }

  Future<void> _saveToGallery() async {
    if (_generatedImage == null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/snapbooth_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(_generatedImage!);
      
      final success = await GallerySaver.saveImage(file.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success == true ? 'Saved to gallery!' : 'Failed to save')),
        );
      }
    } catch (e) {
      debugPrint('Error saving image: $e');
    }
  }

  Future<void> _shareImage() async {
    if (_generatedImage == null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/snapbooth_share.png');
      await file.writeAsBytes(_generatedImage!);
      
      await Share.shareXFiles([XFile(file.path)], text: 'Check out my SnapBooth photostrip!');
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Photostrip'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Provider.of<PhotoboothProvider>(context, listen: false).resetSession();
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
      body: Center(
        child: _isGenerating
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Generating your photostrip...'),
                ],
              )
            : _generatedImage == null
                ? const Text('Something went wrong')
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Image.memory(_generatedImage!),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ActionButton(
                              icon: Icons.download,
                              label: 'Download',
                              onTap: _saveToGallery,
                            ),
                            _ActionButton(
                              icon: Icons.share,
                              label: 'Share',
                              onTap: _shareImage,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            Provider.of<PhotoboothProvider>(context, listen: false).resetSession();
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('New Session'),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: onTap,
          icon: Icon(icon),
          iconSize: 30,
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF741E31),
            padding: const EdgeInsets.all(15),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
