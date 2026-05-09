import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:snapbooth_mobile/models/template.dart';

class PhotoboothProvider extends ChangeNotifier {
  PhotostripTemplate? _selectedTemplate;
  int _timerDuration = 3; // 3, 5, or 10 seconds
  bool _isMirrorMode = true;
  bool _isCapturing = false;
  int _currentSlotIndex = 0;
  final List<XFile> _capturedPhotos = [];
  int _countdownValue = 0;
  Timer? _countdownTimer;

  // Getters
  PhotostripTemplate? get selectedTemplate => _selectedTemplate;
  int get timerDuration => _timerDuration;
  bool get isMirrorMode => _isMirrorMode;
  bool get isCapturing => _isCapturing;
  int get currentSlotIndex => _currentSlotIndex;
  List<XFile> get capturedPhotos => _capturedPhotos;
  int get countdownValue => _countdownValue;

  void selectTemplate(PhotostripTemplate template) {
    _selectedTemplate = template;
    notifyListeners();
  }

  void setTimerDuration(int duration) {
    _timerDuration = duration;
    notifyListeners();
  }

  void toggleMirrorMode() {
    _isMirrorMode = !_isMirrorMode;
    notifyListeners();
  }

  void resetSession() {
    _isCapturing = false;
    _currentSlotIndex = 0;
    _capturedPhotos.clear();
    _countdownValue = 0;
    _countdownTimer?.cancel();
    notifyListeners();
  }

  Future<void> startCaptureSession(CameraController controller) async {
    if (_selectedTemplate == null || _isCapturing) return;

    _isCapturing = true;
    _currentSlotIndex = 0;
    _capturedPhotos.clear();
    notifyListeners();

    for (int i = 0; i < _selectedTemplate!.slotCount; i++) {
      _currentSlotIndex = i;
      await _runCountdown();
      
      final XFile photo = await controller.takePicture();
      _capturedPhotos.add(photo);
      notifyListeners();
    }

    _isCapturing = false;
    notifyListeners();
  }

  Future<void> _runCountdown() async {
    _countdownValue = _timerDuration;
    notifyListeners();

    final completer = Completer<void>();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownValue > 1) {
        _countdownValue--;
        notifyListeners();
      } else {
        _countdownValue = 0;
        timer.cancel();
        completer.complete();
      }
    });

    return completer.future;
  }
}
