/// Phase 10.7 — Topic 03: On-Device LLM
///
/// On-device LLMs run Large Language Models directly on the user's phone
/// without any internet connection. Privacy-first, zero latency.
///
/// Key frameworks:
/// - Google AI Edge (LiteRT) — gemma-2b, gemma-nano, paligemma
/// - MediaPipe LLM Inference — same models, different API
/// - llama.cpp + dart bindings — llama, phi, mistral
///
/// Key concepts covered:
/// 1. Which models run on mobile — size/quality tradeoffs
/// 2. LiteRT (formerly TFLite) for LLM tasks
/// 3. MediaPipe LLM Inference API
/// 4. Prompt engineering for small models
/// 5. Streaming output — token-by-token display
/// 6. Context window management
/// 7. On-device vs cloud LLM — when to use which
import 'package:flutter/material.dart';

void main() => runApp(const _App());
class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'On-Device LLM',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), useMaterial3: true),
    home: const OnDeviceLlmDemo(),
  );
}

class OnDeviceLlmDemo extends StatefulWidget {
  const OnDeviceLlmDemo({super.key});
  @override
  State<OnDeviceLlmDemo> createState() => _OnDeviceLlmDemoState();
}

class _OnDeviceLlmDemoState extends State<OnDeviceLlmDemo> {
  final _ctrl = TextEditingController(text: 'Classify this expense: "Lunch at Warteg, Rp 35.000"');
  String _response = '';
  bool _generating = false;
  int _tokenCount = 0;

  // Simulate streaming token generation
  Future<void> _generate() async {
    setState(() { _generating = true; _response = ''; _tokenCount = 0; });

    const tokens = ['Category:', ' Food', ' &', ' Dining', '\nAmount:', ' Rp', ' 35,000', '\nConfidence:', ' 0.95', '\nNote:', ' Affordable', ' street', ' food', ' meal'];

    for (final token in tokens) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      setState(() { _response += token; _tokenCount++; });
    }
    setState(() => _generating = false);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('03 — On-Device LLM'), backgroundColor: Colors.teal.shade700, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(color: Colors.teal.shade50, child: const Text(
            'On-device LLMs run directly on the phone:\n'
            '• No internet — works fully offline\n'
            '• No API cost — free after download\n'
            '• Privacy — data never leaves the device\n'
            '• Tradeoff: smaller models (1-7B params) vs cloud (70B+)',
            style: TextStyle(fontSize: 13),
          )),
          const SizedBox(height: 16),

          // ── Live demo ──────────────────────────────────────────────────
          _h('Live Demo — Simulated On-Device LLM', Colors.teal),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Prompt:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _ctrl,
                    maxLines: 3,
                    decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: _generating ? null : _generate,
                    icon: Icon(_generating ? Icons.stop : Icons.psychology, size: 16),
                    label: Text(_generating ? 'Generating...' : 'Generate'),
                  ),
                  if (_response.isNotEmpty || _generating) ...[
                    const SizedBox(height: 10),
                    const Text('Response:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: SelectableText(_response + (_generating ? '▌' : ''), style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    ),
                    if (_tokenCount > 0)
                      Text('$_tokenCount tokens generated', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          _h('1. Model Comparison for Mobile', Colors.blue),
          _card(color: Colors.blue.shade50, child: Table(
            columnWidths: const {0: FlexColumnWidth(1.5), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1)},
            border: TableBorder.all(color: Colors.blue.shade200),
            children: [
              _tr(['Model', 'Size', 'RAM', 'Quality'], header: true),
              _tr(['Gemma Nano 1B', '~700MB', '~1.5GB', 'Basic']),
              _tr(['Gemma 2B INT8', '~1.5GB', '~2GB', 'Good']),
              _tr(['Phi-3 Mini', '~2.2GB', '~3GB', 'Good']),
              _tr(['Gemma 7B (FP16)', '~7GB', '~8GB', 'Great']),
              _tr(['GPT-4 (cloud)', 'N/A', 'N/A', 'Excellent']),
            ],
          )),

          const SizedBox(height: 20),
          _h('2. MediaPipe LLM Inference API', Colors.purple),
          _code(r'''
# pubspec.yaml
dependencies:
  flutter_mediapipe_llm: ^0.1.0  # MediaPipe LLM for Flutter

// Initialize the LLM session
import 'package:flutter_mediapipe_llm/flutter_mediapipe_llm.dart';

class OnDeviceLlmService {
  LlmInferenceSession? _session;

  Future<void> init() async {
    // Model file must be in assets or downloaded to app storage
    // Download from: huggingface.co/google/gemma-2-2b-it-gpu-int8
    final modelPath = await _downloadModelIfNeeded('gemma-2-2b-it-gpu-int8.bin');

    _session = await LlmInference.createSession(
      LlmInferenceOptions(
        modelPath: modelPath,
        maxTokens: 512,
        topK: 40,
        temperature: 0.8,
        randomSeed: 42,
      ),
    );
  }

  // Streaming generation — yields tokens one by one
  Stream<String> generate(String prompt) async* {
    if (_session == null) await init();

    // System prompt sets the context for the model
    final fullPrompt = '<start_of_turn>user\n'
        '\$prompt\n'
        '<end_of_turn>\n'
        '<start_of_turn>model\n';

    // generateResponseAsync streams tokens
    await for (final token in _session!.generateResponseAsync(fullPrompt)) {
      yield token;
    }
  }

  Future<void> dispose() async {
    await _session?.close();
  }
}

// Usage in Flutter (with Riverpod streaming):
@riverpod
Stream<String> llmResponse(LlmResponseRef ref, String prompt) {
  return ref.watch(llmServiceProvider).generate(prompt);
}

// Widget: stream tokens into a text widget
StreamBuilder<String>(
  stream: ref.watch(llmResponseProvider(prompt)),
  builder: (_, snapshot) {
    return Text(snapshot.data ?? '');
  },
)'''),

          const SizedBox(height: 20),
          _h('3. Prompt Engineering for Small Models', Colors.orange),
          _code(r'''
// Small models (1-7B) need clear, structured prompts

// ❌ Bad prompt: vague, no structure
String badPrompt(String expense) => "What is this expense? $expense";

// ✅ Good prompt: role, task, format, example
String goodPrompt(String expense) => """
You are a financial expense categorizer.
Classify the following expense into exactly one category.
Return ONLY JSON, no explanation.

Categories: Food, Transport, Housing, Health, Entertainment, Shopping, Education, Other

Expense: $expense

Response format:
{"category": "Food", "confidence": 0.95, "amount_idr": 35000}
""";

// For classification tasks: few-shot examples improve accuracy
String fewShotPrompt(String expense) => """
You are a financial expense categorizer.

Examples:
Input: Lunch at Warteg, Rp 35.000
Output: {"category": "Food", "confidence": 0.98}

Input: Grab car to office, Rp 25.000
Output: {"category": "Transport", "confidence": 0.97}

Input: PLN electricity bill, Rp 350.000
Output: {"category": "Housing", "confidence": 0.99}

Now classify:
Input: $expense
Output:
""";'''),

          const SizedBox(height: 16),
          _card(color: Colors.teal.shade50, child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Gemma Nano / Phi-3 Mini fit on mobile (1-3GB RAM)'),
              Text('• MediaPipe LLM Inference API handles model loading and inference'),
              Text('• Stream tokens one by one for responsive UI (not wait for full response)'),
              Text('• Structured prompts + few-shot examples = much better results on small models'),
              Text('• Use INT8 quantization to halve model size with minimal quality loss'),
              Text('• On-device: privacy + offline. Cloud: smarter + no download needed'),
            ],
          )),
        ],
      ),
    );
  }

  TableRow _tr(List<String> cells, {bool header = false}) => TableRow(
    decoration: header ? BoxDecoration(color: Colors.blue.shade100) : null,
    children: cells.map((c) => Padding(padding: const EdgeInsets.all(6), child: Text(c, style: TextStyle(fontSize: 11, fontWeight: header ? FontWeight.bold : FontWeight.normal)))).toList(),
  );
}

Widget _h(String t, Color c) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: c)));
Widget _code(String s) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(6)), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(s, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCDD6F4)))));
Widget _card({required Color color, required Widget child}) => Card(color: color, child: Padding(padding: const EdgeInsets.all(12), child: child));
