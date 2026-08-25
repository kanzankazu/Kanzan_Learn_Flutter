/// Phase 6 — Topic 03: Advanced Animation
///
/// Flutter has two animation layers:
/// - **Implicit** (Phase 2): AnimatedContainer, AnimatedOpacity — easy, auto-managed
/// - **Explicit** (this topic): AnimationController + Tween — full manual control
///
/// Use explicit animation when you need:
/// - Looping / reversing / stopping at a specific point
/// - Sequencing multiple animations (stagger)
/// - Listening to animation values to drive custom paint or physics
/// - Triggering animations from code, not from state changes
///
/// Key concepts covered:
/// 1. [AnimationController] — the clock; drives the animation from 0 → 1
/// 2. [Tween<T>] — maps the 0–1 range to an actual value range
/// 3. [CurvedAnimation] — applies an easing curve to the controller
/// 4. [AnimatedBuilder] — rebuilds only the subtree that reads the animation
/// 5. Staggered animation — multiple animations on the same controller with [Interval]
/// 6. [TweenSequence] — chain multiple tweens back-to-back
///
/// How to run:
/// ```bash
/// flutter run -t lib/phase6/main_phase6.dart
/// ```

import 'package:flutter/material.dart';

/// Standalone entry point so this file can be run directly:
/// ```bash
/// flutter run -t phase6/03_advanced_animation/advanced_animation_demo.dart
/// ```
void main() => runApp(_StandaloneApp());

/// Minimal app wrapper used only when running this file directly.
class _StandaloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdvancedAnimationDemo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AdvancedAnimationDemo(),
    );
  }
}


/// Demo screen showcasing three explicit animation examples.
class AdvancedAnimationDemo extends StatefulWidget {
  const AdvancedAnimationDemo({super.key});

  @override
  State<AdvancedAnimationDemo> createState() => _AdvancedAnimationDemoState();
}

class _AdvancedAnimationDemoState extends State<AdvancedAnimationDemo>
    with TickerProviderStateMixin {
  // ── Controller 1: basic tween demo ────────────────────────────────────────
  // AnimationController is the "clock" — it outputs a value from 0.0 to 1.0
  // over the specified duration. You need a TickerProvider (vsync) to tie it
  // to the screen's refresh rate — that's what TickerProviderStateMixin gives.
  late final AnimationController _basicController;
  late final Animation<double> _sizeAnim;
  late final Animation<Color?> _colorAnim;

  // ── Controller 2: curved animation demo ───────────────────────────────────
  late final AnimationController _curveController;
  String _selectedCurve = 'easeInOut';

  // ── Controller 3: stagger demo ─────────────────────────────────────────────
  // A single controller drives ALL staggered children.
  // Each child uses an Interval to pick its own slice of the 0–1 range.
  late final AnimationController _staggerController;
  late final List<Animation<double>> _staggerAnims;

  @override
  void initState() {
    super.initState();

    // ── Basic controller setup ───────────────────────────────────────────
    _basicController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Tween<double>: maps 0→1 to 60→140 (box size in pixels)
    _sizeAnim = Tween<double>(begin: 60, end: 140).animate(_basicController);

    // ColorTween: maps 0→1 to orange→deepPurple
    _colorAnim = ColorTween(begin: Colors.orange, end: Colors.deepPurple)
        .animate(_basicController);

    // ── Curved controller setup ──────────────────────────────────────────
    _curveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    // Initial curve is easeInOut — _CurvedAnimDemo reads _curves[_selectedCurve] directly.

    // ── Stagger controller setup ─────────────────────────────────────────
    // Duration longer than any single animation — the gap creates the "stagger".
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 5 items, each fades in over 0.4 of the total duration,
    // staggered by 0.15 each. Interval(begin, end) clips the controller range.
    _staggerAnims = List.generate(5, (i) {
      final start = i * 0.15; // 0.0, 0.15, 0.30, 0.45, 0.60
      final end = start + 0.40; // ends at 0.40, 0.55, 0.70, 0.85, 1.00
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _staggerController,
          // Interval restricts when this tween is active within the controller
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
  }

  /// Builds a [CurvedAnimation] for the curve demo — called when curve changes.
  Animation<double> _buildCurvedAnim(Curve curve) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _curveController, curve: curve),
    );
  }

  @override
  void dispose() {
    // ALWAYS dispose every controller. Forgetting this leaks the Ticker
    // which keeps ticking even after the widget is gone.
    _basicController.dispose();
    _curveController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  // ── Curve options for the demo ─────────────────────────────────────────────
  static const _curves = <String, Curve>{
    'linear': Curves.linear,
    'easeIn': Curves.easeIn,
    'easeOut': Curves.easeOut,
    'easeInOut': Curves.easeInOut,
    'bounceOut': Curves.bounceOut,
    'elasticOut': Curves.elasticOut,
    'decelerate': Curves.decelerate,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('03 — Advanced Animation'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Section 1: AnimationController + Tween ────────────────────
          _header('1. AnimationController + Tween',
              'Controller is the clock (0→1). Tween maps to real values.'),
          const SizedBox(height: 12),

          // AnimatedBuilder: only rebuilds the widget tree inside its builder,
          // not the whole State — much more efficient than calling setState().
          AnimatedBuilder(
            animation: _basicController,
            builder: (context, _) {
              return Center(
                child: Container(
                  width: _sizeAnim.value,  // 60 → 140
                  height: _sizeAnim.value,
                  decoration: BoxDecoration(
                    color: _colorAnim.value, // orange → deepPurple
                    borderRadius: BorderRadius.circular(_sizeAnim.value / 4),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.deepPurple),
                onPressed: () => _basicController.forward(),
                child: const Text('Forward'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _basicController.reverse(),
                child: const Text('Reverse'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _basicController.repeat(reverse: true),
                child: const Text('Repeat'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _codeSnippet('''
// 1. Create controller (needs TickerProviderStateMixin)
_controller = AnimationController(vsync: this, duration: 1.seconds);

// 2. Create tween — maps controller's 0→1 to your value range
_sizeAnim = Tween<double>(begin: 60, end: 140).animate(_controller);
_colorAnim = ColorTween(begin: Colors.orange, end: Colors.purple)
                .animate(_controller);

// 3. Consume in build via AnimatedBuilder
AnimatedBuilder(
  animation: _controller,
  builder: (ctx, _) => Container(
    width: _sizeAnim.value,
    color: _colorAnim.value,
  ),
);

// 4. Control playback
_controller.forward();          // play 0 → 1
_controller.reverse();          // play 1 → 0
_controller.repeat(reverse: true); // bounce forever'''),

          const SizedBox(height: 24),

          // ── Section 2: CurvedAnimation ────────────────────────────────
          _header('2. CurvedAnimation',
              'Wraps a controller with an easing curve. Try different curves!'),
          const SizedBox(height: 8),
          // Curve picker
          Wrap(
            spacing: 6,
            children: _curves.keys.map((name) {
              return ChoiceChip(
                label: Text(name, style: const TextStyle(fontSize: 11)),
                selected: _selectedCurve == name,
                onSelected: (_) {
                  setState(() {
                    _selectedCurve = name;
                  });
                  // Rebuild animation with selected curve then play it
                  final newAnim = _buildCurvedAnim(_curves[name]!);
                  _curveController.reset();
                  newAnim.addListener(() => setState(() {}));
                  _curveController.forward();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          _CurvedAnimDemo(
            controller: _curveController,
            curveName: _selectedCurve,
            curve: _curves[_selectedCurve]!,
            onRun: () {
              _curveController.reset();
              _curveController.forward();
            },
          ),
          const SizedBox(height: 8),
          _codeSnippet('''
// CurvedAnimation wraps the controller with a curve
final curved = CurvedAnimation(
  parent: _controller,
  curve: Curves.bounceOut,   // easing applied to 0→1 output
  reverseCurve: Curves.easeIn, // optional: different curve for reverse
);

// Then animate with the curved wrapper instead of the raw controller
_sizeAnim = Tween<double>(begin: 0, end: 200).animate(curved);'''),

          const SizedBox(height: 24),

          // ── Section 3: Staggered Animation ────────────────────────────
          _header('3. Staggered Animation',
              'One controller, multiple children, each delayed via Interval.'),
          const SizedBox(height: 8),
          // Each item slides in + fades in with a different delay
          ...List.generate(5, (i) {
            return AnimatedBuilder(
              animation: _staggerAnims[i],
              builder: (context, _) {
                final v = _staggerAnims[i].value; // 0 → 1
                return Opacity(
                  opacity: v,
                  child: Transform.translate(
                    // slides in from the left: starts at -80px, ends at 0
                    offset: Offset(-80 * (1 - v), 0),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.withOpacity(0.1),
                          child: Text('${i + 1}',
                              style: const TextStyle(color: Colors.deepPurple)),
                        ),
                        title: Text('Stagger item ${i + 1}'),
                        subtitle: Text(
                            'Interval: ${(i * 15)}% → ${(i * 15 + 40)}%'),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 8),
          Center(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: () {
                _staggerController.reset();
                _staggerController.forward();
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play Stagger'),
            ),
          ),
          const SizedBox(height: 8),
          _codeSnippet('''
// Single controller drives all items
_staggerController = AnimationController(duration: 1200.ms, vsync: this);

// Each item gets its own slice of the 0→1 range via Interval
_staggerAnims = List.generate(5, (i) {
  final start = i * 0.15;
  final end   = start + 0.40;
  return Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: _staggerController,
      curve: Interval(start, end, curve: Curves.easeOut),
      //     ^^^^^^^^ active only during [start, end] of the controller
    ),
  );
});

// Then play once:
_staggerController.forward();'''),

          const SizedBox(height: 24),
          Card(
            color: Colors.deepPurple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Key Takeaways',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• AnimatedBuilder rebuilds only its subtree, not the whole widget'),
                  Text('• Always dispose() controllers — they hold Ticker resources'),
                  Text('• CurvedAnimation changes the "shape" of the animation, not the duration'),
                  Text('• Stagger = Interval slices of a single shared controller'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(String title, String subtitle) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple)),
          Text(subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      );

  Widget _codeSnippet(String code) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(6),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(code,
              style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFFCDD6F4))),
        ),
      );
}

// ── Curved Animation visual demo ───────────────────────────────────────────────

/// Shows a ball bouncing along a horizontal track using a chosen curve.
class _CurvedAnimDemo extends StatelessWidget {
  final AnimationController controller;
  final String curveName;
  final Curve curve;
  final VoidCallback onRun;

  const _CurvedAnimDemo({
    required this.controller,
    required this.curveName,
    required this.curve,
    required this.onRun,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const ballSize = 32.0;
            final trackWidth = constraints.maxWidth - ballSize;

            return AnimatedBuilder(
              animation: controller,
              builder: (_, __) {
                // Apply the curve to the raw controller value
                final curvedValue = curve.transform(controller.value);
                return Stack(
                  children: [
                    // Track
                    Container(
                      height: ballSize,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(ballSize / 2),
                      ),
                    ),
                    // Ball
                    Positioned(
                      left: curvedValue * trackWidth,
                      child: Container(
                        width: ballSize,
                        height: ballSize,
                        decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.circle,
                            color: Colors.white, size: 12),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Curve: $curveName',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(width: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 12)),
              onPressed: onRun,
              child: const Text('Run'),
            ),
          ],
        ),
      ],
    );
  }
}
