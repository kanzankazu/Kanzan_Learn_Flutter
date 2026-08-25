/// Use Case: AddTransactionUseCase
///
/// Business logic for adding a new transaction.
///
/// This use case exists (rather than calling the repository directly)
/// because it orchestrates more than one operation:
///   1. Validates the transaction data
///   2. Saves the transaction
///   3. Updates the wallet balance
///   4. Checks if the transaction pushes a budget over its limit
///
/// The ViewModel calls this use case and never touches repositories directly.
/// This keeps business rules centralized and testable in isolation.

import '../entities/transaction.dart';
import '../repositories/i_transaction_repository.dart';
import '../repositories/i_wallet_repository.dart';
import '../repositories/i_budget_repository.dart';

/// Result of the AddTransactionUseCase.
///
/// Using a sealed class (instead of throwing exceptions) makes it impossible
/// for the caller to forget to handle the error case.
sealed class AddTransactionResult {
  const AddTransactionResult();
}

/// Transaction was saved successfully.
class AddTransactionSuccess extends AddTransactionResult {
  /// The saved transaction (with server-generated ID).
  final Transaction transaction;
  const AddTransactionSuccess(this.transaction);
}

/// Validation failed — the input data was invalid.
class AddTransactionValidationError extends AddTransactionResult {
  final String message;
  const AddTransactionValidationError(this.message);
}

/// A budget limit was exceeded by this transaction.
/// Returned alongside the saved transaction so the UI can show a warning.
class AddTransactionBudgetWarning extends AddTransactionResult {
  final Transaction transaction;

  /// Name of the category whose budget was exceeded.
  final String categoryName;

  /// The limit that was exceeded.
  final double budgetLimit;

  /// How much has been spent after this transaction.
  final double totalSpent;

  const AddTransactionBudgetWarning({
    required this.transaction,
    required this.categoryName,
    required this.budgetLimit,
    required this.totalSpent,
  });
}

/// Use case that handles all business logic for adding a transaction.
///
/// Dependencies are injected via the constructor — this makes the use case
/// easy to test by passing mock repositories.
class AddTransactionUseCase {
  final ITransactionRepository _txRepo;
  final IWalletRepository _walletRepo;
  final IBudgetRepository _budgetRepo;

  const AddTransactionUseCase({
    required ITransactionRepository txRepo,
    required IWalletRepository walletRepo,
    required IBudgetRepository budgetRepo,
  })  : _txRepo = txRepo,
        _walletRepo = walletRepo,
        _budgetRepo = budgetRepo;

  /// Executes the add-transaction business flow.
  ///
  /// Steps:
  ///   1. Validate input
  ///   2. Save the transaction
  ///   3. Update the wallet balance
  ///   4. Check budget limit → warn if exceeded
  Future<AddTransactionResult> execute(Transaction transaction) async {
    // ── Step 1: Validate ───────────────────────────────────────────────────
    // Amount must be positive — the type (income/expense) determines direction.
    if (transaction.amount <= 0) {
      return const AddTransactionValidationError(
          'Amount must be greater than zero.');
    }

    // Note must not be excessively long.
    if (transaction.note.length > 200) {
      return const AddTransactionValidationError(
          'Note must be 200 characters or fewer.');
    }

    // Date must not be more than 1 year in the future (typo guard).
    final oneYearFromNow = DateTime.now().add(const Duration(days: 365));
    if (transaction.date.isAfter(oneYearFromNow)) {
      return const AddTransactionValidationError(
          'Transaction date cannot be more than 1 year in the future.');
    }

    // ── Step 2: Save the transaction ───────────────────────────────────────
    final saved = await _txRepo.addTransaction(transaction);

    // ── Step 3: Update wallet balance ──────────────────────────────────────
    // Increment for income, decrement for expense. Transfer is neutral.
    final delta = switch (transaction.type) {
      TransactionType.income => transaction.amount,
      TransactionType.expense => -transaction.amount,
      TransactionType.transfer => 0.0, // handled separately with source+dest wallets
    };

    if (delta != 0) {
      await _walletRepo.adjustBalance(
        walletId: transaction.walletId,
        delta: delta,
      );
    }

    // ── Step 4: Budget check (expense only) ────────────────────────────────
    if (transaction.type == TransactionType.expense) {
      // Load the budget for this category in this month (if any).
      final budget = await _budgetRepo.getBudgetForCategoryAndMonth(
        category: transaction.category,
        month: transaction.date,
      );

      if (budget != null) {
        // Sum all expenses in this category for the month.
        final txsThisMonth =
            await _txRepo.getTransactionsByCategoryAndMonth(
          category: transaction.category,
          month: transaction.date,
        );
        final totalSpent = txsThisMonth
            .where((t) => t.type == TransactionType.expense)
            .fold(0.0, (sum, t) => sum + t.amount);

        // Warn if the budget limit has been reached or exceeded.
        if (budget.isExceeded(totalSpent)) {
          return AddTransactionBudgetWarning(
            transaction: saved,
            categoryName: transaction.category.label,
            budgetLimit: budget.limitAmount,
            totalSpent: totalSpent,
          );
        }
      }
    }

    return AddTransactionSuccess(saved);
  }
}
