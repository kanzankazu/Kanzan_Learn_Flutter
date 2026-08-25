/// Phase 10.2 — Topic 04: State Machines with Riverpod
///
/// A Finite State Machine (FSM) models complex workflows as a set of
/// explicit states with allowed transitions between them.
///
/// Without FSM: ad-hoc boolean flags (isLoading, isSuccess, hasError, isRetrying…)
/// → hard to reason about, easy to get into impossible states
///
/// With FSM: each state is a sealed class, transitions are explicit
/// → impossible states become compile-time errors
///
/// Key concepts covered:
/// 1. Why state machines? — the boolean flag explosion problem
/// 2. Sealed classes as states
/// 3. Allowed transitions — guard clauses in the notifier
/// 4. State machine + Riverpod AsyncNotifier
/// 5. XState-inspired patterns in Dart
/// 6. Testing state machines — exhaustive coverage
/// 7. Practical example: payment flow FSM
import 'package:flutter/material.dart';

void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'State Machines',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo), useMaterial3: true),
      home: const StateMachinesDemo(),
    );
  }
}

class StateMachinesDemo extends StatefulWidget {
  const StateMachinesDemo({super.key});
  @override
  State<StateMachinesDemo> createState() => _StateMachinesDemoState();
}

class _StateMachinesDemoState extends State<StateMachinesDemo> {
  // Live FSM: payment flow
  _PaymentState _paymentState = const _PaymentIdle();

  void _pay() {
    if (_paymentState is! _PaymentIdle) return;
    setState(() => _paymentState = const _PaymentProcessing());
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _paymentState = const _PaymentSuccess('TXN-202608241'));
    });
  }

  void _retry() {
    if (_paymentState is! _PaymentFailed) return;
    setState(() => _paymentState = const _PaymentIdle());
  }

  void _reset() {
    setState(() => _paymentState = const _PaymentIdle());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('04 — State Machines'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            color: Colors.indigo.shade50,
            child: const Text(
              'State machines eliminate impossible states by making every '
              'valid state explicit as a sealed class.\n\n'
              'Instead of: isLoading=true, hasError=false, isRetrying=true '
              '(what does this even mean?)\n\n'
              'Use: sealed class that can only be Loading, Error, or Retrying.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),

          // ── Live FSM demo ─────────────────────────────────────────────
          _header('Live Demo — Payment Flow FSM', Colors.indigo),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // State visualization
                  _PaymentStateWidget(state: _paymentState),
                  const SizedBox(height: 16),

                  // Valid actions based on current state
                  if (_paymentState is _PaymentIdle)
                    FilledButton.icon(
                      onPressed: _pay,
                      icon: const Icon(Icons.payment),
                      label: const Text('Pay Rp 150.000'),
                    ),
                  if (_paymentState is _PaymentSuccess)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: _reset,
                          icon: const Icon(Icons.refresh),
                          label: const Text('New Payment'),
                        ),
                      ],
                    ),
                  if (_paymentState is _PaymentFailed)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _retry,
                          icon: const Icon(Icons.replay),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── 1. Boolean flag problem ───────────────────────────────────
          _header('1. The Boolean Flag Problem', Colors.red),
          _code(r'''
// ❌ Bad: ad-hoc boolean flags — 2^4 = 16 possible combinations
//    but only 4 are valid. The rest are "impossible states" that
//    the compiler cannot prevent.
class PaymentViewModel extends ChangeNotifier {
  bool isIdle = true;
  bool isLoading = false;
  bool isSuccess = false;
  bool isError = false;
  String? errorMessage;
  String? transactionId;
  // What does isLoading=true AND isSuccess=true mean? Undefined!
}

// ✅ Good: sealed class — only 4 valid states, compiler-enforced
sealed class PaymentState { const PaymentState(); }
class PaymentIdle        extends PaymentState { const PaymentIdle(); }
class PaymentProcessing  extends PaymentState { const PaymentProcessing(); }
class PaymentSuccess     extends PaymentState {
  final String transactionId;
  const PaymentSuccess(this.transactionId);
}
class PaymentFailed      extends PaymentState {
  final String message;
  const PaymentFailed(this.message);
}
// Now: PaymentProcessing AND PaymentSuccess cannot coexist — impossible.'''),

          const SizedBox(height: 20),

          // ── 2. Transitions with guards ────────────────────────────────
          _header('2. Transitions with Guard Clauses', Colors.teal),
          _code(r'''
// Riverpod Notifier as the FSM controller
class PaymentNotifier extends Notifier<PaymentState> {
  @override
  PaymentState build() => const PaymentIdle();

  // ALLOWED TRANSITIONS:
  //   Idle → Processing   (via pay())
  //   Processing → Success (via _onSuccess())
  //   Processing → Failed  (via _onError())
  //   Failed → Idle        (via retry())
  //   Success → Idle       (via reset())
  //
  // BLOCKED: e.g., Success → Processing without going through Idle first.

  Future<void> pay(double amount) async {
    // Guard: only allowed from Idle state
    if (state is! PaymentIdle) {
      throw StateError('Cannot pay from state: ${state.runtimeType}');
    }

    state = const PaymentProcessing();
    try {
      final txId = await ref.read(paymentApiProvider).charge(amount);
      state = PaymentSuccess(txId);
    } on PaymentException catch (e) {
      state = PaymentFailed(e.message);
    }
  }

  void retry() {
    // Guard: only from Failed
    if (state is PaymentFailed) state = const PaymentIdle();
  }

  void reset() {
    // Guard: only from Success
    if (state is PaymentSuccess) state = const PaymentIdle();
  }
}

// Widget — use switch to handle all states (compiler forces exhaustive check)
Widget build(BuildContext context, WidgetRef ref) {
  final payment = ref.watch(paymentProvider);
  return switch (payment) {
    PaymentIdle()       => _PayButton(onTap: () => ref.read(paymentProvider.notifier).pay(150000)),
    PaymentProcessing() => const CircularProgressIndicator(),
    PaymentSuccess(:final transactionId) => _SuccessView(txId: transactionId),
    PaymentFailed(:final message) => _ErrorView(msg: message, onRetry: () => ...),
  };
  // Dart switch exhaustiveness: if you add a new state, this won't compile!
}'''),

          const SizedBox(height: 20),

          // ── 3. State machine diagram ─────────────────────────────────
          _header('3. Payment FSM Diagram', Colors.orange),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  const Text('State Transition Diagram',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _FsmDiagram(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── 4. Testing FSMs ───────────────────────────────────────────
          _header('4. Testing State Machines', Colors.green),
          _code(r'''
// FSMs are extremely testable — each transition is one test case
void main() {
  group('PaymentNotifier FSM', () {
    ProviderContainer makeContainer() => ProviderContainer(
      overrides: [paymentApiProvider.overrideWith(() => MockPaymentApi())],
    );

    test('starts in Idle', () {
      final container = makeContainer();
      expect(container.read(paymentProvider), isA<PaymentIdle>());
    });

    test('transitions Idle → Processing → Success', () async {
      final container = makeContainer();
      // Mock returns success after 1 call
      when(() => mockApi.charge(any())).thenAnswer((_) async => 'TXN-001');

      await container.read(paymentProvider.notifier).pay(150000);

      expect(container.read(paymentProvider), isA<PaymentSuccess>());
      expect((container.read(paymentProvider) as PaymentSuccess).transactionId,
          equals('TXN-001'));
    });

    test('cannot pay from Processing state', () {
      final container = makeContainer();
      container.read(paymentProvider.notifier)._setState(const PaymentProcessing());

      expect(
        () => container.read(paymentProvider.notifier).pay(100),
        throwsStateError,
      );
    });
  });
}'''),

          const SizedBox(height: 16),
          _card(
            color: Colors.indigo.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• Sealed classes make "impossible states impossible" at compile time'),
                Text('• Guard clauses in transitions prevent invalid state jumps'),
                Text('• Switch exhaustiveness forces handling every state in the UI'),
                Text('• Each transition = one test case → perfect test coverage'),
                Text('• Use FSMs for: auth, payment, forms, onboarding, media playback'),
                Text('• Simple screens don\'t need FSMs — use AsyncValue from Riverpod'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── FSM State classes ──────────────────────────────────────────────────────────

sealed class _PaymentState { const _PaymentState(); }
class _PaymentIdle extends _PaymentState { const _PaymentIdle(); }
class _PaymentProcessing extends _PaymentState { const _PaymentProcessing(); }
class _PaymentSuccess extends _PaymentState {
  final String txId;
  const _PaymentSuccess(this.txId);
}
class _PaymentFailed extends _PaymentState {
  final String message;
  const _PaymentFailed(this.message);
}

// ── State visualization widget ─────────────────────────────────────────────────

class _PaymentStateWidget extends StatelessWidget {
  final _PaymentState state;
  const _PaymentStateWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      _PaymentIdle() => _stateChip('Idle', Colors.grey, Icons.circle_outlined),
      _PaymentProcessing() => Column(
          children: [
            _stateChip('Processing', Colors.blue, Icons.sync),
            const SizedBox(height: 8),
            const CircularProgressIndicator(),
          ],
        ),
      _PaymentSuccess(:final txId) => Column(
          children: [
            _stateChip('Success', Colors.green, Icons.check_circle),
            const SizedBox(height: 4),
            Text('TXN: $txId', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ],
        ),
      _PaymentFailed(:final message) => Column(
          children: [
            _stateChip('Failed', Colors.red, Icons.error),
            Text(message, style: const TextStyle(fontSize: 12, color: Colors.red)),
          ],
        ),
    };
  }

  Widget _stateChip(String label, Color color, IconData icon) => Chip(
        avatar: Icon(icon, color: color, size: 18),
        label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        backgroundColor: color.withAlpha(25),
      );
}

// ── Simple FSM diagram using Custom Painter ────────────────────────────────────

class _FsmDiagram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 120),
      painter: _FsmPainter(),
    );
  }
}

class _FsmPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final states = ['Idle', 'Processing', 'Success', 'Failed'];
    final colors = [Colors.grey, Colors.blue, Colors.green, Colors.red];
    final w = size.width / 4;
    const r = 24.0;

    // Draw state nodes
    for (var i = 0; i < states.length; i++) {
      final cx = w * i + w / 2;
      final cy = size.height / 2;
      canvas.drawCircle(Offset(cx, cy), r, Paint()..color = colors[i].withAlpha(40));
      canvas.drawCircle(Offset(cx, cy), r, Paint()..color = colors[i]..style = PaintingStyle.stroke..strokeWidth = 2);

      final tp = TextPainter(
        text: TextSpan(text: states[i], style: TextStyle(fontSize: 9, color: colors[i], fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
    }

    // Draw arrows between states
    final arrowPaint = Paint()..color = Colors.grey.shade400..strokeWidth = 1.5..style = PaintingStyle.stroke;
    for (var i = 0; i < states.length - 1; i++) {
      if (i == 1) continue; // Skip Processing→Success→Failed (both from Processing)
      final x1 = w * i + w / 2 + r;
      final x2 = w * (i + 1) + w / 2 - r;
      final cy = size.height / 2;
      canvas.drawLine(Offset(x1, cy), Offset(x2, cy), arrowPaint);
    }
  }

  @override
  bool shouldRepaint(_FsmPainter old) => false;
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
