/// Domain entity: Budget
///
/// A Budget defines a spending limit for a specific category in a given month.
/// The app compares actual spending (sum of expense transactions in that
/// category/month) against the budget limit to show a progress indicator.
///
/// Key business rules:
/// - limitAmount must be > 0
/// - One budget per category per month (enforced at use-case layer)
/// - spent is computed — never stored directly in the entity

import 'transaction.dart';

/// An immutable entity representing a monthly spending budget for one category.
class Budget {
  /// Unique identifier.
  final String id;

  /// The expense category this budget covers.
  final TransactionCategory category;

  /// Maximum allowed spending for the month in base currency (IDR).
  final double limitAmount;

  /// The year + month this budget applies to.
  /// Only year and month are significant — day/time is ignored.
  final DateTime month;

  const Budget({
    required this.id,
    required this.category,
    required this.limitAmount,
    required this.month,
  });

  // ── Computed helpers ───────────────────────────────────────────────────────

  /// Returns the percentage of the budget spent (0.0 – 1.0, clamped).
  ///
  /// [spentAmount] is passed in from the use case / ViewModel —
  /// it is NOT stored on the entity because it depends on live transaction data.
  double progress(double spentAmount) =>
      (spentAmount / limitAmount).clamp(0.0, 1.0);

  /// Returns true if [spentAmount] has reached or exceeded [limitAmount].
  bool isExceeded(double spentAmount) => spentAmount >= limitAmount;

  /// Returns the remaining budget. Can be negative if over budget.
  double remaining(double spentAmount) => limitAmount - spentAmount;

  // ── Mutation ───────────────────────────────────────────────────────────────

  Budget copyWith({
    String? id,
    TransactionCategory? category,
    double? limitAmount,
    DateTime? month,
  }) =>
      Budget(
        id: id ?? this.id,
        category: category ?? this.category,
        limitAmount: limitAmount ?? this.limitAmount,
        month: month ?? this.month,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Budget && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Budget(category: ${category.name}, limit: $limitAmount, month: ${month.year}-${month.month})';
}
