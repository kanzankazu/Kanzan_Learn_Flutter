/// Phase 10.5 — Topic 04: Inter-Module Communication
///
/// In a Super App, feature modules are independent — they should not
/// import each other directly (that would create tight coupling and
/// defeat the purpose of modularity).
///
/// Patterns for modules to communicate without coupling:
/// 1. Shared event bus — publish/subscribe to domain events
/// 2. Shared service locator — access cross-cutting services
/// 3. Callback injection — shell passes callbacks to modules
/// 4. Shared state (Riverpod) — modules watch the same providers
/// 5. Deep links as commands — navigate via URL, modules handle routes
///
/// Key concepts covered:
/// 1. EventBus pattern — decouple sender from receiver
/// 2. Shared providers — auth state, user profile, theme
/// 3. Module API interface — expose a narrow public API
/// 4. Dependency inversion for inter-module calls
import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Module Communication',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), useMaterial3: true),
        home: const ModuleCommunicationDemo(),
      );
}

class ModuleCommunicationDemo extends StatefulWidget {
  const ModuleCommunicationDemo({super.key});
  @override
  State<ModuleCommunicationDemo> createState() => _ModuleCommunicationDemoState();
}

class _ModuleCommunicationDemoState extends State<ModuleCommunicationDemo> {
  // Live demo: event bus simulation
  final _eventBus = _SimpleEventBus();
  final List<String> _eventLog = [];

  @override
  void initState() {
    super.initState();
    // Module B listens for events from Module A
    _eventBus.on<_PaymentCompletedEvent>().listen((e) {
      setState(() => _eventLog.add('[Promo Module] Received: payment for ${e.amount} — show cashback offer!'));
    });
    _eventBus.on<_UserLoggedInEvent>().listen((e) {
      setState(() => _eventLog.add('[All Modules] User ${e.userId} logged in — refresh data'));
    });
  }

  void _triggerPayment() {
    _eventBus.fire(_PaymentCompletedEvent(amount: 'Rp 250.000', transactionId: 'TXN-001'));
    setState(() => _eventLog.add('[Wallet Module] Fired: PaymentCompleted'));
  }

  void _triggerLogin() {
    _eventBus.fire(_UserLoggedInEvent(userId: 'USR-123'));
    setState(() => _eventLog.add('[Auth Module] Fired: UserLoggedIn'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('04 — Module Communication'), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(color: Colors.teal.shade50, child: const Text(
            'Modules must NOT import each other.\n\n'
            'Instead, they communicate through shared abstractions:\n'
            'event bus, shared providers, or interface injection.',
            style: TextStyle(fontSize: 13),
          )),
          const SizedBox(height: 16),

          // ── Live demo ────────────────────────────────────────────────
          _h('Live Demo — Event Bus', Colors.teal),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: Colors.teal),
                      onPressed: _triggerPayment,
                      icon: const Icon(Icons.payment, size: 16),
                      label: const Text('Complete Payment'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: _triggerLogin,
                      icon: const Icon(Icons.login, size: 16),
                      label: const Text('User Login'),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  const Text('Event Log:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    height: 120,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                    child: _eventLog.isEmpty
                        ? const Center(child: Text('Tap buttons to fire events', style: TextStyle(color: Colors.grey, fontSize: 12)))
                        : ListView(children: _eventLog.reversed.map((e) => Text('• $e', style: const TextStyle(fontSize: 11))).toList()),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── 1. EventBus implementation ─────────────────────────────────
          _h('1. Type-Safe Event Bus', Colors.blue),
          _code(r'''
// packages/core/lib/event_bus.dart

/// A simple type-safe event bus using Dart Streams.
/// Each event type gets its own StreamController.
class AppEventBus {
  static final AppEventBus _instance = AppEventBus._();
  AppEventBus._();
  factory AppEventBus() => _instance;

  final Map<Type, StreamController> _controllers = {};

  /// Subscribe to events of type [T].
  Stream<T> on<T>() {
    _controllers[T] ??= StreamController<T>.broadcast();
    return (_controllers[T] as StreamController<T>).stream;
  }

  /// Publish an event of type [T].
  void fire<T>(T event) {
    _controllers[T]?.add(event);
  }

  void dispose() {
    for (final ctrl in _controllers.values) ctrl.close();
  }
}

// ── Domain events (in packages/core/lib/events/) ───────────────────

// Events are pure data classes — no business logic
class PaymentCompletedEvent {
  final String transactionId;
  final double amount;
  final String walletId;
  const PaymentCompletedEvent({required this.transactionId, required this.amount, required this.walletId});
}

class UserLoggedInEvent {
  final String userId;
  const UserLoggedInEvent({required this.userId});
}

class UserLoggedOutEvent { const UserLoggedOutEvent(); }

// ── Wallet module: fires events ─────────────────────────────────────
class WalletUseCase {
  final AppEventBus _bus;
  WalletUseCase(this._bus);

  Future<void> completePayment(String txId, double amount) async {
    await _api.confirmPayment(txId);
    // Fire event — no direct reference to PromoModule!
    _bus.fire(PaymentCompletedEvent(
      transactionId: txId, amount: amount, walletId: 'wallet_main'));
  }
}

// ── Promo module: listens for events ───────────────────────────────
class PromoNotifier extends AsyncNotifier<List<Promo>> {
  @override
  Future<List<Promo>> build() async {
    // Listen for payment events from other modules
    ref.listen(appEventBusProvider.select((_) => null), (_, __) {});
    final bus = ref.watch(appEventBusProvider);
    bus.on<PaymentCompletedEvent>().listen((event) {
      // Show cashback offer after a payment — no coupling to Wallet!
      ref.invalidateSelf();
    });
    return _api.getAvailablePromos();
  }
}'''),

          const SizedBox(height: 20),

          // ── 2. Shared providers ────────────────────────────────────────
          _h('2. Shared Providers (Cross-Module State)', Colors.purple),
          _code(r'''
// packages/core/lib/providers/auth_provider.dart
// This provider is in the "core" package — ALL modules can watch it

@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override
  Future<User?> build() async {
    return _authService.getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final user = await _authService.login(email, password);
    state = AsyncData(user);
    // Fire event so all modules react
    ref.read(appEventBusProvider).fire(UserLoggedInEvent(userId: user.id));
  }
}

// ── How modules use shared state ─────────────────────────────────

// Wallet module — watches auth from core
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.watch(authStateProvider);
  return user.when(
    data: (u) => u != null ? WalletScreen(userId: u.id) : const LoginPrompt(),
    loading: () => const CircularProgressIndicator(),
    error: (_, __) => const ErrorScreen(),
  );
}

// Promo module — watches the same auth provider from core
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const SizedBox.shrink();
  return PromoList(userId: user.id);
}'''),

          const SizedBox(height: 20),

          // ── 3. Module API interface ────────────────────────────────────
          _h('3. Module API — Narrow Public Interface', Colors.orange),
          _code(r'''
// packages/core/lib/module_apis/wallet_api.dart
// Defines what Wallet exposes to other modules (NOT its internals)

abstract interface class IWalletApi {
  /// Returns the user's current total balance across all wallets.
  Future<double> getTotalBalance(String userId);

  /// Returns the active wallet count.
  int get activeWalletCount;

  /// Navigate to the wallet transfer screen.
  void openTransferScreen(BuildContext context, String? prefillAmount);
}

// packages/feature_wallet/lib/wallet_api_impl.dart
class WalletApiImpl implements IWalletApi {
  @override
  Future<double> getTotalBalance(String userId) =>
      _walletRepo.getTotalBalance(userId);

  @override
  int get activeWalletCount => _state.wallets.length;

  @override
  void openTransferScreen(BuildContext context, String? prefillAmount) =>
      context.push('/wallet/transfer?amount=\${prefillAmount ?? ""}');
}

// Shell app registers the implementation in the DI container
// Other modules depend on IWalletApi — not on WalletApiImpl
// This is the Dependency Inversion Principle applied to modules.'''),

          const SizedBox(height: 16),
          _card(color: Colors.teal.shade50, child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Modules NEVER import each other directly'),
              Text('• EventBus (fire/on) decouples sender from all receivers'),
              Text('• Shared providers in "core" package = cross-module state'),
              Text('• Module API interface = narrow contract for cross-module calls'),
              Text('• Shell app wires everything together — modules stay isolated'),
              Text('• Test modules independently by mocking IWalletApi, IFeatureFlags, etc.'),
            ],
          )),
        ],
      ),
    );
  }
}

// ── Simple event bus for the live demo ────────────────────────────────────────

class _SimpleEventBus {
  final Map<Type, StreamController> _ctrl = {};
  Stream<T> on<T>() { _ctrl[T] ??= StreamController<T>.broadcast(); return (_ctrl[T] as StreamController<T>).stream; }
  void fire<T>(T event) => _ctrl[T]?.add(event);
}

class _PaymentCompletedEvent { final String amount, transactionId; const _PaymentCompletedEvent({required this.amount, required this.transactionId}); }
class _UserLoggedInEvent { final String userId; const _UserLoggedInEvent({required this.userId}); }

Widget _h(String t, Color c) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: c)));
Widget _code(String s) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(6)), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(s, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCDD6F4)))));
Widget _card({required Color color, required Widget child}) => Card(color: color, child: Padding(padding: const EdgeInsets.all(12), child: child));
