/// Demo 04 — Use Cases: When to Use Them and When NOT To.
///
/// A Use Case (also called Interactor) encapsulates a single, named business
/// operation. It sits in the DOMAIN layer between the repository and the ViewModel.
///
/// **The debate: Use Case or not?**
/// This is one of the most discussed topics in Flutter architecture.
/// The rule from the BRImo/Qitta codebase: "UseCase ONLY if there is business
/// logic inside — never create a passthrough UseCase."
///
/// **When to CREATE a Use Case:**
/// ✅ Combines data from multiple repositories
/// ✅ Contains real business logic (validation, calculation, transformation)
/// ✅ Logic is complex enough to test in isolation
/// ✅ Same operation is called from multiple places in the app
///
/// **When to SKIP a Use Case (call repository directly from ViewModel):**
/// ❌ Just forwarding: `return repository.getAll()` — no value added
/// ❌ Single simple fetch with no transformation
/// ❌ CRUD operation with no business rules
///
/// **This demo shows both — with and without Use Cases — side by side.**
///
/// How to run: `flutter run -t lib/phase5/04_use_cases/use_cases_demo.dart`
library;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Domain entities
// ─────────────────────────────────────────────────────────────────────────────

class Order {
  final String id;
  final List<OrderItem> items;
  final String customerId;
  final DateTime placedAt;

  const Order({
    required this.id,
    required this.items,
    required this.customerId,
    required this.placedAt,
  });

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.price * item.quantity);
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });
}

class Customer {
  final String id;
  final String name;
  final String tier; // 'gold' | 'silver' | 'regular'
  final int loyaltyPoints;

  const Customer({
    required this.id,
    required this.name,
    required this.tier,
    required this.loyaltyPoints,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Domain repositories (abstract interfaces)
// ─────────────────────────────────────────────────────────────────────────────

abstract class OrderRepository {
  Future<List<Order>> getOrdersForCustomer(String customerId);
}

abstract class CustomerRepository {
  Future<Customer?> getById(String id);
}

// ─────────────────────────────────────────────────────────────────────────────
// ❌ PASSTHROUGH Use Case — Don't create these
// ─────────────────────────────────────────────────────────────────────────────

/// ❌ This Use Case adds NO value — it's just a forwarding wrapper.
/// Creating this is unnecessary boilerplate. Call the repository directly.
class GetOrdersUseCase_Bad {
  final OrderRepository _repo;
  GetOrdersUseCase_Bad(this._repo);

  /// Zero business logic — this is just a passthrough. Don't do this.
  Future<List<Order>> execute(String customerId) =>
      _repo.getOrdersForCustomer(customerId); // literally just forwarding
}

// ─────────────────────────────────────────────────────────────────────────────
// ✅ Use Cases WITH real business logic
// ─────────────────────────────────────────────────────────────────────────────

/// ✅ GOOD Use Case — calculates an order total with business rules.
///
/// Business logic this Use Case encapsulates:
/// 1. Fetches the customer to determine their loyalty tier
/// 2. Applies tier-based discount (gold=15%, silver=10%, regular=0%)
/// 3. Calculates the VAT (11%)
/// 4. Returns an [OrderSummary] with the full breakdown
///
/// This is NOT a passthrough — it combines two repositories AND has
/// non-trivial discount and tax logic. Perfect for a Use Case.
class CalculateOrderTotalUseCase {
  final OrderRepository _orders;
  final CustomerRepository _customers;

  // Injecting TWO repositories — combining data sources is a key Use Case job
  CalculateOrderTotalUseCase(this._orders, this._customers);

  /// Calculates the final order total with discount and tax applied.
  Future<OrderSummary> execute(String orderId, String customerId) async {
    // Fetch data from two separate repositories
    final orders = await _orders.getOrdersForCustomer(customerId);
    final customer = await _customers.getById(customerId);

    final order = orders.firstWhere((o) => o.id == orderId);
    final subtotal = order.subtotal;

    // Business rule: discount based on customer loyalty tier
    final discountRate = _discountForTier(customer?.tier ?? 'regular');
    final discountAmount = subtotal * discountRate;
    final afterDiscount = subtotal - discountAmount;

    // Business rule: 11% VAT on the discounted price
    const vatRate = 0.11;
    final vatAmount = afterDiscount * vatRate;
    final total = afterDiscount + vatAmount;

    return OrderSummary(
      orderId: orderId,
      customerName: customer?.name ?? 'Unknown',
      customerTier: customer?.tier ?? 'regular',
      subtotal: subtotal,
      discountRate: discountRate,
      discountAmount: discountAmount,
      vatAmount: vatAmount,
      total: total,
    );
  }

  /// Pure business rule: returns the discount rate for a customer tier.
  /// Pure = no side effects, no async, deterministic. Easy to unit test.
  double _discountForTier(String tier) => switch (tier) {
        'gold' => 0.15,   // 15% discount
        'silver' => 0.10, // 10% discount
        _ => 0.0,         // no discount for regular customers
      };
}

/// ✅ GOOD Use Case — checks if a customer is eligible for an upgrade.
///
/// Business rule: upgrade to gold if 5+ orders placed AND loyalty points >= 1000.
/// This logic should NOT be in the ViewModel (too complex) or in a Widget (wrong layer).
class CheckUpgradeEligibilityUseCase {
  final OrderRepository _orders;
  final CustomerRepository _customers;

  CheckUpgradeEligibilityUseCase(this._orders, this._customers);

  Future<UpgradeResult> execute(String customerId) async {
    final orders = await _orders.getOrdersForCustomer(customerId);
    final customer = await _customers.getById(customerId);

    if (customer == null) {
      return UpgradeResult(isEligible: false, reason: 'Customer not found');
    }

    // Business rule 1: must have placed at least 5 orders
    final orderCount = orders.length;
    if (orderCount < 5) {
      return UpgradeResult(
        isEligible: false,
        reason: 'Need ${5 - orderCount} more order(s) to qualify',
      );
    }

    // Business rule 2: must have at least 1000 loyalty points
    if (customer.loyaltyPoints < 1000) {
      return UpgradeResult(
        isEligible: false,
        reason:
            'Need ${1000 - customer.loyaltyPoints} more loyalty points to qualify',
      );
    }

    // All rules passed
    return UpgradeResult(
      isEligible: true,
      reason: 'Eligible! You qualify for ${_nextTier(customer.tier)} status.',
    );
  }

  /// Determines what the next tier up is.
  String _nextTier(String current) => switch (current) {
        'regular' => 'Silver',
        'silver' => 'Gold',
        _ => 'Gold (already highest)',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Value objects returned by Use Cases
// ─────────────────────────────────────────────────────────────────────────────

/// The result of the [CalculateOrderTotalUseCase].
///
/// A Use Case should return a purpose-built result object — not the raw entity.
/// This keeps the domain clean and the presentation layer thin.
class OrderSummary {
  final String orderId;
  final String customerName;
  final String customerTier;
  final double subtotal;
  final double discountRate;
  final double discountAmount;
  final double vatAmount;
  final double total;

  const OrderSummary({
    required this.orderId,
    required this.customerName,
    required this.customerTier,
    required this.subtotal,
    required this.discountRate,
    required this.discountAmount,
    required this.vatAmount,
    required this.total,
  });
}

class UpgradeResult {
  final bool isEligible;
  final String reason;
  const UpgradeResult({required this.isEligible, required this.reason});
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock data implementations
// ─────────────────────────────────────────────────────────────────────────────

class MockOrderRepository implements OrderRepository {
  static final _orders = {
    'c1': [
      Order(
        id: 'o1',
        customerId: 'c1',
        placedAt: DateTime.now().subtract(const Duration(days: 30)),
        items: const [
          OrderItem(productId: 'p1', productName: 'Laptop', price: 15000000, quantity: 1),
          OrderItem(productId: 'p2', productName: 'Mouse', price: 250000, quantity: 2),
        ],
      ),
      Order(
        id: 'o2',
        customerId: 'c1',
        placedAt: DateTime.now().subtract(const Duration(days: 15)),
        items: const [
          OrderItem(productId: 'p3', productName: 'Keyboard', price: 850000, quantity: 1),
        ],
      ),
    ],
  };

  @override
  Future<List<Order>> getOrdersForCustomer(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders[customerId] ?? [];
  }
}

class MockCustomerRepository implements CustomerRepository {
  static const _customers = {
    'c1': Customer(
        id: 'c1', name: 'Alice Johnson', tier: 'gold', loyaltyPoints: 2450),
    'c2': Customer(
        id: 'c2', name: 'Bob Smith', tier: 'regular', loyaltyPoints: 320),
  };

  @override
  Future<Customer?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _customers[id];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class UseCasesDemo extends StatelessWidget {
  const UseCasesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Use Cases Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const _UseCaseScreen(),
    );
  }
}

class _UseCaseScreen extends StatefulWidget {
  const _UseCaseScreen();

  @override
  State<_UseCaseScreen> createState() => _UseCaseScreenState();
}

class _UseCaseScreenState extends State<_UseCaseScreen> {
  final _orders = MockOrderRepository();
  final _customers = MockCustomerRepository();

  late final CalculateOrderTotalUseCase _calcTotal;
  late final CheckUpgradeEligibilityUseCase _checkUpgrade;

  OrderSummary? _summary;
  UpgradeResult? _upgradeResult;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _calcTotal = CalculateOrderTotalUseCase(_orders, _customers);
    _checkUpgrade = CheckUpgradeEligibilityUseCase(_orders, _customers);
    _runUseCases();
  }

  Future<void> _runUseCases() async {
    setState(() => _loading = true);
    final summary = await _calcTotal.execute('o1', 'c1');
    final upgrade = await _checkUpgrade.execute('c1');
    setState(() {
      _summary = summary;
      _upgradeResult = upgrade;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Use Cases'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // When to use vs when to skip
                Card(
                  color: Colors.indigo.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rule: Create a UseCase only if it contains real business logic.',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('✅ DO create: combines repos, has discount/tax logic, reused in multiple places'),
                        Text('❌ DON\'T create: just forwarding to repository (passthrough)'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (_summary != null) ...[
                  Text('CalculateOrderTotalUseCase',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer: ${_summary!.customerName} (${_summary!.customerTier})'),
                          const Divider(),
                          _row('Subtotal', _summary!.subtotal),
                          _row(
                            'Discount (${(_summary!.discountRate * 100).round()}%)',
                            -_summary!.discountAmount,
                            color: Colors.green,
                          ),
                          _row('VAT (11%)', _summary!.vatAmount),
                          const Divider(),
                          _row('TOTAL', _summary!.total,
                              bold: true, color: Colors.indigo),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (_upgradeResult != null) ...[
                  Text('CheckUpgradeEligibilityUseCase',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: Icon(
                        _upgradeResult!.isEligible
                            ? Icons.star
                            : Icons.star_border,
                        color: _upgradeResult!.isEligible
                            ? Colors.amber
                            : Colors.grey,
                        size: 36,
                      ),
                      title: Text(_upgradeResult!.isEligible
                          ? 'Eligible for upgrade!'
                          : 'Not eligible yet'),
                      subtitle: Text(_upgradeResult!.reason),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _row(String label, double amount,
      {bool bold = false, Color? color}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: color,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('Rp ${amount.abs().toStringAsFixed(0)}',
              style: style.copyWith(
                  color: amount < 0 ? Colors.green : color)),
        ],
      ),
    );
  }
}
