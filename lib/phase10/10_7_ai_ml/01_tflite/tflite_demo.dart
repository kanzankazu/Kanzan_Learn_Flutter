/// Phase 10.7 — Topic 01: TFLite (On-Device ML with TensorFlow Lite)
///
/// TFLite runs ML models directly on the device — no internet needed,
/// no cloud API calls, no privacy concerns about sending data to servers.
///
/// Key concepts covered:
/// 1. What TFLite is — .tflite model format, quantization
/// 2. tflite_flutter package — load models, run inference
/// 3. Tensor I/O — input/output shapes, data types
/// 4. Image classification — MobileNet, EfficientNet
/// 5. Object detection — SSD MobileNet, bounding boxes
/// 6. Text classification — embedding models
/// 7. Model optimization — quantization types (INT8, FP16)
/// 8. GPU delegate — use GPU for faster inference
import 'package:flutter/material.dart';

void main() => runApp(const _App());
class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'TFLite Demo',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
    home: const TfliteDemo(),
  );
}

class TfliteDemo extends StatefulWidget {
  const TfliteDemo({super.key});
  @override
  State<TfliteDemo> createState() => _TfliteDemoState();
}

class _TfliteDemoState extends State<TfliteDemo> {
  // Simulated inference results
  final List<(String, double)> _results = [];
  bool _running = false;

  Future<void> _runInference() async {
    setState(() { _running = true; _results.clear(); });
    await Future.delayed(const Duration(milliseconds: 800)); // simulate inference time

    // Simulated classification output
    setState(() {
      _running = false;
      _results.addAll([
        ('cat', 0.89),
        ('kitten', 0.07),
        ('dog', 0.02),
        ('rabbit', 0.01),
        ('bird', 0.01),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('01 — TFLite'), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(color: Colors.deepPurple.shade50, child: const Text(
            'TFLite runs ML models on-device:\n'
            '• No internet required\n'
            '• User data stays on device (privacy)\n'
            '• Zero latency (no round-trip to server)\n'
            '• Works offline',
            style: TextStyle(fontSize: 13),
          )),
          const SizedBox(height: 16),

          // ── Live demo ──────────────────────────────────────────────────
          _h('Live Demo — Simulated Classification', Colors.deepPurple),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Container(height: 120, width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    alignment: Alignment.center,
                    child: const Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('🐱', style: TextStyle(fontSize: 48)),
                      Text('Simulated camera frame', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  if (_running) const CircularProgressIndicator()
                  else FilledButton.icon(
                    onPressed: _runInference,
                    icon: const Icon(Icons.psychology, size: 16),
                    label: const Text('Run Inference'),
                  ),
                  if (_results.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...(_results.map((r) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(children: [
                        SizedBox(width: 80, child: Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w500))),
                        Expanded(child: LinearProgressIndicator(value: r.$2, backgroundColor: Colors.grey.shade200)),
                        const SizedBox(width: 8),
                        Text('${(r.$2 * 100).toStringAsFixed(0)}%', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                      ]),
                    ))),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          _h('1. Setup + Load Model', Colors.deepPurple),
          _code(r'''
# pubspec.yaml
dependencies:
  tflite_flutter: ^0.10.4

# assets/models/mobilenet_v2.tflite  ← put model here
flutter:
  assets:
    - assets/models/mobilenet_v2.tflite
    - assets/labels/imagenet_labels.txt

// Load the model
import 'package:tflite_flutter/tflite_flutter.dart';

class ImageClassifier {
  late final Interpreter _interpreter;
  late final List<String> _labels;

  Future<void> init() async {
    // Load model from assets
    _interpreter = await Interpreter.fromAsset('assets/models/mobilenet_v2.tflite');

    // Use GPU delegate for ~5-10x faster inference on modern phones
    try {
      final gpuDelegate = GpuDelegateV2();
      _interpreter = await Interpreter.fromAsset(
        'assets/models/mobilenet_v2.tflite',
        options: InterpreterOptions()..addDelegate(gpuDelegate),
      );
    } catch (e) {
      // Fall back to CPU if GPU not available
      _interpreter = await Interpreter.fromAsset('assets/models/mobilenet_v2.tflite');
    }

    // Load label list
    final labelsData = await rootBundle.loadString('assets/labels/imagenet_labels.txt');
    _labels = labelsData.split('\n');
  }'''),

          const SizedBox(height: 20),
          _h('2. Image Classification Inference', Colors.blue),
          _code(r'''
// Run inference on a camera frame or image file
Future<List<(String, double)>> classifyImage(Uint8List imageBytes) async {
  // Preprocess: resize to model input size (224x224 for MobileNet)
  final img = image.decodeImage(imageBytes)!;
  final resized = image.copyResize(img, width: 224, height: 224);

  // Convert to float32 tensor [1, 224, 224, 3] (batch, height, width, channels)
  final input = List.generate(1, (_) =>
    List.generate(224, (y) =>
      List.generate(224, (x) {
        final pixel = resized.getPixel(x, y);
        // Normalize to [-1.0, 1.0] for MobileNetV2
        return [
          (image.getRed(pixel) / 127.5) - 1.0,
          (image.getGreen(pixel) / 127.5) - 1.0,
          (image.getBlue(pixel) / 127.5) - 1.0,
        ];
      })
    )
  );

  // Output tensor [1, 1001] — 1001 ImageNet classes
  final output = List.generate(1, (_) => List.filled(1001, 0.0));

  // Run inference (< 10ms on modern phone with GPU delegate)
  _interpreter.run(input, output);

  // Convert output to (label, confidence) pairs, sorted by confidence
  final scores = output[0];
  final results = scores.asMap().entries.map((e) => (_labels[e.key], e.value)).toList();
  results.sort((a, b) => b.$2.compareTo(a.$2));

  return results.take(5).toList(); // top 5 predictions
}'''),

          const SizedBox(height: 20),
          _h('3. Model Quantization', Colors.orange),
          _card(color: Colors.orange.shade50, child: Table(
            columnWidths: const {0: FlexColumnWidth(1.5), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1)},
            border: TableBorder.all(color: Colors.orange.shade200),
            children: [
              _tr(['Type', 'Size', 'Speed', 'Accuracy'], header: true),
              _tr(['FP32 (original)', '~16MB', 'Baseline', '100%']),
              _tr(['FP16 quant', '~8MB', '1.5x faster', '~99%']),
              _tr(['INT8 quant', '~4MB', '2-4x faster', '~98%']),
              _tr(['INT8 + GPU', '~4MB', '5-10x faster', '~98%']),
            ],
          )),

          const SizedBox(height: 16),
          _card(color: Colors.deepPurple.shade50, child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• TFLite runs ML on-device — no internet, no latency, privacy-safe'),
              Text('• Interpreter.fromAsset() loads .tflite model from Flutter assets'),
              Text('• Input tensor: normalize pixels to model expected range'),
              Text('• Output tensor: read probabilities, map to labels'),
              Text('• GPU delegate: 5-10x speedup on modern Android/iOS'),
              Text('• INT8 quantization: 4x smaller model, ~2-4x faster, minimal accuracy loss'),
            ],
          )),
        ],
      ),
    );
  }

  TableRow _tr(List<String> cells, {bool header = false}) => TableRow(
    decoration: header ? BoxDecoration(color: Colors.orange.shade100) : null,
    children: cells.map((c) => Padding(padding: const EdgeInsets.all(6), child: Text(c, style: TextStyle(fontSize: 11, fontWeight: header ? FontWeight.bold : FontWeight.normal)))).toList(),
  );
}

Widget _h(String t, Color c) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: c)));
Widget _code(String s) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(6)), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(s, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCDD6F4)))));
Widget _card({required Color color, required Widget child}) => Card(color: color, child: Padding(padding: const EdgeInsets.all(12), child: child));
