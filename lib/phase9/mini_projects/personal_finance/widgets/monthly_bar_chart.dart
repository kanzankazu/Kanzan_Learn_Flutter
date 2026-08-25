/// Custom Painter: MonthlyBarChart
///
/// Draws a grouped bar chart showing income (green) vs expense (red)
/// for the last 6 months. Demonstrates Phase 6 Custom Painter skills.
///
/// Each bar pair represents one month. The height of each bar is
/// proportional to the maximum value across all months.
import 'package:flutter/material.dart';

/// A bar chart widget showing 6 months of income vs expense data.
///
/// [data] — list of (income, expense) tuples, oldest to newest.
class MonthlyBarChart extends StatelessWidget {
  final List<(double income, double expense)> data;

  const MonthlyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: CustomPaint(
        size: const Size(double.infinity, 140),
        painter: _BarChartPainter(
          data: data,
          incomeColor: Colors.green.shade400,
          expenseColor: Colors.red.shade300,
        ),
      ),
    );
  }
}

/// Custom painter that draws the grouped bar chart.
class _BarChartPainter extends CustomPainter {
  final List<(double income, double expense)> data;
  final Color incomeColor;
  final Color expenseColor;

  const _BarChartPainter({
    required this.data,
    required this.incomeColor,
    required this.expenseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Find the maximum value across all income+expense figures
    // to use as the full height reference.
    final maxValue = data.fold(0.0, (max, pair) {
      final m = pair.$1 > pair.$2 ? pair.$1 : pair.$2;
      return m > max ? m : max;
    });

    if (maxValue == 0) return;

    const labelHeight = 16.0;   // space for month labels at the bottom
    final chartHeight = size.height - labelHeight;
    final slotWidth = size.width / data.length;
    const barGap = 2.0;
    final barWidth = (slotWidth - 12) / 2;

    // Month abbreviations — last 6 months ending at the current month
    const monthNames = ['Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];

    final incomePaint = Paint()
      ..color = incomeColor
      ..style = PaintingStyle.fill;
    final expensePaint = Paint()
      ..color = expenseColor
      ..style = PaintingStyle.fill;
    final labelStyle = TextStyle(
      fontSize: 9,
      color: Colors.grey.shade600,
    );

    for (var i = 0; i < data.length; i++) {
      final slotLeft = i * slotWidth;
      final incomeH = (data[i].$1 / maxValue) * chartHeight * 0.9;
      final expenseH = (data[i].$2 / maxValue) * chartHeight * 0.9;

      // Income bar (left of the pair)
      final incomeLeft = slotLeft + 6;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              incomeLeft, chartHeight - incomeH, barWidth, incomeH),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        ),
        incomePaint,
      );

      // Expense bar (right of the pair)
      final expenseLeft = incomeLeft + barWidth + barGap;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              expenseLeft, chartHeight - expenseH, barWidth, expenseH),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        ),
        expensePaint,
      );

      // Month label centered below the bar pair
      final label = i < monthNames.length ? monthNames[i] : '';
      final tp = TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(slotLeft + (slotWidth - tp.width) / 2, chartHeight + 2),
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => old.data != data;
}
