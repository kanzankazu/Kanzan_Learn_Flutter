/// Analytics Screen — Personal Finance Manager
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../domain/entities/transaction.dart';
import '../widgets/amount_display.dart';

/// Shows spending analytics: donut chart breakdown + category ranking.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // Sample spending data per category this month
  static const _spendingData = [
    (TransactionCategory.food, 860000.0),
    (TransactionCategory.housing, 350000.0),
    (TransactionCategory.transport, 345000.0),
    (TransactionCategory.shopping, 220000.0),
    (TransactionCategory.entertainment, 410000.0),
    (TransactionCategory.health, 90000.0),
  ];

  static const _colors = [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFFF44336),
    Color(0xFF00BCD4),
  ];

  // Which slice is currently highlighted in the donut chart
  int? _highlightedIndex;

  @override
  Widget build(BuildContext context) {
    final total = _spendingData.fold(0.0, (s, e) => s + e.$2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Donut chart ─────────────────────────────────────────────────
          Text('August 2026 — Expense Breakdown',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Custom Painter donut chart + legend side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Donut chart
              GestureDetector(
                onTapDown: (details) {
                  // Detect which slice was tapped by converting local position to angle
                  final center = Offset(110, 110);
                  final dx = details.localPosition.dx - center.dx;
                  final dy = details.localPosition.dy - center.dy;
                  final distance = math.sqrt(dx * dx + dy * dy);
                  if (distance < 40 || distance > 110) {
                    setState(() => _highlightedIndex = null);
                    return;
                  }
                  var angle = math.atan2(dy, dx) + math.pi / 2;
                  if (angle < 0) angle += 2 * math.pi;
                  double cumulative = 0;
                  for (var i = 0; i < _spendingData.length; i++) {
                    cumulative += _spendingData[i].$2 / total;
                    if (angle / (2 * math.pi) < cumulative) {
                      setState(() => _highlightedIndex = i);
                      return;
                    }
                  }
                },
                child: CustomPaint(
                  size: const Size(220, 220),
                  painter: _DonutChartPainter(
                    data: _spendingData.map((e) => e.$2).toList(),
                    colors: _colors,
                    highlightedIndex: _highlightedIndex,
                    total: total,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < _spendingData.length; i++)
                      GestureDetector(
                        onTap: () => setState(() =>
                            _highlightedIndex =
                                _highlightedIndex == i ? null : i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _colors[i],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _spendingData[i].$1.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: _highlightedIndex == i
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Category ranking ─────────────────────────────────────────────
          Text('Category Breakdown',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          ...List.generate(_spendingData.length, (i) {
            final entry = _spendingData[i];
            final pct = entry.$2 / total;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(entry.$1.emoji,
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(entry.$1.label,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                        ),
                        AmountDisplay(
                          amount: entry.$2,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text('${(pct * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(_colors[i]),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Custom Painter that draws a donut (ring) chart.
///
/// Each slice represents one spending category. Tapping a slice
/// highlights it (drawn slightly larger).
class _DonutChartPainter extends CustomPainter {
  final List<double> data;
  final List<Color> colors;
  final int? highlightedIndex;
  final double total;

  const _DonutChartPainter({
    required this.data,
    required this.colors,
    required this.highlightedIndex,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const outerRadius = 95.0;
    const innerRadius = 42.0; // the "hole" in the donut
    const highlightBoost = 8.0;
    const startAngle = -math.pi / 2; // start at 12 o'clock

    var currentAngle = startAngle;

    for (var i = 0; i < data.length; i++) {
      final sweepAngle = 2 * math.pi * (data[i] / total);
      final isHighlighted = i == highlightedIndex;
      final radius = isHighlighted ? outerRadius + highlightBoost : outerRadius;

      // Draw the arc slice
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweepAngle,
        true, // useCenter: true = pie slice (we'll cut the center out)
        Paint()..color = colors[i % colors.length],
      );

      currentAngle += sweepAngle;
    }

    // Cut out the center to make it a donut
    canvas.drawCircle(
      center,
      innerRadius,
      Paint()..color = Colors.white,
    );

    // Center label: total amount
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Total\n',
            style: TextStyle(
                fontSize: 10, color: Colors.grey.shade600),
          ),
          TextSpan(
            text: 'Rp${(total / 1000000).toStringAsFixed(1)}M',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: innerRadius * 1.8);

    tp.paint(
      canvas,
      center - Offset(tp.width / 2, tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(_DonutChartPainter old) =>
      old.highlightedIndex != highlightedIndex || old.data != data;
}
