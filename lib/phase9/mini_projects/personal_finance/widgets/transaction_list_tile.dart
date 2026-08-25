/// Reusable transaction list tile widget.
import 'package:flutter/material.dart';
import '../domain/entities/transaction.dart';

/// Displays a single transaction in a compact list tile format.
///
/// Shows: category emoji, note, date on the left,
/// and the amount (colored by type: green for income, red for expense) on the right.
class TransactionListTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionListTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    // Color the amount based on transaction type
    final amountColor = switch (transaction.type) {
      TransactionType.income => Colors.green.shade700,
      TransactionType.expense => Colors.red.shade700,
      TransactionType.transfer => Colors.blue.shade700,
    };

    // Sign prefix: + for income, - for expense
    final prefix = switch (transaction.type) {
      TransactionType.income => '+',
      TransactionType.expense => '-',
      TransactionType.transfer => '⇄',
    };

    return ListTile(
      dense: true,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: amountColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(transaction.category.emoji,
            style: const TextStyle(fontSize: 18)),
      ),
      title: Text(
        transaction.note.isEmpty ? transaction.category.label : transaction.note,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${_formatDate(transaction.date)} · ${transaction.category.label}',
        style: const TextStyle(fontSize: 11),
      ),
      trailing: Text(
        '$prefix${_formatAmount(transaction.amount)}',
        style: TextStyle(
          color: amountColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}

/// Formats a monetary amount as "1.250.000" (Indonesian dot-thousands).
String _formatAmount(double value) {
  final parts = value.toStringAsFixed(0).split('');
  final result = StringBuffer();
  for (var i = 0; i < parts.length; i++) {
    if (i > 0 && (parts.length - i) % 3 == 0) result.write('.');
    result.write(parts[i]);
  }
  return result.toString();
}
