/// Entry point Phase 10.4 — Track 4: Performance
///
/// Track 4 teaches you to build Flutter apps that run at 60fps+ on any device.
///
/// **Topics:**
/// 01. DevTools Profiling — CPU profiler, rebuild stats, RepaintBoundary
/// 02. Custom RenderObject — layout primitive, performLayout, paint, hitTest
/// 03. Shader Effects — GLSL fragment shaders, FragmentProgram, wave/blur/noise
/// 04. Isolates & compute() — off-thread heavy work, SendPort/ReceivePort
///
/// **Mini Project: Performance Dashboard**
/// Real-time FPS counter, frame time chart, jank detector, workload simulator.
import 'package:flutter/material.dart';

import '01_devtools_profiling/devtools_profiling_demo.dart';
import '02_custom_render_object/custom_render_object_demo.dart';
import '03_shader_effects/shader_effects_demo.dart';
import '04_isolate_compute/isolate_compute_demo.dart';
import 'mini_projects/perf_dashboard/perf_dashboard_app.dart';

void main() => runApp(const Phase104MenuApp());

class Phase104MenuApp extends StatelessWidget {
  const Phase104MenuApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phase 10.4 — Performance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true),
      home: const Phase104MenuScreen(),
    );
  }
}

class Phase104MenuScreen extends StatelessWidget {
  const Phase104MenuScreen({super.key});

  static const _topics = [
    _T('01 — DevTools Profiling',
        'CPU profiler, rebuild stats, RepaintBoundary, Timeline',
        Icons.bar_chart, Colors.blue, DevToolsProfilingDemo()),
    _T('02 — Custom RenderObject',
        'performLayout, paint, hitTest, ring layout example',
        Icons.view_quilt, Colors.orange, CustomRenderObjectDemo()),
    _T('03 — Shader Effects',
        'GLSL, FragmentProgram, wave/blur/noise, GPU rendering',
        Icons.auto_awesome, Colors.purple, ShaderEffectsDemo()),
    _T('04 — Isolates & compute()',
        'Isolate.run(), compute(), SendPort/ReceivePort, worker pattern',
        Icons.device_hub, Colors.teal, IsolateComputeDemo()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 10.4 — Performance'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.teal.shade50,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Track 4 teaches you to make your app fly.\n\n'
                '• Profile before you optimize — never guess\n'
                '• Move heavy work off the main thread\n'
                '• Build custom layout primitives for ultimate control\n'
                '• Use GPU shaders for visual effects that would crush the CPU',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._topics.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor: t.color.withAlpha(38),
                        child: Icon(t.icon, color: t.color, size: 20)),
                    title: Text(t.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(t.sub, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => t.dest)),
                  ),
                ),
              )),
          const Divider(height: 24),
          Card(
            color: Colors.teal.shade100,
            child: ListTile(
              leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.dashboard, color: Colors.white)),
              title: const Text('Mini Project: Performance Dashboard',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text(
                  'Live FPS, frame time chart, jank detector, workload simulator, rebuild counter'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfDashboardApp())),
            ),
          ),
        ],
      ),
    );
  }
}

class _T {
  final String label, sub;
  final IconData icon;
  final Color color;
  final Widget dest;
  const _T(this.label, this.sub, this.icon, this.color, this.dest);
}
