import 'package:flutter/material.dart';

enum TemplateLayout { vertical }

class PhotostripTemplate {
  final String id;
  final String name;
  final TemplateLayout layout;
  final int slotCount;
  final Color backgroundColor;
  final Color accentColor;
  final String description;
  final String category; // 'Classic', 'Aesthetic', 'Retro', 'Minimal'
  final String? assetPath;

  PhotostripTemplate({
    required this.id,
    required this.name,
    required this.layout,
    required this.slotCount,
    this.backgroundColor = Colors.white,
    this.accentColor = const Color(0xFF741E31),
    this.description = '',
    this.category = 'Classic',
    this.assetPath,
  });

  static List<PhotostripTemplate> get availableTemplates => [
    PhotostripTemplate(
      id: 'theater-ticket-3',
      name: 'Theater Ticket',
      layout: TemplateLayout.vertical,
      slotCount: 3,
      backgroundColor: const Color(0xFFF5F5DC), // Creamy beige
      accentColor: const Color(0xFF8B0000), // Dark Red
      category: 'Special',
      description: 'A vintage theater ticket with stub and barcode.',
      assetPath: 'assets/templates/Frame_teater.png',
    ),
    // CLASSIC
    PhotostripTemplate(
      id: 'classic-3',
      name: 'Classic 3-Frame',
      layout: TemplateLayout.vertical,
      slotCount: 3,
      category: 'Classic',
      description: 'The standard vintage photobooth look.',
    ),
    PhotostripTemplate(
      id: 'classic-4',
      name: 'Classic 4-Frame',
      layout: TemplateLayout.vertical,
      slotCount: 4,
      category: 'Classic',
      description: 'More frames for more memories.',
    ),

    // AESTHETIC / SOFT
    PhotostripTemplate(
      id: 'aesthetic-pink-3',
      name: 'Soft Ribbon',
      layout: TemplateLayout.vertical,
      slotCount: 3,
      backgroundColor: const Color(0xFFFDEEF4),
      accentColor: const Color(0xFFF1D3DF),
      category: 'Aesthetic',
      description: 'Pink pastel with ribbon decorations.',
    ),
    PhotostripTemplate(
      id: 'aesthetic-lavender-2',
      name: 'Cloudy Dream',
      layout: TemplateLayout.vertical,
      slotCount: 2,
      backgroundColor: const Color(0xFFF3E5F5),
      accentColor: const Color(0xFFCE93D8),
      category: 'Aesthetic',
      description: 'Spacious dual-frame with a dreamy vibe.',
    ),

    // RETRO / VINTAGE
    PhotostripTemplate(
      id: 'retro-sepia-4',
      name: 'Retro Vinyl',
      layout: TemplateLayout.vertical,
      slotCount: 4,
      backgroundColor: const Color(0xFFF5F5DC),
      accentColor: const Color(0xFF8B4513),
      category: 'Retro',
      description: 'Old-school aesthetic with warm tones.',
    ),
    PhotostripTemplate(
      id: 'retro-denim-3',
      name: '90s Vibe',
      layout: TemplateLayout.vertical,
      slotCount: 3,
      backgroundColor: const Color(0xFFE3F2FD),
      accentColor: const Color(0xFF1976D2),
      category: 'Retro',
      description: 'Blue gradients and retro typography.',
    ),

    // MINIMAL / DARK
    PhotostripTemplate(
      id: 'minimal-black-4',
      name: 'Noir Elegance',
      layout: TemplateLayout.vertical,
      slotCount: 4,
      backgroundColor: const Color(0xFF212121),
      accentColor: Colors.white,
      category: 'Minimal',
      description: 'Sleek black background for high contrast.',
    ),

    // SPECIAL THEME
    PhotostripTemplate(
      id: 'theater-ticket-3',
      name: 'Theater Ticket',
      layout: TemplateLayout.vertical,
      slotCount: 3,
      backgroundColor: const Color(0xFFF5F5DC), // Creamy beige
      accentColor: const Color(0xFF8B0000), // Dark Red
      category: 'Special',
      description: 'A vintage theater ticket with stub and barcode.',
    ),
  ];
}
