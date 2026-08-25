/// Phase 10.7 — Mini Project: Smart Scanner
///
/// Combines ML Kit OCR + TFLite classifier into a practical receipt scanner:
/// - Photograph a receipt → OCR extracts the text
/// - TFLite classifies the expense category from the text
/// - Amount is parsed with regex
/// - User can correct the category if the AI got it wrong
import 'package:flutter/material.dart';

void main() => runApp(const SmartScannerApp());

class SmartScannerApp extends StatelessWidget {
  const SmartScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange), useMaterial3: true),
      home: const SmartScannerScreen(),
    );
  }
}

// ── Domain ─────────────────────────────────────────────────────────────────────

enum ExpenseCategory { food, transport, housing, health, entertainment, shopping, education, other }

extension ExpenseCategoryX on ExpenseCategory {
  String get label => name[0].toUpperCase() + name.substring(1);
  String get emoji => switch (this) {
    ExpenseCategory.food          => '🍔',
    ExpenseCategory.transport     => '🚗',
    ExpenseCategory.housing       => '🏠',
    ExpenseCategory.health        => '💊',
    ExpenseCategory.entertainment => '🎬',
    ExpenseCategory.shopping      => '🛍️',
    ExpenseCategory.education     => '📚',
    ExpenseCategory.other         => '📦',
  };
}

class ScanResult {
  final String rawText;
  final ExpenseCategory category;
  final double confidence;
  final double? amount;
  final bool userCorrected;

  const ScanResult({
    required this.rawText,
    required this.category,
    required this.confidence,
    required this.amount,
    this.userCorrected = false,
  });

  ScanResult copyWithCategory(ExpenseCategory newCategory) => ScanResult(
    rawText: rawText, category: newCategory,
    confidence: 1.0, amount: amount, userCorrected: true,
  );
}

// ── Screen ──────────────────────────────────────────────────────────────────────

class SmartScannerScreen extends StatefulWidget {
  const SmartScannerScreen({super.key});
  @override
  State<SmartScannerScreen> createState() => _SmartScannerScreenState();
}

class _SmartScannerScreenState extends State<SmartScannerScreen> {
  ScanResult? _result;
  bool _scanning = false;
  final List<ScanResult> _history = [];

  // Simulated scan pipeline: OCR → classify → parse amount
  Future<void> _scan() async {
    setState(() { _scanning = true; _result = null; });

    // Step 1: Simulate camera capture + OCR (ML Kit TextRecognizer)
    await Future.delayed(const Duration(milliseconds: 600));
    const rawText = 'WARUNG MAKAN PAK BUDI\n'
        'Jl. Sudirman No. 12\n'
        'Nasi Goreng Spesial  Rp 35.000\n'
        'Es Teh Manis          Rp 5.000\n'
        'Air Mineral           Rp 3.000\n'
        '----------------------------\n'
        'TOTAL               Rp 43.000\n'
        'CASH                Rp 50.000\n'
        'KEMBALIAN           Rp 7.000';

    // Step 2: Simulate TFLite classification (text → category)
    await Future.delayed(const Duration(milliseconds: 300));
    const category = ExpenseCategory.food;
    const confidence = 0.96;

    // Step 3: Simulate regex amount parsing
    final amountMatch = RegExp(r'TOTAL\s+Rp\s*([\d.]+)').firstMatch(rawText);
    final amount = amountMatch != null
        ? double.tryParse(amountMatch.group(1)!.replaceAll('.', ''))
        : null;

    setState(() {
      _scanning = false;
      _result = ScanResult(rawText: rawText, category: category, confidence: confidence, amount: amount);
    });
  }

  void _correctCategory(ExpenseCategory newCategory) {
    if (_result == null) return;
    setState(() => _result = _result!.copyWithCategory(newCategory));
  }

  void _saveResult() {
    if (_result == null) return;
    setState(() {
      _history.insert(0, _result!);
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Scanner'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: _result == null && !_scanning
          ? _ScanPrompt(onScan: _scan, history: _history)
          : _scanning
              ? const _ScanningIndicator()
              : _ScanResultView(
                  result: _result!,
                  onCorrect: _correctCategory,
                  onSave: _saveResult,
                  onRescan: _scan,
                ),
    );
  }
}

// ── UI Components ──────────────────────────────────────────────────────────────

class _ScanPrompt extends StatelessWidget {
  final VoidCallback onScan;
  final List<ScanResult> history;

  const _ScanPrompt({required this.onScan, required this.history});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          const Icon(Icons.document_scanner, size: 80, color: Colors.deepOrange),
          const SizedBox(height: 16),
          const Text('Smart Receipt Scanner', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Photograph a receipt to automatically extract the amount and categorize the expense.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              minimumSize: const Size(double.infinity, 52),
            ),
            onPressed: onScan,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Scan Receipt', style: TextStyle(fontSize: 16)),
          ),
          const Spacer(),
          if (history.isNotEmpty) ...[
            Align(alignment: Alignment.centerLeft, child: Text('Recent Scans', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700))),
            const SizedBox(height: 8),
            ...history.take(3).map((r) => ListTile(
              dense: true,
              leading: Text(r.category.emoji, style: const TextStyle(fontSize: 20)),
              title: Text(r.category.label),
              trailing: r.amount != null ? Text('Rp ${r.amount!.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)) : null,
              subtitle: r.userCorrected ? const Text('✏️ User corrected', style: TextStyle(fontSize: 11, color: Colors.orange)) : null,
            )),
          ],
        ],
      ),
    );
  }
}

class _ScanningIndicator extends StatelessWidget {
  const _ScanningIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Scanning receipt...', style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text('OCR → TFLite Classifier → Amount Parser', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ScanResultView extends StatelessWidget {
  final ScanResult result;
  final ValueChanged<ExpenseCategory> onCorrect;
  final VoidCallback onSave;
  final VoidCallback onRescan;

  const _ScanResultView({
    required this.result,
    required this.onCorrect,
    required this.onSave,
    required this.onRescan,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── AI Result card ─────────────────────────────────────────────
          Card(
            color: Colors.deepOrange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(result.category.emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(result.category.label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(result.userCorrected ? '✏️ Manually corrected' : 'AI confidence: ${(result.confidence * 100).toStringAsFixed(0)}%',
                          style: TextStyle(fontSize: 12, color: result.userCorrected ? Colors.orange : Colors.grey)),
                    ]),
                    const Spacer(),
                    if (result.amount != null) Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      const Text('Amount', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text('Rp ${result.amount!.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                    ]),
                  ]),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Correct category if AI was wrong ───────────────────────────
          const Text('Correct category if needed:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ExpenseCategory.values.map((cat) => ChoiceChip(
              label: Text('${cat.emoji} ${cat.label}'),
              selected: result.category == cat,
              onSelected: (_) => onCorrect(cat),
              visualDensity: VisualDensity.compact,
            )).toList(),
          ),

          const SizedBox(height: 16),

          // ── Raw OCR text ───────────────────────────────────────────────
          const Text('OCR Output:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(8)),
            child: SelectableText(result.rawText, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCDD6F4))),
          ),

          const SizedBox(height: 20),

          // ── Actions ────────────────────────────────────────────────────
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: onRescan,
              icon: const Icon(Icons.replay),
              label: const Text('Rescan'),
            )),
            const SizedBox(width: 10),
            Expanded(child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.deepOrange),
              onPressed: onSave,
              icon: const Icon(Icons.save),
              label: const Text('Save Expense'),
            )),
          ]),
        ],
      ),
    );
  }
}
