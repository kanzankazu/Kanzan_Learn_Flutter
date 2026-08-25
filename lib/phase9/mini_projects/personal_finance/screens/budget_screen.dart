/// Budget Screen — Personal Finance Manager
import 'package:flutter/material.dart';
import '../domain/entities/budget.dart';
import '../domain/entities/transaction.dart';
import '../widgets/amount_display.dart';

/// Shows monthly budget limits per category with progress bars.
class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  // Sample budget data (replace with Riverpod provider in a full app)
  static final _budgets = [
    (
      budget: Budget(id: 'b1', category: TransactionCategory.food, limitAmount: 1500000, month: DateTime(2026, 8)),
      spent: 860000.0,
    ),
    (
      budget: Budget(id: 'b2', category: TransactionCategory.transport, limitAmount: 500000, month: DateTime(2026, 8)),
      spent: 345000.0,
    ),
    (
      budget: Budget(id: 'b3', category: TransactionCategory.entertainment, limitAmount: 400000, month: DateTime(2026, 8)),
      spent: 410000.0, // over budget!
    ),
    (
      budget: Budget(id: 'b4', category: TransactionCategory.shopping, limitAmount: 800000, month: DateTime(2026, 8)),
      spent: 220000.0,
    ),
    (
      budget: Budget(id: 'b5', category: TransactionCategory.health, limitAmount: 300000, month: DateTime(2026, 8)),
      spent: 0.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Month header
          Text('August 2026',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Tap a category to see its transactions',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),

          ..._budgets.map((entry) =>
              _BudgetCard(budget: entry.budget, spent: entry.spent)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Set Budget'),
      ),
    );
  }
}

/// Card showing a single budget category with a progress bar.
class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final double spent;

  const _BudgetCard({required this.budget, required this.spent});

  @override
  Widget build(BuildContext context) {
    final progress = budget.progress(spent);
    final isOver = budget.isExceeded(spent);
    final remaining = budget.remaining(spent);
    final barColor = isOver ? Colors.red : (progress > 0.8 ? Colors.orange : Colors.green);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category header row
            Row(
              children: [
                Text(budget.category.emoji,
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(budget.category.label,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                // Over-budget warning badge
                if (isOver)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Over budget!',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(barColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),

            // Spent / limit row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Text('Spent: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  AmountDisplay(amount: spent, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ]),
                Row(children: [
                  Text('Limit: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  AmountDisplay(amount: budget.limitAmount, style: const TextStyle(fontSize: 12)),
                ]),
              ],
            ),

            // Remaining amount
            const SizedBox(height: 4),
            Text(
              isOver
                  ? 'Over by ${_fmt(-remaining)}'
                  : '${_fmt(remaining)} remaining',
              style: TextStyle(
                  fontSize: 12,
                  color: isOver ? Colors.red : Colors.green.shade700,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) => 'Rp${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
}
