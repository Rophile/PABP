import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapbooth_mobile/models/template.dart';

class ImageService {
  static Future<Uint8List> generatePhotostrip({
    required List<XFile> photos,
    required PhotostripTemplate template,
  }) async {
    // Default dimensions
    double stripWidth = 600.0;
    double stripHeight;
    
    ui.Image? templateImage;
    if (template.assetPath != null) {
      templateImage = await _loadAssetImage(template.assetPath!);
      // Calculate height based on template's aspect ratio
      double aspectRatio = templateImage.height / templateImage.width;
      stripHeight = stripWidth * aspectRatio;
    } else {
      // Fallback for non-asset templates
      const double padding = 20.0;
      const double photoWidth = 600.0 - (padding * 2);
      const double photoHeight = photoWidth * 0.75;
      const double footerHeight = 80.0;
      stripHeight = (padding * (photos.length + 1)) +
          (photoHeight * photos.length) +
          footerHeight;
      stripWidth = 600.0;
    }

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(
      recorder,
      ui.Rect.fromLTWH(0, 0, stripWidth, stripHeight),
    );

    // 1. Draw background color
    final Paint bgPaint = Paint()..color = template.backgroundColor;
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, stripWidth, stripHeight), bgPaint);

    // 2. Draw template as background if it exists
    if (templateImage != null) {
      _paintImage(
        canvas,
        templateImage,
        ui.Rect.fromLTWH(0, 0, stripWidth, stripHeight),
        fit: BoxFit.fill, // Ensure full frame is shown
      );
    }

    // Photo placement logic
    if (template.assetPath != null) {
      // If we have a custom asset, we need to place photos inside its slots.
      // For now, we'll use a proportional approach. 
      // Most photostrips have slots centered and evenly spaced.
      double availableHeight = stripHeight;
      double slotHeight = availableHeight / (template.slotCount + 1); // rough estimate
      
      // Theater Ticket specific logic for photo placement if needed
      // Or general logic:
      double paddingX = stripWidth * 0.12; // 12% padding
      double photoW = stripWidth - (paddingX * 2);
      double photoH = photoW * 0.75;
      
      // Calculate vertical start based on common theater ticket layouts (usually starts after a header)
      double currentTop = stripHeight * 0.15; 
      double spacing = (stripHeight * 0.65 - (photoH * photos.length)) / (photos.length - 1);
      if (photos.length == 1) spacing = 0;

      for (int i = 0; i < photos.length; i++) {
        final ui.Image image = await _loadUiImage(photos[i].path);
        final Rect destRect = Rect.fromLTWH(paddingX, currentTop, photoW, photoH);
        _paintImage(canvas, image, destRect);
        currentTop += photoH + spacing;
      }
    } else {
      // Standard logic for generated templates
      const double padding = 20.0;
      const double photoWidth = 600.0 - (padding * 2);
      const double photoHeight = photoWidth * 0.75;
      double currentTop = padding;

      // Special Header (non-asset)
      if (template.id == 'theater-ticket-3') {
        final headerPainter = TextPainter(
          text: TextSpan(
            text: '★ ★ ★\nTHEATER TICKET',
            style: TextStyle(color: template.accentColor, fontSize: 40, fontWeight: FontWeight.bold, height: 1.2),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        headerPainter.layout(minWidth: 0, maxWidth: stripWidth);
        headerPainter.paint(canvas, Offset(0, currentTop));
        currentTop += headerPainter.height + padding;
      }

      for (int i = 0; i < photos.length; i++) {
        final ui.Image image = await _loadUiImage(photos[i].path);
        final Rect destRect = Rect.fromLTWH(padding, currentTop, photoWidth, photoHeight);
        final Paint borderPaint = Paint()
          ..color = template.accentColor.withAlpha(100)
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawRect(destRect, borderPaint);
        _paintImage(canvas, image, destRect);
        currentTop += photoHeight + padding;
      }
      
      // Standard Footer (non-asset)
      if (template.id != 'theater-ticket-3') {
        final textPainter = TextPainter(
          text: TextSpan(
            text: 'SnapBooth',
            style: TextStyle(color: template.accentColor, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset((stripWidth - textPainter.width) / 2, stripHeight - 60));
      }
    }

    // 3. Draw template AGAIN as an overlay
    if (templateImage != null) {
      _paintImage(
        canvas,
        templateImage,
        ui.Rect.fromLTWH(0, 0, stripWidth, stripHeight),
        fit: BoxFit.fill,
      );
    }

    final ui.Picture picture = recorder.endRecording();
    final ui.Image finalImage = await picture.toImage(stripWidth.toInt(), stripHeight.toInt());
    final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static Future<ui.Image> _loadAssetImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(data.buffer.asUint8List(), (ui.Image img) => completer.complete(img));
    return completer.future;
  }

  static Future<ui.Image> _loadUiImage(String path) async {
    final Uint8List data = await File(path).readAsBytes();
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(data, (ui.Image img) => completer.complete(img));
    return completer.future;
  }

  static void _paintImage(ui.Canvas canvas, ui.Image image, Rect rect, {BoxFit fit = BoxFit.cover}) {
    final double srcWidth = image.width.toDouble();
    final double srcHeight = image.height.toDouble();
    final double destWidth = rect.width;
    final double destHeight = rect.height;

    Rect srcRect;
    if (fit == BoxFit.cover) {
      double srcRectWidth = srcWidth;
      double srcRectHeight = srcHeight;
      if (srcWidth / srcHeight > destWidth / destHeight) {
        srcRectWidth = srcHeight * (destWidth / destHeight);
      } else {
        srcRectHeight = srcWidth * (destHeight / destWidth);
      }
      srcRect = Rect.fromLTWH((srcWidth - srcRectWidth) / 2, (srcHeight - srcRectHeight) / 2, srcRectWidth, srcRectHeight);
    } else {
      srcRect = Rect.fromLTWH(0, 0, srcWidth, srcHeight);
    }

    canvas.drawImageRect(image, srcRect, rect, Paint()..filterQuality = FilterQuality.high);
  }
}
