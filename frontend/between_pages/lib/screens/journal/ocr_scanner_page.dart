import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrScannerPage extends StatefulWidget {
  const OcrScannerPage({super.key});

  @override
  State<OcrScannerPage> createState() => _OcrScannerPageState();
}

class _OcrScannerPageState extends State<OcrScannerPage> {
  bool _isScanning = false;
  String _scannedText = '';

  Future<void> _scanImage(ImageSource source) async {
    setState(() {
      _isScanning = true;
      _scannedText = '';
    });

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        final inputImage = InputImage.fromFilePath(pickedFile.path);
        // Usamos el reconocedor de texto latino (español, inglés, etc.)
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        
        setState(() {
          _scannedText = recognizedText.text;
        });
        
        textRecognizer.close();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al escanear: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escáner de Texto (OCR)'),
        actions: [
          if (_scannedText.trim().isNotEmpty)
            FilledButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Guardar'),
              onPressed: () => Navigator.pop(context, _scannedText.trim()),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _scanImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cámara'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _scanImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isScanning)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _scannedText.isEmpty 
                          ? 'Captura la foto de una página física.\nEl texto extraído aparecerá aquí y podrás guardarlo en tus notas.' 
                          : _scannedText,
                      style: TextStyle(
                        color: _scannedText.isEmpty ? Colors.grey : null,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}