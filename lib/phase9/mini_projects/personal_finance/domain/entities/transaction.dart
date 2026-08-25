/// Domain entity: Transaction
///
/// A Transaction is the fundamental unit of the finance app — every income,
/// expense, or transfer is a Transaction.
///
/// Design decisions:
/// - Pure Dart class: NO Flutter, NO Hive annotations, NO JSON serialization.
///   This keeps the domain layer framework-agnostic and easy to unit-test.
/// - Immutable: all fields are final. Mutation = create a new instance via copyWith().
/// - Validated: TransactionType.fromString() throws on invalid input, preventing
///   silent data corruption.
///
/// See also:
///   [TransactionDto]   — the Hive/JSON representation in the data layer
///   [TransactionMapper] — converts between TransactionDto ↔ Transaction

/// The type of a financial transaction.
///
/// [income]   — money coming in (salary, freelance payment, gift)
/// [expense]  — money going out (food, rent, transport)
/// [transfer] — money moving between two wallets (no net effect on net worth)
enum TransactionType {
  income,
  expense,
  transfer;

  /// Parses a raw string from the data layer into a [TransactionType].
  ///
  /// Throws [ArgumentError] on unknown values so data bugs surface immediately
  /// rather than silently defaulting to the wrong type.
  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => throw ArgumentError('Unknown TransactionType: "$value"'),
    );
  }
}

/// The expense/income category used to group transactions for budgeting.
///
/// In a real app you would let users create custom categories. Here we use
/// a fixed enum to keep the demo simple while still showing the pattern.
enum TransactionCategory {
  food,
  transport,
  housing,
  health,
  entertainment,
  education,
  shopping,
  salary,
  freelance,
  investment,
  transfer,
  other;

  /// Human-readable label shown in the UI.
  String get label => switch (this) {
        food => 'Food & Drink',
        transport => 'Transport',
        housing => 'Housing',
        health => 'Health',
        entertainment => 'Entertainment',
        education => 'Education',
        shopping => 'Shopping',
        salary => 'Salary',
        freelance => 'Freelance',
        investment => 'Investment',
        transfer => 'Transfer',
        other => 'Other',
      };

  /// Icon representing this category in the transaction list.
  String get emoji => switch (this) {
        food => '🍔',
        transport => '🚗',
        housing => '🏠',
        health => '💊',
        entertainment => '🎬',
        education => '📚',
        shopping => '🛍️',
        salary => '💼',
        freelance => '💻',
        investment => '📈',
        transfer => '🔄',
        other => '📦',
      };
}

/// An immutable domain entity representing a single financial transaction.
///
/// Example:
/// ```dart
/// final tx = Transaction(
///   id: 'tx_001',
///   walletId: 'wallet_cash',
///   amount: 45000,
///   note: 'Lunch at Warung Makan',
///   date: DateTime(2026, 8, 24),
///   type: TransactionType.expense,
///   category: TransactionCategory.food,
/// );
/// ```
class Transaction {
  /// Unique identifier (UUID or Firestore document ID).
  final String id;

  /// ID of the wallet this transaction belongs to.
  final String walletId;

  /// Transaction amount in the app's base currency (IDR).
  /// Always positive — [type] determines whether it is income or expense.
  final double amount;

  /// Optional user note / description for this transaction.
  final String note;

  /// When this transaction occurred.
  final DateTime date;

  /// Whether this is income, expense, or a transfer.
  final TransactionType type;

  /// Category for budgeting and analytics.
  final TransactionCategory category;

  const Transaction({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.note,
    required this.date,
    required this.type,
    required this.category,
  });

  /// Returns a copy of this transaction with the specified fields replaced.
  ///
  /// Useful for edit operations: `tx.copyWith(amount: 50000)`.
  Transaction copyWith({
    String? id,
    String? walletId,
    double? amount,
    String? note,
    DateTime? date,
    TransactionType? type,
    TransactionCategory? category,
  }) =>
      Transaction(
        id: id ?? this.id,
        walletId: walletId ?? this.walletId,
        amount: amount ?? this.amount,
        note: note ?? this.note,
        date: date ?? this.date,
        type: type ?? this.type,
        category: category ?? this.category,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Transaction(id: $id, amount: $amount, type: $type, date: $date)';
}
