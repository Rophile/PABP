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
    
    final double stripHeight = (padding * (photos.length + 1)) + (photoHeight * photos.length);

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder, ui.Rect.fromLTWH(0, 0, stripWidth, stripHeight));
    
    final Paint paint = Paint()..color = Colors.white;
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, stripWidth, stripHeight), paint);

    for (int i = 0; i < photos.length; i++) {
      final ui.Image image = await _loadUiImage(photos[i].path);
      
      final double top = padding + (i * (photoHeight + padding));
      final Rect destRect = Rect.fromLTWH(padding, top, photoWidth, photoHeight);
      
      _paintImage(canvas, image, destRect);
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
