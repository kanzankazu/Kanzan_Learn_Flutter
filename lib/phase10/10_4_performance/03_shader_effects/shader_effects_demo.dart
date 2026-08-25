/// Phase 10.4 — Topic 03: Fragment Shaders (GLSL Effects)
///
/// Fragment shaders run on the GPU for every pixel — enabling
/// real-time visual effects that are impossible with CPU drawing:
/// blur, glow, distortion, noise, gradient effects, wave animations.
///
/// Key concepts covered:
/// 1. What a fragment shader is — GPU program, runs per pixel
/// 2. GLSL basics — uniform, varying, built-in functions
/// 3. flutter.shaders in pubspec.yaml
/// 4. FragmentProgram.fromAsset() — load the shader at runtime
/// 5. FragmentShader.setFloat() — pass data from Dart to shader
/// 6. Using shaders with CustomPainter
/// 7. Performance considerations — GPU vs CPU tradeoffs
/// 8. Common shader effects: gradient, noise, wave, blur
import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shader Effects',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple), useMaterial3: true),
      home: const ShaderEffectsDemo(),
    );
  }
}

class ShaderEffectsDemo extends StatefulWidget {
  const ShaderEffectsDemo({super.key});
  @override
  State<ShaderEffectsDemo> createState() => _ShaderEffectsDemoState();
}

class _ShaderEffectsDemoState extends State<ShaderEffectsDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('03 — Shader Effects'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            color: Colors.purple.shade50,
            child: const Text(
              'Fragment shaders run on the GPU — every pixel in parallel.\n\n'
              'They are written in GLSL (OpenGL Shading Language) and compiled '
              'by Flutter\'s Impeller/Skia engine into GPU instructions.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),

          // ── Live demo: CPU-simulated wave effect ───────────────────────
          _header('Live Demo — Wave Effect (CPU simulation)', Colors.purple),
          const Text('This demo simulates what a shader would produce using CustomPainter. '
              'A real shader runs this on the GPU.',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => CustomPaint(
              size: const Size(double.infinity, 100),
              painter: _WavePainter(time: _ctrl.value * 2 * math.pi),
            ),
          ),

          const SizedBox(height: 20),

          // ── 1. GLSL basics ─────────────────────────────────────────────
          _header('1. GLSL Shader Basics', Colors.blue),
          _code(r'''
// shaders/wave.frag — the fragment shader file
// Flutter requires GLSL ES 1.0 (not GLSL 3.3)

precision mediump float;

// Uniforms: values passed from Dart to the shader each frame
uniform float uTime;          // current time in seconds
uniform vec2  uResolution;    // canvas width, height in pixels
uniform sampler2D uTexture;   // optional: a texture to sample

// The main function runs for EVERY pixel on the canvas
void main() {
  // gl_FragCoord = pixel position (0,0 = bottom-left, GLSL convention)
  vec2 uv = gl_FragCoord.xy / uResolution;  // normalize to 0.0–1.0

  // Wave: shift the Y of each pixel by a sine wave
  float wave = sin(uv.x * 10.0 + uTime * 2.0) * 0.05;

  // Gradient from blue to purple
  vec3 color = mix(
    vec3(0.1, 0.3, 0.9),   // blue
    vec3(0.6, 0.1, 0.9),   // purple
    uv.y + wave             // shift by wave
  );

  // Output: RGBA (each 0.0–1.0)
  gl_FragColor = vec4(color, 1.0);
}'''),

          const SizedBox(height: 20),

          // ── 2. Register the shader ─────────────────────────────────────
          _header('2. Register Shader in pubspec.yaml', Colors.teal),
          _code(r'''
# pubspec.yaml
flutter:
  shaders:
    - shaders/wave.frag      # register ALL shaders here
    - shaders/gradient.frag
    - shaders/blur.frag

# Flutter compiles shaders at build time → faster startup
# (no runtime compilation needed — it is AOT compiled with the app)'''),

          const SizedBox(height: 20),

          // ── 3. Load and use the shader ─────────────────────────────────
          _header('3. Use in a Flutter Widget', Colors.orange),
          _code(r'''
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class WaveWidget extends StatefulWidget { ... }

class _WaveState extends State<WaveWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 3.seconds)..repeat();
    _loadShader();
  }

  Future<void> _loadShader() async {
    // FragmentProgram.fromAsset loads and compiles the shader
    // This is async — show a placeholder until ready
    final program = await ui.FragmentProgram.fromAsset('shaders/wave.frag');
    setState(() => _shader = program.fragmentShader());
  }

  @override
  Widget build(BuildContext context) {
    if (_shader == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        // Pass values to shader uniforms (must match order in GLSL)
        _shader!
          ..setFloat(0, _ctrl.value * 2 * 3.14159)  // uTime
          ..setFloat(1, context.size?.width ?? 300)  // uResolution.x
          ..setFloat(2, context.size?.height ?? 200); // uResolution.y

        return CustomPaint(
          painter: _ShaderPainter(shader: _shader!),
          child: const SizedBox(height: 200),
        );
      },
    );
  }
}

class _ShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  const _ShaderPainter({required this.shader});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,  // apply shader as the paint
    );
  }

  @override
  bool shouldRepaint(_ShaderPainter old) => true; // always repaint (animated)
}'''),

          const SizedBox(height: 20),

          // ── 4. Common effects ──────────────────────────────────────────
          _header('4. Common Shader Effects', Colors.red),
          _code(r'''
// ── Radial blur ──────────────────────────────────────────────────
void main() {
  vec2 uv = gl_FragCoord.xy / uResolution;
  vec2 center = vec2(0.5, 0.5);
  vec2 dir = normalize(uv - center);
  float dist = length(uv - center);
  float blurAmount = dist * 0.05;  // more blur further from center

  vec4 color = vec4(0.0);
  for (int i = 0; i < 10; i++) {
    color += texture2D(uTexture, uv - dir * blurAmount * float(i));
  }
  gl_FragColor = color / 10.0;
}

// ── Noise / film grain ──────────────────────────────────────────
float rand(vec2 co) {
  return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
  vec2 uv = gl_FragCoord.xy / uResolution;
  vec4 tex = texture2D(uTexture, uv);
  float noise = rand(uv + uTime) * 0.1;  // 10% grain
  gl_FragColor = tex + vec4(noise, noise, noise, 0.0);
}

// ── Chromatic aberration (lens distortion) ──────────────────────
void main() {
  vec2 uv = gl_FragCoord.xy / uResolution;
  float amount = 0.003;
  gl_FragColor = vec4(
    texture2D(uTexture, uv + vec2( amount, 0.0)).r,  // R shifted right
    texture2D(uTexture, uv).g,                        // G unchanged
    texture2D(uTexture, uv + vec2(-amount, 0.0)).b,  // B shifted left
    1.0
  );
}'''),

          const SizedBox(height: 16),
          _card(
            color: Colors.purple.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• Fragment shaders run on the GPU — perfect for smooth 60fps effects'),
                Text('• Register shaders in pubspec.yaml flutter.shaders section'),
                Text('• FragmentProgram.fromAsset() is async — load in initState'),
                Text('• shader.setFloat(index, value) passes Dart values to GLSL uniforms'),
                Text('• Use Paint()..shader = myShader in CustomPainter.paint()'),
                Text('• Shaders have no concept of Flutter widgets — just pixels and math'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wave demo painter (CPU simulation) ────────────────────────────────────────

class _WavePainter extends CustomPainter {
  final double time;
  const _WavePainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var x = 0.0; x < size.width; x++) {
      final uv = x / size.width;
      final wave = math.sin(uv * 10 + time) * 10;
      final t = (uv + wave / size.height).clamp(0.0, 1.0);
      final color = Color.lerp(const Color(0xFF1A3AE8), const Color(0xFF9B16E8), t)!;
      paint.color = color;
      canvas.drawRect(Rect.fromLTWH(x, 0, 1, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.time != time;
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
