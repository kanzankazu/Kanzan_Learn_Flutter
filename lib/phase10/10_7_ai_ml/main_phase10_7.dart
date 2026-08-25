/// Entry point Phase 10.7 — Track 7: AI/ML Mobile
import 'package:flutter/material.dart';

import '01_tflite/tflite_demo.dart';
import '02_ml_kit/ml_kit_demo.dart';
import '03_on_device_llm/on_device_llm_demo.dart';
import '04_ai_patterns/ai_patterns_demo.dart';
import 'mini_projects/smart_scanner/smart_scanner_app.dart';

void main() => runApp(const Phase107MenuApp());

class Phase107MenuApp extends StatelessWidget {
  const Phase107MenuApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Phase 10.7 — AI/ML',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange), useMaterial3: true),
        home: const Phase107MenuScreen(),
      );
}

class Phase107MenuScreen extends StatelessWidget {
  const Phase107MenuScreen({super.key});

  static const _topics = [
    _T('01 — TFLite', 'Model loading, tensor I/O, image classification, GPU delegate, quantization', Icons.model_training, Colors.deepPurple, TfliteDemo()),
    _T('02 — ML Kit', 'OCR (text recognition), barcode scanning, face detection, real-time processing', Icons.text_fields, Colors.blue, MlKitDemo()),
    _T('03 — On-Device LLM', 'MediaPipe LLM, gemma nano, prompt engineering, streaming tokens', Icons.psychology, Colors.teal, OnDeviceLlmDemo()),
    _T('04 — AI Patterns', 'On-device vs cloud, RAG, embedding search, hybrid pipeline, caching', Icons.auto_awesome, Colors.orange, AiPatternsDemo()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phase 10.7 — AI/ML Mobile'), backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.deepOrange.shade50,
            child: const Padding(padding: EdgeInsets.all(14), child: Text(
              'Track 7 — AI/ML Mobile teaches you to embed intelligence into your Flutter app.\n\n'
              '• TFLite: run any ML model on-device\n'
              '• ML Kit: Google\'s ready-to-use vision APIs\n'
              '• On-device LLM: GPT-quality AI without a cloud subscription\n'
              '• AI Patterns: RAG, hybrid pipelines, embeddings',
              style: TextStyle(fontSize: 13, height: 1.5),
            )),
          ),
          const SizedBox(height: 12),
          ..._topics.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(child: ListTile(
                  leading: CircleAvatar(backgroundColor: t.color.withAlpha(38), child: Icon(t.icon, color: t.color, size: 20)),
                  title: Text(t.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(t.sub, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => t.dest)),
                )),
              )),
          const Divider(height: 24),
          Card(
            color: Colors.deepOrange.shade100,
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.deepOrange, child: Icon(Icons.document_scanner, color: Colors.white)),
              title: const Text('Mini Project: Smart Scanner', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('ML Kit OCR + TFLite classifier → scan receipts, extract amount, auto-categorize'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartScannerApp())),
            ),
          ),
        ],
      ),
    );
  }
}

class _T { final String label, sub; final IconData icon; final Color color; final Widget dest; const _T(this.label, this.sub, this.icon, this.color, this.dest); }
