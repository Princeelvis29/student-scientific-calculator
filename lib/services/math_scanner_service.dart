import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class MathScannerService {
  const MathScannerService();

  bool get isAvailable => !kIsWeb;

  Future<String?> scanFromCamera() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Camera OCR is reserved for Android/iOS builds.',
      );
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (image == null) {
      return null;
    }

    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      return _clean(recognizedText.text);
    } finally {
      await textRecognizer.close();
    }
  }

  String _clean(String value) {
    return value
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('X', '×')
        .replaceAll('x', '×')
        .replaceAll('*', '×')
        .replaceAll('/', '÷')
        .replaceAll('−', '-')
        .replaceAll('–', '-');
  }
}
