/// Dashboard Screen — Personal Finance Manager
///
/// The first screen users see. Shows:
/// - Net worth (total of all wallet balances)
/// - This month's income vs expense summary
/// - Monthly trend bar chart (Custom Painter)
/// - Quick-access buttons for recent wallets
/// - Latest 5 transactions
///
/// Architecture notes:
/// - Uses SliverAppBar for the collapsing header effect (Phase 6 — Slivers)
/// - Custom Painter for the bar chart (Phase 6 — Custom Painter)
/// - Loads data from fake in-memory data so the demo runs without Hive setup
import 'package:flutter/material.dart';

import '../domain/entities/transaction.dart';
import '../domain/entities/wallet.dart';
import '../widgets/amount_display.dart';
import '../widgets/transaction_list_tile.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/wallet_card.dart';

/// Dashboard screen — combines SliverAppBar, charts, and live data.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Sample data (replaces real Riverpod providers in a full app) ─────────
    // In production: replace with `ref.watch(dashboardProvider)` (Riverpod).
    const netWorth = 12450000.0;
    const monthIncome = 8500000.0;
    const monthExpense = 3275000.0;

    // Six months of (income, expense) pairs for the bar chart
    const monthlyData = [
      (7200000.0, 2900000.0),
      (8100000.0, 3100000.0),
      (7800000.0, 2750000.0),
      (9000000.0, 3400000.0),
      (8200000.0, 2980000.0),
      (8500000.0, 3275000.0),
    ];

    final wallets = [
      Wallet(id: '1', name: 'Cash', balance: 1200000, type: WalletType.cash, colorValue: 0xFF2E7D32),
      Wallet(id: '2', name: 'BCA', balance: 8750000, type: WalletType.bank, colorValue: 0xFF0D47A1),
      Wallet(id: '3', name: 'GoPay', balance: 2500000, type: WalletType.eWallet, colorValue: 0xFF1565C0),
    ];

    final recentTransactions = [
      Transaction(id: 't1', walletId: '2', amount: 45000, note: 'Lunch', date: DateTime.now().subtract(const Duration(hours: 2)), type: TransactionType.expense, category: TransactionCategory.food),
      Transaction(id: 't2', walletId: '2', amount: 8500000, note: 'Monthly salary', date: DateTime.now().subtract(const Duration(days: 1)), type: TransactionType.income, category: TransactionCategory.salary),
      Transaction(id: 't3', walletId: '1', amount: 25000, note: 'Bus ticket', date: DateTime.now().subtract(const Duration(days: 1)), type: TransactionType.expense, category: TransactionCategory.transport),
      Transaction(id: 't4', walletId: '3', amount: 120000, note: 'Grocery', date: DateTime.now().subtract(const Duration(days: 2)), type: TransactionType.expense, category: TransactionCategory.shopping),
      Transaction(id: 't5', walletId: '2', amount: 500000, note: 'Freelance project', date: DateTime.now().subtract(const Duration(days: 3)), type: TransactionType.income, category: TransactionCategory.freelance),
    ];

    return CustomScrollView(
      slivers: [
        // ── Collapsing app bar with net worth ─────────────────────────────
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          title: const Text('Finance Manager'),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primaryContainer,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 48), // avoid status bar overlap
                  const Text('Net Worth',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  AmountDisplay(
                    amount: netWorth,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Income vs Expense summary row ─────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Income card
                Expanded(
                  child: _SummaryCard(
                    label: 'Income',
                    amount: monthIncome,
                    color: Colors.green,
                    icon: Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 12),
                // Expense card
                Expanded(
                  child: _SummaryCard(
                    label: 'Expenses',
                    amount: monthExpense,
                    color: Colors.red,
                    icon: Icons.arrow_upward,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Monthly trend bar chart ───────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('6-Month Trend',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                const SizedBox(height: 8),
                // Custom Painter chart (Phase 6)
                MonthlyBarChart(data: monthlyData),
              ],
            ),
          ),
        ),

        // ── Wallet cards ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text('My Wallets',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: wallets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => WalletCard(wallet: wallets[i]),
            ),
          ),
        ),

        // ── Recent transactions ───────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {},
                  child: const Text('See all'),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => TransactionListTile(
                transaction: recentTransactions[i]),
            childCount: recentTransactions.length,
          ),
        ),

        // Safe area padding at the bottom
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

/// A small summary card showing total income or expense for the month.
class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Colored icon badge
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Text(label,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            AmountDisplay(
              amount: amount,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }
}
