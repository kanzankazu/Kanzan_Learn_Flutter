/// Phase 10.7 — Topic 04: AI Patterns — On-Device vs Cloud
///
/// Building AI features into a Flutter app requires choosing the right
/// architecture. This topic covers the key decision points and patterns.
///
/// Key patterns covered:
/// 1. On-device vs Cloud LLM — decision matrix
/// 2. RAG (Retrieval-Augmented Generation) — ground LLM in your data
/// 3. Embedding search — find similar items without LLM
/// 4. Hybrid pipeline — on-device fast path + cloud for complex cases
/// 5. AI result caching — avoid re-running expensive inferences
/// 6. Graceful degradation — rule-based fallback when AI fails
/// 7. User trust — confidence scores, explainability, corrections
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() => runApp(const _App());
class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'AI Patterns',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange), useMaterial3: true),
    home: const AiPatternsDemo(),
  );
}

class AiPatternsDemo extends StatefulWidget {
  const AiPatternsDemo({super.key});
  @override
  State<AiPatternsDemo> createState() => _AiPatternsDemoState();
}

class _AiPatternsDemoState extends State<AiPatternsDemo> {
  // Simulated embedding search
  final _searchCtrl = TextEditingController();
  List<(String, double)> _searchResults = [];

  void _searchSimilar(String query) {
    if (query.isEmpty) { setState(() => _searchResults = []); return; }
    // Simulate cosine similarity search
    final items = ['Lunch at Warteg', 'GoPay transfer', 'Electricity bill', 'Grab ride home', 'Movie ticket', 'Coffee shop', 'Grocery shopping', 'Phone bill'];
    final scores = items.map((item) {
      final overlap = query.toLowerCase().split(' ').where((w) => item.toLowerCase().contains(w)).length;
      return (item, (overlap / math.max(query.split(' ').length, 1) * 0.7 + math.Random().nextDouble() * 0.3).clamp(0.0, 1.0));
    }).toList()..sort((a, b) => b.$2.compareTo(a.$2));
    setState(() => _searchResults = scores.take(4).toList());
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('04 — AI Patterns'), backgroundColor: Colors.orange, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 1. Decision matrix ─────────────────────────────────────────
          _h('1. On-Device vs Cloud LLM', Colors.orange),
          _card(color: Colors.orange.shade50, child: Table(
            columnWidths: const {0: FlexColumnWidth(1.5), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
            border: TableBorder.all(color: Colors.orange.shade200),
            children: [
              _tr(['Factor', 'On-Device', 'Cloud'], header: true),
              _tr(['Privacy', '✅ Data stays local', '⚠️ Sent to server']),
              _tr(['Offline', '✅ Works offline', '❌ Needs internet']),
              _tr(['Quality', '⚠️ Smaller models', '✅ GPT-4 level']),
              _tr(['Cost', '✅ Free after DL', '💰 Per token']),
              _tr(['Speed (TTT)', '~50ms (no RTT)', '~800ms (network)']),
              _tr(['Model size', '1-7GB on device', 'N/A']),
              _tr(['Best for', 'OCR, classify, NER', 'Complex reasoning']),
            ],
          )),

          const SizedBox(height: 20),

          // ── 2. RAG pattern ─────────────────────────────────────────────
          _h('2. RAG — Retrieval-Augmented Generation', Colors.blue),
          _code(r'''
// RAG solves "LLM hallucination" by grounding the model in your data.
// Pipeline:
//   User question → find relevant context → LLM answers WITH context

class RagPipeline {
  final EmbeddingModel _embedder;  // converts text to vector
  final VectorStore _store;         // stores vectors + retrieves similar
  final LlmService _llm;

  // Step 1: Index your documents (run once at startup / sync)
  Future<void> indexDocuments(List<Document> docs) async {
    for (final doc in docs) {
      // Convert each document to an embedding vector
      final embedding = await _embedder.embed(doc.content);
      // Store vector alongside the original text
      await _store.upsert(doc.id, embedding, metadata: doc);
    }
  }

  // Step 2: Answer a question using RAG
  Future<String> query(String userQuestion) async {
    // Find the 3 most semantically similar documents
    final questionEmbedding = await _embedder.embed(userQuestion);
    final relevantDocs = await _store.search(questionEmbedding, topK: 3);

    // Build an augmented prompt that includes the retrieved context
    final context = relevantDocs.map((d) => d.content).join('\n---\n');
    final augmentedPrompt = """
You are a helpful assistant. Answer the question using ONLY the provided context.
If the answer is not in the context, say "I don't have that information."

Context:
$context

Question: $userQuestion
Answer:""";

    // LLM answers with context → much less hallucination
    return _llm.generate(augmentedPrompt);
  }
}

// On-device RAG with local vector store (sqlite_vector or objectbox):
// 1. Embed each user transaction when created
// 2. When user asks "What did I spend on food last month?" →
//    retrieve similar transactions → LLM summarizes them
// No cloud needed!'''),

          const SizedBox(height: 20),

          // ── 3. Embedding search live demo ──────────────────────────────
          _h('3. Embedding Search — Live Demo', Colors.teal),
          const Text('Type a query to find semantically similar items (simulated cosine similarity):',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              hintText: 'e.g. "food", "transport", "ride"',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: _searchSimilar,
          ),
          const SizedBox(height: 8),
          if (_searchResults.isNotEmpty)
            ..._searchResults.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                Expanded(child: Text(r.$1)),
                SizedBox(width: 100, child: LinearProgressIndicator(value: r.$2, backgroundColor: Colors.grey.shade200)),
                const SizedBox(width: 8),
                Text('${(r.$2 * 100).toStringAsFixed(0)}%', style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
              ]),
            )),

          const SizedBox(height: 20),

          // ── 4. Hybrid pipeline ─────────────────────────────────────────
          _h('4. Hybrid Pipeline Pattern', Colors.purple),
          _code(r'''
// Rule-based (instant) → On-device ML (fast) → Cloud LLM (smart)
// Use the fastest approach that is accurate enough.

class HybridCategorizerPipeline {
  final Map<RegExp, String> _rules;
  final TfliteClassifier _tflite;
  final CloudLlmClient _cloudLlm;

  Future<CategoryResult> categorize(String expenseText) async {
    // Step 1: Rule-based classifier — instant, 0ms
    for (final entry in _rules.entries) {
      if (entry.key.hasMatch(expenseText)) {
        return CategoryResult(
          category: entry.value,
          confidence: 1.0,
          source: 'rule',
        );
      }
    }

    // Step 2: On-device TFLite — ~10ms, no internet
    final tfliteResult = await _tflite.classify(expenseText);
    if (tfliteResult.confidence >= 0.85) {
      return CategoryResult(
        category: tfliteResult.label,
        confidence: tfliteResult.confidence,
        source: 'tflite',
      );
    }

    // Step 3: Cloud LLM — ~800ms, internet required, costs money
    // Only reached when on-device confidence is low
    final llmCategory = await _cloudLlm.categorize(expenseText);
    return CategoryResult(category: llmCategory, confidence: 0.95, source: 'llm');
  }
}

// Result: most requests handled in < 1ms (rules) or < 10ms (TFLite).
// Cloud LLM is only called for ~5% of ambiguous cases.'''),

          const SizedBox(height: 20),

          // ── 5. AI result caching ───────────────────────────────────────
          _h('5. AI Result Caching', Colors.green),
          _code(r'''
// Cache AI results to avoid re-running expensive inference

class CachedAiClassifier {
  final Map<String, CategoryResult> _cache = {};
  final HybridCategorizerPipeline _pipeline;

  Future<CategoryResult> categorize(String text) async {
    // Normalize text before cache lookup
    final key = text.toLowerCase().trim();

    // Check cache first (common expense descriptions repeat)
    if (_cache.containsKey(key)) return _cache[key]!;

    // Run AI inference
    final result = await _pipeline.categorize(text);

    // Cache result for future calls with the same text
    _cache[key] = result;

    // In production: persist cache to Hive/Isar so it survives app restart
    return result;
  }
}

// Result: "Lunch at Warteg" is categorized once, cached forever.
// All future instances of the same description = instant from cache.'''),

          const SizedBox(height: 16),
          _card(color: Colors.orange.shade50, child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• On-device = offline + privacy. Cloud = smarter + no storage'),
              Text('• RAG grounds LLM answers in your own data → no hallucination'),
              Text('• Embedding search = semantic similarity without running a full LLM'),
              Text('• Hybrid pipeline: rules → TFLite → cloud LLM (escalate on low confidence)'),
              Text('• Cache AI results — same input usually = same output'),
              Text('• Always show confidence + allow user corrections (AI is not perfect)'),
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
