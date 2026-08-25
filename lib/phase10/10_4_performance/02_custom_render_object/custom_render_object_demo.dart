/// Phase 10.4 — Topic 02: Custom RenderObject
///
/// Every Flutter widget ultimately becomes a RenderObject that handles
/// layout (how big am I? where do my children go?) and painting (draw me).
///
/// You only need a custom RenderObject when:
/// - CustomPainter is not enough (e.g. you need custom layout)
/// - You need custom hit testing
/// - You are building a new layout primitive (like Row/Column but custom)
/// - Maximum performance — RenderObject bypasses the Widget rebuild overhead
///
/// Key concepts covered:
/// 1. The three Flutter trees: Widget → Element → RenderObject
/// 2. RenderBox — the concrete subclass for 2D box layouts
/// 3. performLayout() — determine your own size + position children
/// 4. paint() — draw on the canvas
/// 5. hitTestChildren() / hitTestSelf() — handle pointer events
/// 6. LeafRenderObjectWidget vs SingleChildRenderObjectWidget vs MultiChildRenderObjectWidget
/// 7. When to use CustomPainter vs RenderObject
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom RenderObject',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange), useMaterial3: true),
      home: const CustomRenderObjectDemo(),
    );
  }
}

class CustomRenderObjectDemo extends StatelessWidget {
  const CustomRenderObjectDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('02 — Custom RenderObject'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            color: Colors.orange.shade50,
            child: const Text(
              'CustomPainter: draws on an existing canvas, participates in the normal layout.\n\n'
              'RenderObject: IS the layout system. Controls its own size, positions children, '
              'draws itself — the lowest level possible.\n\n'
              'Use CustomPainter for charts/effects. Use RenderObject for custom layout primitives.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),

          // ── Live demo: custom ring layout ──────────────────────────────
          _header('Live Demo — RingLayout', Colors.orange),
          const Text('A custom layout that arranges children in a circle. '
              'Impossible with Row/Column — only possible with a RenderObject.',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              height: 220,
              width: 220,
              child: RingLayout(
                radius: 80,
                children: [
                  _colorDot(Colors.red),
                  _colorDot(Colors.orange),
                  _colorDot(Colors.yellow),
                  _colorDot(Colors.green),
                  _colorDot(Colors.blue),
                  _colorDot(Colors.purple),
                ],
              ),
            ),
          ),
          _code(r'''
// Full RenderObject for a ring layout — positions children in a circle

// 1. The Widget layer
class RingLayout extends MultiChildRenderObjectWidget {
  final double radius;
  const RingLayout({required this.radius, required super.children, super.key});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RingRenderBox(radius: radius);

  @override
  void updateRenderObject(BuildContext context, _RingRenderBox renderObject) {
    renderObject.radius = radius;
  }
}

// 2. Required parentData for MultiChild layouts
class _RingParentData extends ContainerBoxParentData<RenderBox> {}

// 3. The RenderObject
class _RingRenderBox extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _RingParentData>,
         RenderBoxContainerDefaultsMixin<RenderBox, _RingParentData> {

  double _radius;
  _RingRenderBox({required double radius}) : _radius = radius;

  set radius(double v) {
    if (_radius == v) return;
    _radius = v;
    markNeedsLayout();  // tell Flutter to re-layout
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _RingParentData) {
      child.parentData = _RingParentData();
    }
  }

  @override
  void performLayout() {
    // We take as much space as given
    size = constraints.biggest;
    final center = Offset(size.width / 2, size.height / 2);

    // Position each child evenly around the ring
    var child = firstChild;
    var i = 0;
    final count = childCount;

    while (child != null) {
      final parentData = child.parentData as _RingParentData;
      final angle = 2 * math.pi * i / count - math.pi / 2;

      // Layout child with loose constraints (it determines its own size)
      child.layout(constraints.loosen(), parentUsesSize: true);

      // Position: center of ring + offset along the angle
      parentData.offset = Offset(
        center.dx + _radius * math.cos(angle) - child.size.width / 2,
        center.dy + _radius * math.sin(angle) - child.size.height / 2,
      );

      child = parentData.nextSibling;
      i++;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Draw the ring guide line (optional)
    final center = offset + Offset(size.width / 2, size.height / 2);
    context.canvas.drawCircle(center, _radius,
        Paint()..color = Colors.grey.shade200..style = PaintingStyle.stroke..strokeWidth = 2);

    // Paint all children at their computed positions
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}'''),

          const SizedBox(height: 20),

          // ── When to use what ────────────────────────────────────────────
          _header('When to Use What', Colors.teal),
          _card(
            color: Colors.teal.shade50,
            child: Table(
              columnWidths: const {0: FlexColumnWidth(1.5), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
              border: TableBorder.all(color: Colors.teal.shade200),
              children: [
                _tableRow(['Use case', 'CustomPainter', 'RenderObject'], header: true),
                _tableRow(['Draw a chart', '✅ Simpler', '⚠️ Overkill']),
                _tableRow(['Custom layout', '❌ Can\'t', '✅ Required']),
                _tableRow(['Hit testing', '⚠️ Limited', '✅ Full control']),
                _tableRow(['Performance', '✅ Good', '✅✅ Best']),
                _tableRow(['Learning curve', '✅ Easy', '⚠️ Hard']),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _card(
            color: Colors.orange.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• 3 trees: Widget (blueprint) → Element (lifecycle) → RenderObject (layout+paint)'),
                Text('• RenderBox.performLayout() sets size and positions children via parentData.offset'),
                Text('• markNeedsLayout() triggers re-layout; markNeedsPaint() triggers repaint only'),
                Text('• Use LeafRenderObjectWidget for no children, MultiChild for many children'),
                Text('• 99% of custom drawing → CustomPainter. Custom layout → RenderObject'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorDot(Color color) => Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  TableRow _tableRow(List<String> cells, {bool header = false}) => TableRow(
        decoration: header ? BoxDecoration(color: Colors.teal.shade100) : null,
        children: cells.map((c) => Padding(
              padding: const EdgeInsets.all(6),
              child: Text(c, style: TextStyle(fontSize: 11, fontWeight: header ? FontWeight.bold : FontWeight.normal)),
            )).toList(),
      );
}

// ── RingLayout implementation ──────────────────────────────────────────────────

class RingLayout extends MultiChildRenderObjectWidget {
  final double radius;
  const RingLayout({required this.radius, required super.children, super.key});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RingRenderBox(radius: radius);

  @override
  void updateRenderObject(BuildContext context, _RingRenderBox renderObject) =>
      renderObject.radius = radius;
}

class _RingParentData extends ContainerBoxParentData<RenderBox> {}

class _RingRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _RingParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _RingParentData> {
  double _radius;
  _RingRenderBox({required double radius}) : _radius = radius;

  set radius(double v) {
    if (_radius == v) return;
    _radius = v;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _RingParentData) {
      child.parentData = _RingParentData();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    final cx = size.width / 2;
    final cy = size.height / 2;
    var child = firstChild;
    var i = 0;
    final count = childCount;
    while (child != null) {
      final pd = child.parentData as _RingParentData;
      final angle = 2 * math.pi * i / count - math.pi / 2;
      child.layout(constraints.loosen(), parentUsesSize: true);
      pd.offset = Offset(
        cx + _radius * math.cos(angle) - child.size.width / 2,
        cy + _radius * math.sin(angle) - child.size.height / 2,
      );
      child = pd.nextSibling;
      i++;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final center = offset + Offset(size.width / 2, size.height / 2);
    context.canvas.drawCircle(
      center, _radius,
      Paint()..color = Colors.grey.shade200..style = PaintingStyle.stroke..strokeWidth = 2,
    );
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

Widget _header(String t, Color c) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(t, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: c)),
    );
Widget _code(String code) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(6)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(code, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCDD6F4))),
      ),
    );
Widget _card({required Color color, required Widget child}) =>
    Card(color: color, child: Padding(padding: const EdgeInsets.all(12), child: child));
