/// Phase 10.7 — Topic 02: Google ML Kit
///
/// ML Kit provides ready-to-use ML APIs that run on-device — no model
/// training needed. Just call the API and get results.
///
/// Available ML Kit APIs in Flutter (google_mlkit_* packages):
/// - Text Recognition (OCR) — extract text from images
/// - Face Detection — detect faces, landmarks, emotions
/// - Barcode Scanning — read QR, EAN-13, Code-128, etc.
/// - Object Detection — detect and track objects in real-time
/// - Pose Detection — detect body landmarks
/// - Language Detection / Translation
/// - Smart Reply — suggest replies to messages
///
/// Key concepts covered:
/// 1. Package setup — multiple google_mlkit_* packages
/// 2. InputImage — the common input for all ML Kit APIs
/// 3. Text Recognition — OCR from camera or gallery
/// 4. Barcode Scanning — scan QR codes / product barcodes
/// 5. Face Detection — landmarks, contours, classifications
/// 6. Processing pipeline — camera stream → ML Kit → overlay
import 'package:flutter/material.dart';

void main() => runApp(const _App());
class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ML Kit Demo',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
    home: const MlKitDemo(),
  );
}

class MlKitDemo extends StatefulWidget {
  const MlKitDemo({super.key});
  @override
  State<MlKitDemo> createState() => _MlKitDemoState();
}

class _MlKitDemoState extends State<MlKitDemo> {
  String _recognizedText = '';
  String _detectedBarcode = '';
  bool _processing = false;

  Future<void> _simulateOcr() async {
    setState(() { _processing = true; _recognizedText = ''; });
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {
      _processing = false;
      _recognizedText = 'Date: 24/08/2026\nMerchant: Warung Makan Pak Budi\nTotal: Rp 45.000\nPayment: Cash';
    });
  }

  Future<void> _simulateBarcode() async {
    setState(() { _processing = true; _detectedBarcode = ''; });
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      _processing = false;
      _detectedBarcode = 'Type: QR Code\nValue: https://pay.example.com/tx/TXN-20260824-001\nAmount: Rp 45.000';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('02 — ML Kit'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(color: Colors.blue.shade50, child: const Text(
            'ML Kit = Google\'s on-device ML APIs for common tasks.\n\n'
            'No training, no .tflite file management — just call the API.\n'
            'Models are downloaded on first use and cached on device.',
            style: TextStyle(fontSize: 13),
          )),
          const SizedBox(height: 16),

          _h('1. Package Setup', Colors.blue),
          _code(r'''
# pubspec.yaml — install only the APIs you need
dependencies:
  google_mlkit_text_recognition: ^0.13.1  # OCR
  google_mlkit_barcode_scanning: ^0.12.0  # QR / barcode
  google_mlkit_face_detection: ^0.12.0    # face detection
  google_mlkit_object_detection: ^0.14.0  # object detection
  camera: ^0.11.0                          # camera stream
  image_picker: ^1.1.2                     # pick from gallery'''),

          const SizedBox(height: 20),
          _h('2. Text Recognition (OCR) — Live Demo', Colors.teal),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  // Simulated receipt image
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                    alignment: Alignment.center,
                    child: const Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.receipt, size: 32, color: Colors.grey),
                      Text('Simulated receipt image', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  if (_processing) const CircularProgressIndicator()
                  else FilledButton.icon(
                    onPressed: _simulateOcr,
                    icon: const Icon(Icons.text_fields, size: 16),
                    label: const Text('Scan Text (OCR)'),
                  ),
                  if (_recognizedText.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                      child: SelectableText(_recognizedText, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          _code(r'''
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

Future<String> recognizeText(File imageFile) async {
  // InputImage is the universal input type for all ML Kit APIs
  final inputImage = InputImage.fromFile(imageFile);

  // Run OCR — returns structured result with blocks, lines, elements
  final result = await _recognizer.processImage(inputImage);

  // Access recognized text
  final fullText = result.text;  // plain string

  // Structured access: blocks → lines → elements
  for (final block in result.blocks) {
    for (final line in block.lines) {
      print('Line: ${line.text}  Confidence: ${line.confidence}');
      print('BoundingBox: ${line.boundingBox}'); // for drawing overlays
    }
  }

  await _recognizer.close(); // release resources

  return fullText;
}

// Or from camera buffer (real-time OCR):
Future<String> recognizeFromCameraFrame(CameraImage cameraImage, InputImageRotation rotation) async {
  final inputImage = InputImage.fromBytes(
    bytes: cameraImage.planes[0].bytes,
    metadata: InputImageMetadata(
      size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
      rotation: rotation,
      format: InputImageFormat.yuv_420_888,
      bytesPerRow: cameraImage.planes[0].bytesPerRow,
    ),
  );
  final result = await _recognizer.processImage(inputImage);
  return result.text;
}'''),

          const SizedBox(height: 20),
          _h('3. Barcode Scanner — Live Demo', Colors.purple),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Container(height: 80, width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                    alignment: Alignment.center,
                    child: const Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.qr_code_2, size: 40, color: Colors.grey),
                      Text('Simulated QR code', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: Colors.purple),
                    onPressed: _simulateBarcode,
                    icon: const Icon(Icons.qr_code_scanner, size: 16),
                    label: const Text('Scan Barcode'),
                  ),
                  if (_detectedBarcode.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Text(_detectedBarcode, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          _code(r'''
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

// Configure which barcode formats to scan (narrower = faster)
final _scanner = BarcodeScanner(formats: [
  BarcodeFormat.qrCode,
  BarcodeFormat.ean13,
  BarcodeFormat.code128,
]);

Future<List<Barcode>> scanBarcodes(InputImage inputImage) async {
  final barcodes = await _scanner.processImage(inputImage);

  for (final barcode in barcodes) {
    print('Type: ${barcode.type.name}');         // qrCode, ean13, etc.
    print('Value: ${barcode.rawValue}');          // decoded string value
    print('Bounding box: ${barcode.boundingBox}'); // for drawing overlay

    // Typed value access for specific barcode types:
    if (barcode.type == BarcodeType.url) {
      print('URL: ${barcode.value?.url?.url}');
    } else if (barcode.type == BarcodeType.wifi) {
      final wifi = barcode.value?.wifi;
      print('SSID: ${wifi?.ssid}  Password: ${wifi?.password}');
    }
  }

  return barcodes;
}'''),

          const SizedBox(height: 16),
          _card(color: Colors.blue.shade50, child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• ML Kit APIs are ready-to-use — no model management needed'),
              Text('• InputImage is the universal input — supports File, bytes, camera stream'),
              Text('• OCR: result.text for plain string; result.blocks for structured access'),
              Text('• Barcode scanner: specify formats to scan — narrower is faster'),
              Text('• Always call recognizer.close() to release GPU/native resources'),
              Text('• Camera stream: process every Nth frame to avoid overloading the ML thread'),
            ],
          )),
        ],
      ),
    );
  }
}

Widget _h(String t, Color c) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: c)));
Widget _code(String s) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(6)), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(s, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCDD6F4)))));
Widget _card({required Color color, required Widget child}) => Card(color: color, child: Padding(padding: const EdgeInsets.all(12), child: child));
