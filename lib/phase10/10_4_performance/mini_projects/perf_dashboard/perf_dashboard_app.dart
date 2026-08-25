/// Phase 10.4 — Mini Project: Performance Dashboard
///
/// A real-time performance monitoring dashboard showing:
/// - Live FPS counter (Ticker-based)
/// - Frame time chart (Custom Painter bar chart)
/// - Memory usage estimation
/// - Rebuild counter per widget
/// - Jank detector (frames > 16ms)
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() => runApp(const PerfDashboardApp());

class PerfDashboardApp extends StatelessWidget {
  const PerfDashboardApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Performance Dashboard',
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false, // use our custom overlay instead
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), useMaterial3: true),
      home: const PerfDashboardScreen(),
    );
  }
}

class PerfDashboardScreen extends StatefulWidget {
  const PerfDashboardScreen({super.key});
  @override
  State<PerfDashboardScreen> createState() => _PerfDashboardScreenState();
}

class _PerfDashboardScreenState extends State<PerfDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  // Frame timing
  Duration _lastElapsed = Duration.zero;
  final List<double> _frameTimes = List.filled(60, 0.0); // rolling 60-frame history
  int _frameIndex = 0;
  double _currentFps = 0.0;
  int _jankCount = 0;

  // Rebuild tracking
  int _expensiveRebuildCount = 0;
  bool _showExpensive = false;

  // Workload simulation
  double _cpuLoad = 0.0; // 0.0–1.0
  late final AnimationController _workController;
  late final Animation<double> _workAnim;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _workController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _workAnim = _workController;
  }

  void _onTick(Duration elapsed) {
    final dt = elapsed - _lastElapsed;
    _lastElapsed = elapsed;

    if (dt == Duration.zero) return;

    final ms = dt.inMicroseconds / 1000.0;
    final fps = 1000.0 / ms;

    setState(() {
      _frameTimes[_frameIndex % 60] = ms;
      _frameIndex++;
      _currentFps = fps;
      if (ms > 16.67) _jankCount++;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _workController.dispose();
    super.dispose();
  }

  double get _avgFrameTime {
    final valid = _frameTimes.where((t) => t > 0);
    if (valid.isEmpty) return 0;
    return valid.reduce((a, b) => a + b) / valid.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Dashboard'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── KPI row ─────────────────────────────────────────────────
            Row(
              children: [
                Expanded(child: _KpiCard(
                  label: 'FPS', value: _currentFps.toStringAsFixed(0),
                  color: _currentFps >= 55 ? Colors.green : _currentFps >= 30 ? Colors.orange : Colors.red,
                  icon: Icons.speed,
                )),
                const SizedBox(width: 8),
                Expanded(child: _KpiCard(
                  label: 'Avg Frame', value: '${_avgFrameTime.toStringAsFixed(1)}ms',
                  color: _avgFrameTime <= 16.67 ? Colors.green : Colors.red,
                  icon: Icons.timer,
                )),
                const SizedBox(width: 8),
                Expanded(child: _KpiCard(
                  label: 'Jank', value: '$_jankCount',
                  color: _jankCount == 0 ? Colors.green : Colors.red,
                  icon: Icons.warning_amber,
                )),
              ],
            ),
            const SizedBox(height: 16),

            // ── Frame time chart ─────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Frame Time (ms) — Last 60 Frames',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Red = jank (> 16.67ms = dropped frame)',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 8),
                    CustomPaint(
                      size: const Size(double.infinity, 80),
                      painter: _FrameTimePainter(
                        frameTimes: _frameTimes,
                        currentIndex: _frameIndex,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Workload simulator ────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Workload Simulator',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('CPU load:', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Slider(
                            value: _cpuLoad,
                            onChanged: (v) => setState(() => _cpuLoad = v),
                          ),
                        ),
                        Text('${(_cpuLoad * 100).toInt()}%',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    // Expensive work simulation
                    AnimatedBuilder(
                      animation: _workAnim,
                      builder: (_, __) {
                        // Simulate CPU work based on load slider
                        if (_cpuLoad > 0) {
                          final iterations = (_cpuLoad * 100000).toInt();
                          var sum = 0.0;
                          for (var i = 0; i < iterations; i++) sum += math.sqrt(i.toDouble());
                          return Text('Work result: ${sum.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 10, color: Colors.grey));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Rebuild counter demo ──────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rebuild Counter',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Expensive widget rebuilt: $_expensiveRebuildCount times',
                            style: const TextStyle(fontSize: 12)),
                        Switch(
                          value: _showExpensive,
                          onChanged: (v) => setState(() => _showExpensive = v),
                        ),
                      ],
                    ),
                    if (_showExpensive)
                      _ExpensiveWidget(
                        onRebuild: () => _expensiveRebuildCount++,
                        time: _lastElapsed,
                      ),
                    const Text(
                      'Tip: Use const or RepaintBoundary to prevent unnecessary rebuilds.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            // Tips
            Card(
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Performance Tips', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('• Target: FPS ≥ 60, Frame time ≤ 16.67ms'),
                    Text('• Jank = frame > 16.67ms = user sees stuttering'),
                    Text('• Move CPU work to Isolate.run() to unblock the UI'),
                    Text('• Use const constructors — widgets that never rebuild'),
                    Text('• RepaintBoundary isolates expensive subtrees from full repaints'),
                    Text('• Profile with flutter run --profile, not --debug'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ────────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _KpiCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _ExpensiveWidget extends StatelessWidget {
  final VoidCallback onRebuild;
  final Duration time;
  const _ExpensiveWidget({required this.onRebuild, required this.time});

  @override
  Widget build(BuildContext context) {
    onRebuild(); // count rebuild
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.teal.shade100, Colors.teal.shade300]),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text('Expensive widget @ ${time.inMilliseconds}ms',
          style: const TextStyle(fontSize: 11)),
    );
  }
}

// ── Frame time chart painter ───────────────────────────────────────────────────

class _FrameTimePainter extends CustomPainter {
  final List<double> frameTimes;
  final int currentIndex;

  const _FrameTimePainter({required this.frameTimes, required this.currentIndex});

  @override
  void paint(Canvas canvas, Size size) {
    const budget = 16.67; // ms per frame at 60fps
    final barW = size.width / 60;
    final maxMs = 50.0; // y-axis max

    // Budget line
    canvas.drawLine(
      Offset(0, size.height * (1 - budget / maxMs)),
      Offset(size.width, size.height * (1 - budget / maxMs)),
      Paint()..color = Colors.grey.shade300..strokeWidth = 1,
    );

    for (var i = 0; i < 60; i++) {
      final dataIdx = (currentIndex - 60 + i) % 60;
      final ms = frameTimes[dataIdx.abs()];
      if (ms <= 0) continue;

      final barH = (ms / maxMs * size.height).clamp(0.0, size.height);
      final x = i * barW;
      final isJank = ms > budget;

      canvas.drawRect(
        Rect.fromLTWH(x + 1, size.height - barH, barW - 2, barH),
        Paint()..color = isJank ? Colors.red.shade400 : Colors.green.shade400,
      );
    }
  }

  @override
  bool shouldRepaint(_FrameTimePainter old) => true;
}
