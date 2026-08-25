/// Domain repository interface: IBudgetRepository
import '../entities/budget.dart';
import '../entities/transaction.dart';

abstract interface class IBudgetRepository {
  Future<List<Budget>> getAllBudgets();
  Future<List<Budget>> getBudgetsForMonth(DateTime month);

  /// Returns the budget for [category] in the month that [month] falls in.
  /// Returns null if no budget is set for that category/month.
  Future<Budget?> getBudgetForCategoryAndMonth({
    required TransactionCategory category,
    required DateTime month,
  });

  Future<Budget> addBudget(Budget budget);
  Future<Budget> updateBudget(Budget budget);
  Future<void> deleteBudget(String id);

  Stream<List<Budget>> watchBudgetsForMonth(DateTime month);
}
