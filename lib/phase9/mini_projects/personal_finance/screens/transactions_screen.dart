/// Transactions Screen — Personal Finance Manager
import 'package:flutter/material.dart';
import '../domain/entities/transaction.dart';
import '../widgets/transaction_list_tile.dart';
import '../widgets/amount_display.dart';

/// Displays a searchable, filterable list of all transactions.
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _search = '';
  TransactionType? _filterType;

  // Sample data (replace with Riverpod provider in a full app)
  final List<Transaction> _allTransactions = [
    Transaction(id: 't1', walletId: 'w1', amount: 45000, note: 'Lunch at Warteg', date: DateTime(2026, 8, 24), type: TransactionType.expense, category: TransactionCategory.food),
    Transaction(id: 't2', walletId: 'w1', amount: 8500000, note: 'Monthly salary', date: DateTime(2026, 8, 23), type: TransactionType.income, category: TransactionCategory.salary),
    Transaction(id: 't3', walletId: 'w1', amount: 25000, note: 'Bus ticket', date: DateTime(2026, 8, 23), type: TransactionType.expense, category: TransactionCategory.transport),
    Transaction(id: 't4', walletId: 'w2', amount: 120000, note: 'Weekly grocery', date: DateTime(2026, 8, 22), type: TransactionType.expense, category: TransactionCategory.shopping),
    Transaction(id: 't5', walletId: 'w1', amount: 500000, note: 'Freelance logo design', date: DateTime(2026, 8, 21), type: TransactionType.income, category: TransactionCategory.freelance),
    Transaction(id: 't6', walletId: 'w1', amount: 350000, note: 'Electricity bill', date: DateTime(2026, 8, 20), type: TransactionType.expense, category: TransactionCategory.housing),
    Transaction(id: 't7', walletId: 'w1', amount: 80000, note: 'Cinema ticket', date: DateTime(2026, 8, 18), type: TransactionType.expense, category: TransactionCategory.entertainment),
    Transaction(id: 't8', walletId: 'w2', amount: 200000, note: 'Grab transfer to cash', date: DateTime(2026, 8, 17), type: TransactionType.transfer, category: TransactionCategory.transfer),
  ];

  List<Transaction> get _filtered => _allTransactions.where((t) {
        final matchSearch = _search.isEmpty ||
            t.note.toLowerCase().contains(_search.toLowerCase()) ||
            t.category.label.toLowerCase().contains(_search.toLowerCase());
        final matchType = _filterType == null || t.type == _filterType;
        return matchSearch && matchType;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final totalIncome = filtered
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final totalExpense = filtered
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search transactions…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          // Type filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _chip('All', null),
                const SizedBox(width: 8),
                _chip('Income', TransactionType.income),
                const SizedBox(width: 8),
                _chip('Expense', TransactionType.expense),
                const SizedBox(width: 8),
                _chip('Transfer', TransactionType.transfer),
              ],
            ),
          ),

          // Summary row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: _summaryTile('Income', totalIncome, Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: _summaryTile('Expense', totalExpense, Colors.red)),
              ],
            ),
          ),

          // Transaction list
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No transactions found'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) =>
                        TransactionListTile(transaction: filtered[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, // Would open AddTransactionSheet
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  Widget _chip(String label, TransactionType? type) => ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: _filterType == type,
        onSelected: (_) => setState(() => _filterType = type),
      );

  Widget _summaryTile(String label, double amount, Color color) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold)),
            AmountDisplay(
                amount: amount,
                style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );
}
