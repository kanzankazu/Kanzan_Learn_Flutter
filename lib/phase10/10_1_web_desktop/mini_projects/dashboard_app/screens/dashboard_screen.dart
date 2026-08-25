/// Dashboard Screen — Admin Dashboard mini project
///
/// Shows KPI cards, a bar chart (Custom Painter), and recent activity table.
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The main overview screen with KPIs, charts, and recent activity.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        // On very wide screens, cap content and center it
        final contentWidth = constraints.maxWidth.clamp(0.0, 1400.0);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SizedBox(
              width: contentWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Page header ──────────────────────────────────────
                  Text('Overview',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Text('August 2026 — all figures in IDR',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 20),

                  // ── KPI cards ─────────────────────────────────────────
                  _KpiRow(constraints: constraints),
                  const SizedBox(height: 24),

                  // ── Charts row ────────────────────────────────────────
                  _buildChartsRow(context, constraints),
                  const SizedBox(height: 24),

                  // ── Recent activity table ─────────────────────────────
                  _RecentActivityTable(),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildChartsRow(BuildContext context, BoxConstraints constraints) {
    // Single column on narrow screens, two columns on wide
    if (constraints.maxWidth < 800) {
      return Column(
        children: [
          _RevenueChart(),
          const SizedBox(height: 16),
          _TopCategoriesChart(),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _RevenueChart()),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _TopCategoriesChart()),
      ],
    );
  }
}

// ── KPI Row ────────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  final BoxConstraints constraints;
  const _KpiRow({required this.constraints});

  static const _kpis = [
    _Kpi('Total Revenue', 'Rp 48.2M', '+12.5%', Icons.attach_money, Color(0xFF2563EB), true),
    _Kpi('Active Users', '2,847', '+8.3%', Icons.people, Color(0xFF16A34A), true),
    _Kpi('New Orders', '384', '+5.1%', Icons.shopping_cart, Color(0xFFD97706), true),
    _Kpi('Avg Order Value', 'Rp 125K', '-2.1%', Icons.trending_up, Color(0xFFDC2626), false),
  ];

  @override
  Widget build(BuildContext context) {
    // Responsive grid: 1 col on phone, 2 on tablet, 4 on desktop
    final cols = constraints.maxWidth < 600
        ? 1
        : constraints.maxWidth < 900
            ? 2
            : 4;
    final itemW =
        (constraints.maxWidth - (cols - 1) * 12) / cols;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _kpis
          .map((kpi) => SizedBox(width: itemW, child: _KpiCard(kpi: kpi)))
          .toList(),
    );
  }
}

class _Kpi {
  final String label;
  final String value;
  final String change;
  final IconData icon;
  final Color color;
  final bool positive;

  const _Kpi(this.label, this.value, this.change, this.icon, this.color, this.positive);
}

class _KpiCard extends StatefulWidget {
  final _Kpi kpi;
  const _KpiCard({required this.kpi});

  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered
                ? widget.kpi.color
                : Colors.grey.shade200,
          ),
          boxShadow: _hovered
              ? [BoxShadow(color: widget.kpi.color.withAlpha(40), blurRadius: 12)]
              : [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.kpi.label,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: widget.kpi.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(widget.kpi.icon,
                      color: widget.kpi.color, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.kpi.value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  widget.kpi.positive
                      ? Icons.trending_up
                      : Icons.trending_down,
                  size: 14,
                  color:
                      widget.kpi.positive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(widget.kpi.change,
                    style: TextStyle(
                        fontSize: 12,
                        color: widget.kpi.positive
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w500)),
                const SizedBox(width: 4),
                const Text('vs last month',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Revenue Bar Chart ──────────────────────────────────────────────────────────

class _RevenueChart extends StatelessWidget {
  static const _data = [38.2, 41.5, 35.8, 44.1, 39.6, 48.2]; // in millions
  static const _months = ['Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Monthly Revenue (Rp M)',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            const Text('Last 6 months',
                style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: CustomPaint(
                size: const Size(double.infinity, 180),
                painter: _RevenueBarPainter(
                  data: _data,
                  labels: _months,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueBarPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color color;

  const _RevenueBarPainter({
    required this.data,
    required this.labels,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const labelH = 20.0;
    final chartH = size.height - labelH;
    final maxVal = data.reduce(math.max);
    final slotW = size.width / data.length;
    final barW = slotW * 0.5;

    final barPaint = Paint()..color = color;
    final highlightPaint = Paint()..color = color.withAlpha(180);
    final textStyle = TextStyle(fontSize: 10, color: Colors.grey.shade600);

    for (var i = 0; i < data.length; i++) {
      final barH = (data[i] / maxVal) * chartH * 0.9;
      final x = i * slotW + (slotW - barW) / 2;
      final y = chartH - barH;

      // Highlight current month
      final paint = i == data.length - 1 ? barPaint : highlightPaint;

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, y, barW, barH),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        paint,
      );

      // Value label on top
      final valTp = TextPainter(
        text: TextSpan(
          text: data[i].toStringAsFixed(1),
          style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valTp.paint(canvas, Offset(x + (barW - valTp.width) / 2, y - 14));

      // Month label
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
          canvas, Offset(x + (barW - tp.width) / 2, chartH + 4));
    }
  }

  @override
  bool shouldRepaint(_RevenueBarPainter old) => false;
}

// ── Top Categories Donut Chart ─────────────────────────────────────────────────

class _TopCategoriesChart extends StatelessWidget {
  static const _categories = [
    ('Electronics', 38.0, Color(0xFF2563EB)),
    ('Fashion', 24.0, Color(0xFF16A34A)),
    ('Food', 18.0, Color(0xFFD97706)),
    ('Books', 12.0, Color(0xFF9333EA)),
    ('Other', 8.0, Color(0xFF94A3B8)),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Categories',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 16),
            Center(
              child: CustomPaint(
                size: const Size(140, 140),
                painter: _DonutPainter(
                  slices: _categories
                      .map((c) => (c.$2, c.$3))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ..._categories.map((c) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: c.$3, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(c.$1,
                              style: const TextStyle(fontSize: 12))),
                      Text('${c.$2.toStringAsFixed(0)}%',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<(double value, Color color)> slices;
  const _DonutPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold(0.0, (s, e) => s + e.$1);
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 4;
    var startAngle = -math.pi / 2;

    for (final (value, color) in slices) {
      final sweep = 2 * math.pi * (value / total);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        startAngle, sweep, true,
        Paint()..color = color,
      );
      startAngle += sweep;
    }
    // Donut hole
    canvas.drawCircle(center, r * 0.55, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_DonutPainter old) => false;
}

// ── Recent Activity Table ──────────────────────────────────────────────────────

class _RecentActivityTable extends StatelessWidget {
  static const _rows = [
    ('ORD-1847', 'Budi Santoso', 'Electronics', 'Rp 2.4M', 'Completed'),
    ('ORD-1846', 'Siti Rahayu', 'Fashion', 'Rp 450K', 'Processing'),
    ('ORD-1845', 'Ahmad Fauzi', 'Food', 'Rp 120K', 'Completed'),
    ('ORD-1844', 'Dewi Lestari', 'Books', 'Rp 85K', 'Cancelled'),
    ('ORD-1843', 'Eko Prasetyo', 'Electronics', 'Rp 5.8M', 'Processing'),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Orders',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.open_in_new, size: 14),
                  label: const Text('View all',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
              },
              children: [
                // Header row
                TableRow(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(4)),
                  children: ['Order ID', 'Customer', 'Category', 'Amount', 'Status']
                      .map((h) => Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            child: Text(h,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                          ))
                      .toList(),
                ),
                // Data rows
                ..._rows.map((row) => TableRow(
                      children: [
                        _cell(row.$1, mono: true),
                        _cell(row.$2),
                        _cell(row.$3),
                        _cell(row.$4, bold: true),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 4),
                          child: _StatusBadge(status: row.$5),
                        ),
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(String text, {bool mono = false, bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Text(text,
            style: TextStyle(
                fontSize: 12,
                fontFamily: mono ? 'monospace' : null,
                fontWeight:
                    bold ? FontWeight.bold : FontWeight.normal)),
      );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      'Completed' => (Colors.green.shade700, Colors.green.shade50),
      'Processing' => (Colors.blue.shade700, Colors.blue.shade50),
      'Cancelled' => (Colors.red.shade700, Colors.red.shade50),
      _ => (Colors.grey.shade700, Colors.grey.shade50),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(status,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
