import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class MathScannerService {
  const MathScannerService();

  bool get isAvailable => !kIsWeb;

  Future<String?> scanRawTextFromCamera() async {
    return _pickAndRecognize(ImageSource.camera);
  }

  Future<String?> scanRawTextFromGallery() async {
    return _pickAndRecognize(ImageSource.gallery);
  }

  Future<String?> scanFromCamera() async {
    final String? raw =
        await scanRawTextFromCamera();

    if (raw == null) return null;

    return _legacyClean(raw);
  }

  Future<String?> _pickAndRecognize(
    ImageSource source,
  ) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'ML Kit camera OCR is available in the Android/iOS build, not the Chrome test build.',
      );
    }

    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 92,
    );

    if (image == null) {
      return null;
    }

    final InputImage inputImage =
        InputImage.fromFilePath(image.path);

    final TextRecognizer recognizer =
        TextRecognizer(
      script: TextRecognitionScript.latin,
    );

    try {
      final RecognizedText recognized =
          await recognizer.processImage(inputImage);

      return recognized.text;
    } finally {
      await recognizer.close();
    }
  }

  String _legacyClean(String value) {
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
