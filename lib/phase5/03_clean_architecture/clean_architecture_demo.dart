/// Demo 03 — Clean Architecture Layers.
///
/// Clean Architecture (by Robert C. Martin) organizes code into concentric
/// layers where dependencies always point INWARD — toward the business rules.
/// The inner layers know NOTHING about the outer layers.
///
/// **The three layers we use in Flutter:**
///
/// ```
///  ┌─────────────────────────────────────┐
///  │  PRESENTATION (UI)                  │  ← Widgets, ViewModels, BLoC
///  │  ┌─────────────────────────────┐    │
///  │  │  DOMAIN (Business Logic)    │    │  ← Entities, Use Cases, Repo Interfaces
///  │  │  ┌───────────────────┐      │    │
///  │  │  │  DATA (External)  │      │    │  ← API, DB, Cache, DTOs
///  │  │  └───────────────────┘      │    │
///  │  └─────────────────────────────┘    │
///  └─────────────────────────────────────┘
/// ```
///
/// Wait — that's wrong. The dependency arrows point INWARD:
/// DATA depends on DOMAIN (implements the repo interfaces).
/// PRESENTATION depends on DOMAIN (calls use cases).
/// DOMAIN depends on NOTHING.
///
/// **Folder structure in Flutter:**
/// ```
/// lib/
/// └── features/
///     └── products/
///         ├── data/
///         │   ├── datasources/    ← API calls, local DB queries
///         │   ├── models/         ← DTOs (JSON ↔ Domain entities)
///         │   └── repositories/   ← implements domain/repositories/
///         ├── domain/
///         │   ├── entities/       ← pure Dart classes, no frameworks
///         │   ├── repositories/   ← abstract interfaces
///         │   └── usecases/       ← one file per use case
///         └── presentation/
///             ├── screens/
///             ├── widgets/
///             └── viewmodels/     ← or bloc/, cubit/
/// ```
///
/// How to run: `flutter run -t lib/phase5/03_clean_architecture/clean_architecture_demo.dart`
library;

import 'dart:async';
import 'package:flutter/material.dart';

// ═════════════════════════════════════════════════════════════════════════════
// DOMAIN LAYER — the core of the application
// No imports from data or presentation layers.
// No Flutter widgets. No Dio. No Hive. Pure Dart.
// ═════════════════════════════════════════════════════════════════════════════

// ── Domain Entity ─────────────────────────────────────────────────────────────

/// A Product entity — the domain object.
///
/// This is a pure Dart class with no framework dependencies.
/// It represents the business concept of a "product" in the app's domain.
///
/// Key rule: domain entities must NOT contain:
/// - `fromJson()` methods (that belongs in data/models)
/// - Widget imports
/// - Database annotations
/// Just business concepts and maybe simple business rules.
class Product {
  final String id;
  final String name;
  final double price;
  final int stockCount;
  final String category;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stockCount,
    required this.category,
  });

  /// A simple domain business rule: is this product available to purchase?
  /// Business logic lives on the entity — not in the UI, not in a service.
  bool get isInStock => stockCount > 0;

  /// Another business rule: is this a premium-priced product?
  bool get isPremium => price > 500000;
}

// ── Domain Repository Interface ────────────────────────────────────────────────

/// Abstract product repository — defined in the DOMAIN layer.
///
/// This interface is the "port" (from hexagonal architecture).
/// The domain layer says: "I need something that can get and filter products."
/// The data layer provides the "adapter" that fulfills this contract.
///
/// Dependency direction: DATA → DOMAIN (data implements this interface).
/// DOMAIN never imports data. This is the key to Clean Architecture.
abstract class ProductRepository {
  Future<List<Product>> getAll();
  Future<List<Product>> getByCategory(String category);
  Future<Product?> getById(String id);
}

// ── Domain Use Cases ──────────────────────────────────────────────────────────

/// Use Case: get all products, filtered and sorted.
///
/// A Use Case encapsulates a single user interaction or business operation.
/// See Demo 04 for a deep dive into when to use Use Cases.
///
/// This use case adds value over a raw repository call:
/// - Filters out out-of-stock products if [inStockOnly] is true
/// - Sorts by price
class GetProductsUseCase {
  /// Injected via constructor — depends on the abstraction, not a concrete class.
  final ProductRepository _repository;

  GetProductsUseCase(this._repository);

  /// Execute the use case.
  ///
  /// [category] — filter by category; null = all categories.
  /// [inStockOnly] — if true, only return products with stock > 0.
  Future<List<Product>> execute({
    String? category,
    bool inStockOnly = false,
  }) async {
    // Fetch data from the repository (which decides where data comes from)
    final products = category != null
        ? await _repository.getByCategory(category)
        : await _repository.getAll();

    // Apply business rule: filter and sort
    var result = products;
    if (inStockOnly) {
      result = result.where((p) => p.isInStock).toList();
    }
    // Sort by price ascending — a consistent business rule
    result.sort((a, b) => a.price.compareTo(b.price));
    return result;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DATA LAYER — implements the domain interfaces
// Knows about HTTP, JSON, databases. Depends on DOMAIN (implements interfaces).
// ═════════════════════════════════════════════════════════════════════════════

// ── Data Transfer Object (DTO) ────────────────────────────────────────────────

/// ProductDto — the "raw" data format from an API or database.
///
/// DTOs are separate from domain entities because:
/// 1. API field names may differ (snake_case, different names)
/// 2. APIs might return extra fields you don't want in your domain
/// 3. Domain entities should not know about JSON or DB schemas
///
/// The mapping (DTO → Entity) is the data layer's responsibility.
class ProductDto {
  final String id;
  final String name;
  final double price;
  final int stock_count; // snake_case from API
  final String category;

  const ProductDto({
    required this.id,
    required this.name,
    required this.price,
    required this.stock_count,
    required this.category,
  });

  /// fromJson — parses the raw API response.
  factory ProductDto.fromJson(Map<String, dynamic> json) => ProductDto(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        stock_count: json['stock_count'] as int,
        category: json['category'] as String,
      );

  /// toDomain — converts this DTO to a domain [Product] entity.
  /// This is the only place that knows about both the API format AND the domain.
  Product toDomain() => Product(
        id: id,
        name: name,
        price: price,
        stockCount: stock_count, // field name translation
        category: category,
      );
}

// ── Remote Data Source ────────────────────────────────────────────────────────

/// Simulates an API data source.
///
/// In a real app this would use Dio to call a real endpoint.
/// The repository would call this class; the domain never does.
class ProductRemoteDataSource {
  static final _products = [
    {'id': '1', 'name': 'Laptop Pro', 'price': 18000000.0, 'stock_count': 5, 'category': 'Electronics'},
    {'id': '2', 'name': 'Wireless Mouse', 'price': 250000.0, 'stock_count': 0, 'category': 'Electronics'},
    {'id': '3', 'name': 'Dart Programming Book', 'price': 350000.0, 'stock_count': 12, 'category': 'Books'},
    {'id': '4', 'name': 'Flutter Design Book', 'price': 280000.0, 'stock_count': 8, 'category': 'Books'},
    {'id': '5', 'name': 'Standing Desk', 'price': 3500000.0, 'stock_count': 2, 'category': 'Furniture'},
    {'id': '6', 'name': 'Office Chair', 'price': 2800000.0, 'stock_count': 0, 'category': 'Furniture'},
  ];

  Future<List<ProductDto>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _products
        .map((e) => ProductDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

// ── Repository Implementation ──────────────────────────────────────────────────

/// Concrete implementation of [ProductRepository].
///
/// This class lives in the DATA layer and DEPENDS ON the DOMAIN interface.
/// It "plugs into" the domain like an adapter.
///
/// Responsibilities:
/// 1. Calls the data source (API, DB, cache)
/// 2. Converts DTOs → domain entities (via toDomain())
/// 3. Handles data-source-specific errors (rethrows as domain exceptions)
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remote;

  ProductRepositoryImpl(this._remote);

  @override
  Future<List<Product>> getAll() async {
    final dtos = await _remote.fetchAll();
    // Convert every DTO to a domain entity before returning to domain/presentation
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<List<Product>> getByCategory(String category) async {
    final all = await getAll();
    return all.where((p) => p.category == category).toList();
  }

  @override
  Future<Product?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null; // not found
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PRESENTATION LAYER — UI and ViewModel
// Depends on DOMAIN only. Never imports data layer directly.
// ═════════════════════════════════════════════════════════════════════════════

/// ViewModel for the product list.
///
/// Only depends on [GetProductsUseCase] from the domain layer.
/// Never imports ProductDto, ProductRemoteDataSource, or any HTTP/DB code.
class ProductViewModel extends ChangeNotifier {
  final GetProductsUseCase _getProducts;

  ProductViewModel(this._getProducts);

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  bool _inStockOnly = false;
  String? _selectedCategory;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get inStockOnly => _inStockOnly;
  String? get selectedCategory => _selectedCategory;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _getProducts.execute(
        category: _selectedCategory,
        inStockOnly: _inStockOnly,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setInStockOnly(bool value) {
    _inStockOnly = value;
    load();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    load();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dependency wiring — connects the layers
// In a real app this is done by a DI container (get_it or Riverpod providers).
// ─────────────────────────────────────────────────────────────────────────────

/// Manually wires up the dependency graph.
///
/// Order: data → domain → presentation
/// 1. Create data sources
/// 2. Create repositories (inject data sources)
/// 3. Create use cases (inject repositories)
/// 4. Create ViewModels (inject use cases)
ProductViewModel buildProductViewModel() {
  // Data layer
  final dataSource = ProductRemoteDataSource();
  final repository = ProductRepositoryImpl(dataSource);

  // Domain layer
  final getProducts = GetProductsUseCase(repository);

  // Presentation layer
  return ProductViewModel(getProducts);
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class CleanArchitectureDemo extends StatelessWidget {
  const CleanArchitectureDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean Architecture Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const _ProductListScreen(),
    );
  }
}

class _ProductListScreen extends StatefulWidget {
  const _ProductListScreen();

  @override
  State<_ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<_ProductListScreen> {
  late final ProductViewModel _vm;

  static const _categories = ['All', 'Electronics', 'Books', 'Furniture'];

  @override
  void initState() {
    super.initState();
    _vm = buildProductViewModel();
    _vm.addListener(() => setState(() {}));
    _vm.load();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clean Architecture'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Layer diagram
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.deepOrange.shade50,
            child: const Text(
              'Layers: PRESENTATION → DOMAIN ← DATA\n'
              'Arrows = dependency direction. Data & Presentation both depend on Domain.\n'
              'Domain depends on NOTHING — it\'s the stable core.',
              style: TextStyle(fontSize: 11),
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Category filter
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = cat == 'All'
                            ? _vm.selectedCategory == null
                            : _vm.selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (_) => _vm.setCategory(
                              cat == 'All' ? null : cat,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // In-stock filter
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('In stock', style: TextStyle(fontSize: 12)),
                    Switch(
                      value: _vm.inStockOnly,
                      onChanged: _vm.setInStockOnly,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Product list
          Expanded(
            child: _vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _vm.error != null
                    ? Center(
                        child: Text('Error: ${_vm.error}',
                            style: const TextStyle(color: Colors.red)))
                    : _vm.products.isEmpty
                        ? const Center(
                            child: Text('No products match your filters.',
                                style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _vm.products.length,
                            itemBuilder: (context, index) {
                              final p = _vm.products[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: p.isPremium
                                        ? Colors.amber.shade100
                                        : Colors.grey.shade100,
                                    child: Icon(
                                      p.isPremium
                                          ? Icons.star
                                          : Icons.shopping_bag_outlined,
                                      color: p.isPremium
                                          ? Colors.amber
                                          : Colors.grey,
                                    ),
                                  ),
                                  title: Text(p.name),
                                  subtitle: Text(
                                    'Rp ${p.price.toStringAsFixed(0)} • ${p.category}',
                                  ),
                                  trailing: Chip(
                                    label: Text(
                                      p.isInStock
                                          ? '${p.stockCount} left'
                                          : 'Out of stock',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: p.isInStock
                                            ? Colors.green.shade800
                                            : Colors.red.shade800,
                                      ),
                                    ),
                                    backgroundColor: p.isInStock
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
