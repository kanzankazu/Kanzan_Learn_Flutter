/// Demo 02 — Passing Data Between Screens with GoRouter.
///
/// **Concepts covered:**
/// - Query parameters: `/products?category=electronics`
/// - Path parameters: `/products/:id`
/// - Extra object: send complex data (Dart objects) without URL encoding
/// - Receiving data passed back from a previous screen
///
/// **When to use which:**
/// - Path param → ID that's part of the URL (`/user/42`)
/// - Query param → optional filter/sort (`/products?sort=price`)
/// - Extra → complex objects that don't need to be encoded in the URL
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Simple data model for demo
// ─────────────────────────────────────────────────────────────────────────────

/// Product model to be passed between screens.
class Product {
  final int id;
  final String name;
  final double price;
  final String category;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });
}

/// Dummy product data.
const _products = [
  Product(id: 1, name: 'Gaming Laptop', price: 15000000, category: 'Electronics'),
  Product(id: 2, name: 'Mechanical Keyboard', price: 850000, category: 'Electronics'),
  Product(id: 3, name: 'Flutter Book', price: 120000, category: 'Books'),
  Product(id: 4, name: 'Standing Desk', price: 2500000, category: 'Furniture'),
];

// ─────────────────────────────────────────────────────────────────────────────
// Demo entry point
// ─────────────────────────────────────────────────────────────────────────────

/// Entry point for the passing data demo. Creates its own GoRouter instance.
class PassingDataDemo extends StatelessWidget {
  const PassingDataDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/products',
      routes: [
        GoRoute(
          // Path param `:category` → value taken from URL, e.g. /products?category=Books
          path: '/products',
          name: 'products',
          builder: (context, state) {
            // Query parameter — optional, can be null
            final category = state.uri.queryParameters['category'];
            return _ProductListScreen(filterCategory: category);
          },
          routes: [
            GoRoute(
              // Path parameter `:id` → required in URL, e.g. /products/2
              path: ':id',
              name: 'product-detail',
              builder: (context, state) {
                // Get the path parameter
                final id = int.parse(state.pathParameters['id']!);

                // `extra` → complex data sent via context.go/push.
                // If opened directly from a URL (deep link), extra = null.
                // Always handle the null case!
                final product = state.extra as Product?;

                return _ProductDetailScreen(productId: id, product: product);
              },
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Passing Data Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screens
// ─────────────────────────────────────────────────────────────────────────────

/// Product list with category filter via query parameter.
class _ProductListScreen extends StatelessWidget {
  /// Category filter from query parameter, null = show all.
  final String? filterCategory;

  const _ProductListScreen({this.filterCategory});

  @override
  Widget build(BuildContext context) {
    // Filter products by category
    final filtered = filterCategory == null
        ? _products
        : _products.where((p) => p.category == filterCategory).toList();

    // Unique category list for filter chips
    final categories = _products.map((p) => p.category).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(filterCategory == null ? 'All Products' : filterCategory!),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Filter chips — navigate with query parameters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // "All" chip
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: filterCategory == null,
                    // go() with query parameter — URL becomes /products
                    onSelected: (_) => context.go('/products'),
                  ),
                ),
                // Per-category chips
                ...categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: filterCategory == cat,
                      // URL becomes /products?category=Electronics
                      onSelected: (_) => context.go('/products?category=$cat'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Product list
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final product = filtered[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepOrange.shade100,
                    child: Text(product.id.toString()),
                  ),
                  title: Text(product.name),
                  subtitle: Text('Rp ${product.price.toStringAsFixed(0)}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to detail with TWO methods simultaneously:
                    // 1. Path param → /products/2 (for deep links & URLs)
                    // 2. extra → Product object (avoids re-fetching from DB)
                    context.go(
                      '/products/${product.id}',
                      extra: product, // pass the Product object directly
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Product detail — receives data via path param and extra.
class _ProductDetailScreen extends StatelessWidget {
  final int productId;

  /// Product from `extra` — can be null if opened via deep link.
  final Product? product;

  const _ProductDetailScreen({required this.productId, this.product});

  @override
  Widget build(BuildContext context) {
    // If extra is available, use it directly. Otherwise (deep link), look up from list.
    // This is a simple "offline-first" pattern.
    final resolvedProduct =
        product ?? _products.firstWhere((p) => p.id == productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(resolvedProduct.name),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resolvedProduct.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Category: ${resolvedProduct.category}'),
                    const SizedBox(height: 4),
                    Text(
                      'Price: Rp ${resolvedProduct.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Technical explanation of how the data arrived here
            const Text(
              '💡 How data was received:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '• productId = ${resolvedProduct.id} → from path parameter (:id)\n'
              '• product object → from extra (sent when list item was tapped)\n'
              '• If extra is null (deep link) → look up from _products list',
            ),
          ],
        ),
      ),
    );
  }
}
