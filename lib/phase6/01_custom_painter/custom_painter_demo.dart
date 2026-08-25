/// Phase 6 — Topic 01: Custom Painter
///
/// Flutter provides [CustomPaint] + [CustomPainter] to draw anything on screen
/// using a low-level [Canvas] API — similar to Android's Canvas or HTML5 <canvas>.
///
/// When to use CustomPainter:
/// - Charts and graphs (bar, line, pie)
/// - Progress indicators with custom shapes
/// - Signatures / freehand drawing
/// - Complex background decorations that widgets can't express
///
/// Key concepts covered:
/// 1. [CustomPaint] widget — the host that owns the canvas layer
/// 2. [CustomPainter] class — you override [paint] and [shouldRepaint]
/// 3. [Canvas] methods — drawLine, drawCircle, drawArc, drawPath, drawRect
/// 4. [Paint] object — controls color, stroke width, style (fill vs stroke)
/// 5. [Path] — build complex shapes from line segments and arcs
/// 6. [shouldRepaint] — optimization: only redraw when data actually changes
///
/// How to run this topic independently:
/// ```bash
/// flutter run -t lib/phase6/main_phase6.dart
/// ```

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Standalone entry point so this file can be run directly:
/// ```bash
/// flutter run -t phase6/01_custom_painter/custom_painter_demo.dart
/// ```
void main() => runApp(_StandaloneApp());

/// Minimal app wrapper used only when running this file directly.
class _StandaloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CustomPainterDemo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const CustomPainterDemo(),
    );
  }
}


/// Demo screen that showcases three distinct CustomPainter examples.
class CustomPainterDemo extends StatefulWidget {
  const CustomPainterDemo({super.key});

  @override
  State<CustomPainterDemo> createState() => _CustomPainterDemoState();
}

class _CustomPainterDemoState extends State<CustomPainterDemo>
    with SingleTickerProviderStateMixin {
  // ── Animation for the animated arc ──────────────────────────────────────
  late final AnimationController _controller;
  late final Animation<double> _progressAnim;

  // ── Data for the bar chart (0.0 – 1.0 normalized) ───────────────────────
  final List<double> _barValues = [0.4, 0.75, 0.55, 0.9, 0.3, 0.65];
  final List<String> _barLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void initState() {
    super.initState();
    // Animate from 0 → 1 over 2 seconds, then reverse continuously.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _progressAnim = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Always dispose controllers to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('01 — Custom Painter'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Section 1: Basic shapes ──────────────────────────────────────
          _SectionHeader(
            title: '1. Basic Shapes',
            subtitle: 'drawLine, drawCircle, drawRect, drawPath',
            color: Colors.orange,
          ),
          const SizedBox(height: 8),
          _DemoCard(
            child: CustomPaint(
              // Size of the drawing area
              size: const Size(double.infinity, 160),
              painter: _BasicShapesPainter(),
            ),
          ),
          const SizedBox(height: 8),
          _CodeSnippet('''
class _BasicShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke; // outline only

    // Draw a rectangle
    canvas.drawRect(Rect.fromLTWH(10, 10, 80, 60), paint);

    // Draw a circle (filled)
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(200, 40), 30, paint);

    // Draw a custom Path (triangle)
    final path = Path()
      ..moveTo(300, 70)
      ..lineTo(350, 10)
      ..lineTo(400, 70)
      ..close(); // automatically connects back to moveTo
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BasicShapesPainter old) => false; // static — never repaint
}'''),

          const SizedBox(height: 24),

          // ── Section 2: Animated progress arc ────────────────────────────
          _SectionHeader(
            title: '2. Animated Progress Arc',
            subtitle: 'drawArc + AnimationController',
            color: Colors.deepOrange,
          ),
          const SizedBox(height: 8),
          _DemoCard(
            child: AnimatedBuilder(
              animation: _progressAnim,
              builder: (_, __) => CustomPaint(
                size: const Size(double.infinity, 180),
                painter: _ProgressArcPainter(progress: _progressAnim.value),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _CodeSnippet('''
class _ProgressArcPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  const _ProgressArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 60.0;
    const strokeW = 12.0;
    const startAngle = -math.pi / 2; // 12 o\'clock

    // Background track
    canvas.drawCircle(center, radius,
        Paint()..color = Colors.grey.shade200
               ..strokeWidth = strokeW
               ..style = PaintingStyle.stroke);

    // Foreground progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * math.pi * progress, // sweep angle proportional to progress
      false,                  // useCenter: false = arc, not pie slice
      Paint()..color = Colors.deepOrange
             ..strokeWidth = strokeW
             ..style = PaintingStyle.stroke
             ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ProgressArcPainter old) => old.progress != progress;
}'''),

          const SizedBox(height: 24),

          // ── Section 3: Bar chart ─────────────────────────────────────────
          _SectionHeader(
            title: '3. Bar Chart',
            subtitle: 'Custom chart drawn entirely with canvas.drawRect',
            color: Colors.indigo,
          ),
          const SizedBox(height: 8),
          _DemoCard(
            child: CustomPaint(
              size: const Size(double.infinity, 180),
              painter: _BarChartPainter(
                values: _barValues,
                labels: _barLabels,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _CodeSnippet('''
class _BarChartPainter extends CustomPainter {
  final List<double> values;  // normalized 0.0 – 1.0
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 20.0;
    final barWidth = (size.width - padding * 2) / values.length * 0.6;
    final gap = (size.width - padding * 2) / values.length * 0.4;
    final maxHeight = size.height - 40; // leave room for labels

    for (var i = 0; i < values.length; i++) {
      final x = padding + i * (barWidth + gap);
      final barH = values[i] * maxHeight;
      final rect = Rect.fromLTWH(x, size.height - barH - 20, barWidth, barH);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()..color = Colors.indigo.withOpacity(0.7),
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => old.values != values;
}'''),

          const SizedBox(height: 24),

          // ── Key takeaways ────────────────────────────────────────────────
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Key Takeaways',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• shouldRepaint decides if the canvas redraws — '
                      'return true only when the data that affects the drawing actually changed'),
                  Text('• PaintingStyle.fill = solid, PaintingStyle.stroke = outline only'),
                  Text('• drawArc angles are in radians. Full circle = 2π'),
                  Text('• Wrap in AnimatedBuilder to animate without rebuilding the whole tree'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

/// Draws three simple shapes: rect, circle, triangle.
class _BasicShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Rectangle outline
    canvas.drawRect(
      const Rect.fromLTWH(20, 20, 100, 70),
      paint,
    );

    // Filled circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      40,
      Paint()..color = Colors.orangeAccent.withOpacity(0.4),
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      40,
      paint,
    );

    // Triangle via Path
    final trianglePaint = Paint()
      ..color = Colors.deepOrange
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width - 30, size.height - 10)
      ..lineTo(size.width - 100, size.height - 10)
      ..lineTo(size.width - 65, 20)
      ..close();

    canvas.drawPath(path, trianglePaint);
  }

  /// Returns false because this painter has no dynamic data — no need to repaint.
  @override
  bool shouldRepaint(_BasicShapesPainter old) => false;
}

/// Draws a circular arc to represent a progress value.
class _ProgressArcPainter extends CustomPainter {
  final double progress; // expected range: 0.0 → 1.0

  const _ProgressArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 60.0;
    const strokeW = 14.0;
    // Start angle: -π/2 means 12 o'clock (top of the circle).
    // Without this offset, arcs start at the 3 o'clock position.
    const startAngle = -math.pi / 2;

    // ── Background track (full circle) ──────────────────────────────────
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.grey.shade200
        ..strokeWidth = strokeW
        ..style = PaintingStyle.stroke,
    );

    // ── Progress arc ─────────────────────────────────────────────────────
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * math.pi * progress, // sweeps proportionally
      false, // useCenter=false draws an open arc, not a pie slice
      Paint()
        ..color = Colors.deepOrange
        ..strokeWidth = strokeW
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round, // rounded endpoints look nicer
    );

    // ── Percentage text in the center ────────────────────────────────────
    final pct = '${(progress * 100).toInt()}%';
    final tp = TextPainter(
      text: TextSpan(
        text: pct,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.deepOrange,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // drawText via TextPainter.paint, centered on the arc
    tp.paint(
      canvas,
      center - Offset(tp.width / 2, tp.height / 2),
    );
  }

  /// Only repaint when [progress] actually changes.
  @override
  bool shouldRepaint(_ProgressArcPainter old) => old.progress != progress;
}

/// Draws a simple vertical bar chart.
class _BarChartPainter extends CustomPainter {
  final List<double> values; // 0.0 → 1.0 normalized heights
  final List<String> labels;

  const _BarChartPainter({required this.values, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 16.0;
    const labelHeight = 20.0;
    final usableWidth = size.width - padding * 2;
    final usableHeight = size.height - labelHeight;
    final slotWidth = usableWidth / values.length;
    final barWidth = slotWidth * 0.55;

    final barPaint = Paint()..color = Colors.indigo.shade400;
    final textStyle = const TextStyle(fontSize: 10, color: Colors.black54);

    for (var i = 0; i < values.length; i++) {
      final barH = values[i] * usableHeight;
      final x = padding + i * slotWidth + (slotWidth - barWidth) / 2;
      final y = usableHeight - barH;

      // Bar rect with rounded top corners
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, y, barWidth, barH),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        barPaint,
      );

      // Day label below each bar
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x + (barWidth - tp.width) / 2, usableHeight + 4),
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.values != values || old.labels != labels;
}

// ── Reusable helper widgets ────────────────────────────────────────────────

/// Section title + subtitle used across all topics.
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

/// Card wrapper that gives a clean border around a demo widget.
class _DemoCard extends StatelessWidget {
  final Widget child;
  const _DemoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(8),
      child: child,
    );
  }
}

/// Displays a code snippet in a monospace scrollable block.
class _CodeSnippet extends StatelessWidget {
  final String code;
  const _CodeSnippet(this.code);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          code,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: Color(0xFFCDD6F4),
          ),
        ),
      ),
    );
  }
}
