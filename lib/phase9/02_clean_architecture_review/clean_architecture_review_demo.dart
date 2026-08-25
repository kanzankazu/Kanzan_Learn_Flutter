/// Phase 9 — Topic 02: Clean Architecture Review
///
/// Before building the portfolio app, this topic is a quick but thorough
/// recap of Clean Architecture — the structural pattern every senior
/// Flutter dev is expected to know and apply consistently.
///
/// Key principle: the Dependency Rule.
///   Inner layers (domain) know NOTHING about outer layers (data/UI).
///   Dependencies always point inward.
///
///   ┌────────────────────────────────────────────────────────┐
///   │  Presentation  (Riverpod providers, screens, widgets)  │
///   │        ↓  depends on                                   │
///   │     Domain     (entities, use cases, repo interfaces)  │
///   │        ↑  implemented by                               │
///   │       Data     (API clients, local DB, DTOs)           │
///   └────────────────────────────────────────────────────────┘
///
/// Covered:
/// 1. Layer responsibilities — what belongs where
/// 2. Entity vs DTO vs Model — the naming confusion solved
/// 3. Repository pattern — abstraction that separates domain from data
/// 4. Use Case — when to create one vs when to skip
/// 5. Dependency injection wiring (get_it)
/// 6. Full data-flow trace: UI tap → UseCase → Repository → API → back
/// 7. Folder structure for a feature (vertical slice)
import 'package:flutter/material.dart';

/// Standalone entry point.
void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean Architecture Review',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const CleanArchitectureReviewDemo(),
    );
  }
}

/// Demo screen — a compact but complete Clean Architecture reference.
class CleanArchitectureReviewDemo extends StatelessWidget {
  const CleanArchitectureReviewDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('02 — Clean Architecture Review'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Visual dependency diagram ──────────────────────────────────────
          _card(
            color: Colors.deepOrange.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('The Dependency Rule',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  'Presentation  →  Domain  ←  Data\n\n'
                  '• Domain never imports from Presentation or Data\n'
                  '• Data implements interfaces defined in Domain\n'
                  '• Presentation calls Domain use cases / repo interfaces\n'
                  '• This means Domain can be tested with ZERO Flutter dependencies',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── 1. Layer responsibilities ─────────────────────────────────────
          _header('1. Layer Responsibilities', Colors.deepOrange),
          _layerCard(
            layer: 'Domain',
            color: Colors.blue,
            description: 'Pure Dart. No Flutter, no http, no firebase.',
            contains: const [
              'Entities — plain Dart classes (User, Transaction, Budget)',
              'Repository interfaces — abstract classes (IUserRepository)',
              'Use cases — one class per business action (GetTransactionsUseCase)',
              'Value objects — validated wrappers (Email, Amount, DateRange)',
            ],
          ),
          _layerCard(
            layer: 'Data',
            color: Colors.green,
            description:
                'Implements domain interfaces. Knows about HTTP, Firebase, SQLite.',
            contains: const [
              'DTOs — classes that match the API/DB schema exactly',
              'Repository implementations — FirebaseTransactionRepository',
              'Remote data sources — TransactionApiClient (Dio)',
              'Local data sources — TransactionDao (Isar / SQLite)',
              'Mappers — DTO → Entity, Entity → DTO',
            ],
          ),
          _layerCard(
            layer: 'Presentation',
            color: Colors.purple,
            description: 'Flutter widgets and state management. No business logic.',
            contains: const [
              'Screens / pages — TransactionListScreen',
              'Widgets — TransactionCard, AmountDisplay',
              'State (Riverpod) — transactionListProvider, AsyncNotifier',
              'ViewModels / Controllers — hold UI state, call use cases',
            ],
          ),

          const SizedBox(height: 16),

          // ── 2. Entity vs DTO vs Model ─────────────────────────────────────
          _header('2. Entity vs DTO vs Model', Colors.indigo),
          _code('''
// ── Entity (Domain layer) ─────────────────────────────────────────────────
// Pure business object. No JSON serialization. No annotations.
// The canonical truth of what a "Transaction" is in your app.
class Transaction {
  final String id;
  final double amount;    // always in the base currency
  final String note;
  final DateTime date;
  final TransactionType type; // income | expense | transfer

  const Transaction({
    required this.id,
    required this.amount,
    required this.note,
    required this.date,
    required this.type,
  });
}

// ── DTO (Data layer) ──────────────────────────────────────────────────────
// Mirrors the API / Firestore document shape EXACTLY.
// Can have fromJson / toJson. May have different field names than the Entity.
class TransactionDto {
  final String id;
  final double amount;
  final String note;
  final String date;       // ISO 8601 string from the API
  final String txType;     // API uses "txType", not "type"

  const TransactionDto({...});

  factory TransactionDto.fromJson(Map<String, dynamic> json) => TransactionDto(
    id: json['id'] as String,
    amount: (json['amount'] as num).toDouble(),
    note: json['note'] as String,
    date: json['date'] as String,
    txType: json['txType'] as String,
  );
}

// ── Mapper (Data layer) ───────────────────────────────────────────────────
// Converts between DTO ↔ Entity. Lives in the data layer.
class TransactionMapper {
  static Transaction toEntity(TransactionDto dto) => Transaction(
    id: dto.id,
    amount: dto.amount,
    note: dto.note,
    date: DateTime.parse(dto.date),          // string → DateTime
    type: TransactionType.fromString(dto.txType),
  );

  static TransactionDto toDto(Transaction entity) => TransactionDto(
    id: entity.id,
    amount: entity.amount,
    note: entity.note,
    date: entity.date.toIso8601String(),     // DateTime → string
    txType: entity.type.name,
  );
}'''),

          const SizedBox(height: 16),

          // ── 3. Repository pattern ─────────────────────────────────────────
          _header('3. Repository Pattern', Colors.teal),
          _code('''
// ── Interface (Domain layer) ──────────────────────────────────────────────
// Domain defines WHAT it needs, not HOW it is fulfilled.
// This is what lets you swap Firebase for REST or vice versa without
// touching a single line of domain or presentation code.
abstract interface class ITransactionRepository {
  /// Returns the most recent [limit] transactions for [walletId].
  Future<Result<List<Transaction>>> getTransactions({
    required String walletId,
    int limit = 20,
  });

  /// Saves a new transaction and returns the saved entity.
  Future<Result<Transaction>> addTransaction(Transaction transaction);

  /// Permanently removes a transaction.
  Future<Result<void>> deleteTransaction(String id);
}

// ── Implementation (Data layer) ───────────────────────────────────────────
// Data layer knows about Firebase. Domain does not.
class FirebaseTransactionRepository implements ITransactionRepository {
  final TransactionRemoteDataSource _remote;
  final TransactionLocalDataSource _local;

  const FirebaseTransactionRepository(this._remote, this._local);

  @override
  Future<Result<List<Transaction>>> getTransactions({
    required String walletId,
    int limit = 20,
  }) async {
    try {
      // Try remote first; fall back to local cache on error
      final dtos = await _remote.fetchTransactions(walletId, limit);
      await _local.cacheTransactions(dtos);          // update cache
      return Success(dtos.map(TransactionMapper.toEntity).toList());
    } catch (e, stack) {
      // Try local cache before giving up
      final cached = await _local.getCachedTransactions(walletId, limit);
      if (cached.isNotEmpty) {
        return Success(cached.map(TransactionMapper.toEntity).toList());
      }
      return Failure(AppError.fromException(e, stack));
    }
  }
}'''),

          const SizedBox(height: 16),

          // ── 4. Use Case ───────────────────────────────────────────────────
          _header('4. Use Case — When to Create One', Colors.orange),
          _card(
            color: Colors.orange.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create a Use Case when there is business logic beyond '
                  '"just call the repository".',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 8),
                _ruleRow('✅ Create', 'Combines 2+ repositories'),
                _ruleRow('✅ Create', 'Has validation / guards (e.g. budget check)'),
                _ruleRow('✅ Create', 'Transforms / aggregates data'),
                _ruleRow('✅ Create', 'Has side effects (e.g. send notification after save)'),
                _ruleRow('❌ Skip',
                    'Passthrough — just calls repository.getX() with no logic'),
              ],
            ),
          ),
          _code('''
// ✅ Good Use Case — has real business logic
class AddTransactionUseCase {
  final ITransactionRepository _txRepo;
  final IBudgetRepository _budgetRepo;
  final INotificationService _notifications;

  const AddTransactionUseCase(
      this._txRepo, this._budgetRepo, this._notifications);

  Future<Result<Transaction>> execute(Transaction transaction) async {
    // Business rule 1: negative amounts are not allowed
    if (transaction.amount <= 0) {
      return Failure(AppError.validation('Amount must be positive'));
    }

    // Business rule 2: check if this expense exceeds the budget limit
    if (transaction.type == TransactionType.expense) {
      final budget = await _budgetRepo.getBudgetForCategory(transaction.category);
      if (budget != null && budget.wouldExceed(transaction.amount)) {
        // Business rule 3: send alert if budget is exceeded
        await _notifications.sendBudgetAlert(budget);
      }
    }

    // Delegate persistence to the repository
    return _txRepo.addTransaction(transaction);
  }
}

// ❌ Passthrough Use Case — skip this, call the repo directly from the ViewModel
class GetTransactionsUseCase {
  final ITransactionRepository _repo;
  Future<Result<List<Transaction>>> execute(String walletId) =>
      _repo.getTransactions(walletId: walletId); // zero logic — pointless wrapper
}'''),

          const SizedBox(height: 16),

          // ── 5. Full data-flow trace ───────────────────────────────────────
          _header('5. Full Data-Flow Trace', Colors.purple),
          _code('''
// User taps "Save Transaction" button

// ① Presentation layer
// TransactionFormScreen calls the ViewModel
ref.read(transactionFormProvider.notifier).saveTransaction(formData);

// ② ViewModel (Riverpod AsyncNotifier)
// Calls the use case — knows nothing about Firebase or Dio
state = await AsyncValue.guard(() =>
    ref.read(addTransactionUseCaseProvider).execute(transaction));

// ③ AddTransactionUseCase (Domain)
// Validates, checks budget, calls repository interface
final result = await _txRepo.addTransaction(transaction);

// ④ FirebaseTransactionRepository (Data)
// Converts Entity → DTO, calls remote data source
final dto = TransactionMapper.toDto(transaction);
await _remote.saveTransaction(dto);           // Firestore write
await _local.cacheTransaction(dto);           // Isar write (for offline)
return Success(TransactionMapper.toEntity(dto));

// ⑤ Back up to ViewModel
// State is updated, UI rebuilds automatically via Riverpod
// TransactionListScreen sees the new transaction immediately

// Key insight: each layer only knows about the layer directly below it.
// Firebase is NEVER mentioned in the ViewModel or Domain code.'''),

          const SizedBox(height: 16),

          // ── 6. Folder structure ───────────────────────────────────────────
          _header('6. Feature Folder Structure', Colors.brown),
          _code('''
lib/
├── core/
│   ├── config/        app_config.dart, env constants
│   ├── error/         AppError sealed class, Result<T>
│   ├── network/       DioClient, interceptors
│   └── di/            injection_container.dart (get_it setup)
│
├── features/
│   └── transactions/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── transaction_remote_data_source.dart
│       │   │   └── transaction_local_data_source.dart
│       │   ├── dto/
│       │   │   └── transaction_dto.dart
│       │   ├── mappers/
│       │   │   └── transaction_mapper.dart
│       │   └── repositories/
│       │       └── firebase_transaction_repository.dart
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   └── transaction.dart
│       │   ├── repositories/
│       │   │   └── i_transaction_repository.dart  ← interface
│       │   └── usecases/
│       │       └── add_transaction_use_case.dart
│       │
│       └── presentation/
│           ├── screens/
│           │   ├── transaction_list_screen.dart
│           │   └── transaction_form_screen.dart
│           ├── widgets/
│           │   └── transaction_card.dart
│           └── providers/
│               └── transaction_providers.dart     ← Riverpod'''),

          const SizedBox(height: 16),
          _card(
            color: Colors.deepOrange.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• Dependency Rule: imports always point inward (Presentation → Domain ← Data)'),
                Text('• Entity = domain truth; DTO = API shape; Mapper = converts between them'),
                Text('• Repository interface lives in Domain; implementation lives in Data'),
                Text('• Only create a Use Case when there is real business logic'),
                Text('• Domain layer has ZERO Flutter/Firebase/Dio imports — pure Dart'),
                Text('• This structure scales from 5 screens to 50+ without spaghetti'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ruleRow(String tag, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: tag.startsWith('✅')
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(tag, style: const TextStyle(fontSize: 11)),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
          ],
        ),
      );

  Widget _layerCard({
    required String layer,
    required Color color,
    required String description,
    required List<String> contains,
  }) =>
      Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(layer,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(description,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
                ),
              ]),
              const SizedBox(height: 8),
              ...contains.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.arrow_right, size: 16, color: color),
                        Expanded(
                            child: Text(item,
                                style: const TextStyle(fontSize: 12))),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      );
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

Widget _header(String title, Color color) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: color)),
    );

Widget _code(String code) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(code,
            style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Color(0xFFCDD6F4))),
      ),
    );

Widget _card({required Color color, required Widget child}) => Card(
      color: color,
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
