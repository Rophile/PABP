import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:snapbooth_mobile/models/template.dart';

class ImageService {
  static Future<Uint8List> generatePhotostrip({
    required List<XFile> photos,
    required PhotostripTemplate template,
  }) async {
    // Standard photostrip aspect ratio is roughly 1:3 or 1:4 depending on slots
    // Let's assume a fixed width and calculate height
    const double stripWidth = 600.0;
    const double padding = 20.0;
    const double photoWidth = stripWidth - (padding * 2);
    const double photoHeight = photoWidth * 0.75; // 4:3 aspect ratio for each photo
    
    final double footerHeight = 80.0;
    final double stripHeight = (padding * (photos.length + 1)) + (photoHeight * photos.length) + footerHeight;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder, ui.Rect.fromLTWH(0, 0, stripWidth, stripHeight));
    
    // Draw background
    final Paint bgPaint = Paint()..color = template.backgroundColor;
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, stripWidth, stripHeight), bgPaint);

    double currentTop = padding;

    // Special Header for Theater Ticket
    if (template.id == 'theater-ticket-3') {
      final headerPainter = TextPainter(
        text: TextSpan(
          text: '★ ★ ★\nTHEATER TICKET',
          style: TextStyle(
            color: template.accentColor,
            fontSize: 40,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      headerPainter.layout(width: stripWidth);
      headerPainter.paint(canvas, Offset(0, currentTop));
      currentTop += headerPainter.height + padding;
    }

    for (int i = 0; i < photos.length; i++) {
      final ui.Image image = await _loadUiImage(photos[i].path);
      
      final Rect destRect = Rect.fromLTWH(padding, currentTop, photoWidth, photoHeight);
      
      // Draw frame border
      final Paint borderPaint = Paint()
        ..color = template.accentColor.withAlpha(100)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(destRect, borderPaint);

      _paintImage(canvas, image, destRect);
      currentTop += photoHeight + padding;
    }

    // Special Footer for Theater Ticket
    if (template.id == 'theater-ticket-3') {
      // Perforated line simulation
      final dashPaint = Paint()
        ..color = template.accentColor.withAlpha(100)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      double dashWidth = 10, dashSpace = 5;
      double startX = 0;
      while (startX < stripWidth) {
        canvas.drawLine(Offset(startX, currentTop), Offset(startX + dashWidth, currentTop), dashPaint);
        startX += dashWidth + dashSpace;
      }
      currentTop += padding;

      // Data fields
      final dataPainter = TextPainter(
        text: TextSpan(
          text: 'MON, JUN 29    ROW 38    SEAT A45',
          style: TextStyle(
            color: template.accentColor,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      dataPainter.layout();
      dataPainter.paint(canvas, Offset((stripWidth - dataPainter.width) / 2, currentTop));
      currentTop += dataPainter.height + padding;

      // Barcode simulation
      final barcodePaint = Paint()..color = template.accentColor;
      double barcodeX = padding * 2;
      for (int i = 0; i < 40; i++) {
        double w = (i % 3 == 0) ? 8.0 : 3.0;
        canvas.drawRect(Rect.fromLTWH(barcodeX, currentTop, w, 40), barcodePaint);
        barcodeX += w + 4;
      }
    } else {
      // Standard Footer
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'SnapBooth',
          style: TextStyle(
            color: template.accentColor,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset((stripWidth - textPainter.width) / 2, stripHeight - footerHeight + (footerHeight - textPainter.height) / 2),
      );
    }

    final ui.Picture picture = recorder.endRecording();
    final ui.Image finalImage = await picture.toImage(stripWidth.toInt(), stripHeight.toInt());
    final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  static Future<ui.Image> _loadUiImage(String path) async {
    final Uint8List data = await File(path).readAsBytes();
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(data, (ui.Image img) => completer.complete(img));
    return completer.future;
  }

  static void _paintImage(ui.Canvas canvas, ui.Image image, Rect rect) {
    final double srcWidth = image.width.toDouble();
    final double srcHeight = image.height.toDouble();
    final double destWidth = rect.width;
    final double destHeight = rect.height;

    // Calculate source rect for center crop (aspect fill)
    double srcRectWidth = srcWidth;
    double srcRectHeight = srcHeight;
    
    if (srcWidth / srcHeight > destWidth / destHeight) {
      srcRectWidth = srcHeight * (destWidth / destHeight);
    } else {
      srcRectHeight = srcWidth * (destHeight / destWidth);
    }

    final Rect srcRect = Rect.fromLTWH(
      (srcWidth - srcRectWidth) / 2,
      (srcHeight - srcRectHeight) / 2,
      srcRectWidth,
      srcRectHeight,
    );

    canvas.drawImageRect(image, srcRect, rect, Paint()..filterQuality = FilterQuality.high);
  }
}
