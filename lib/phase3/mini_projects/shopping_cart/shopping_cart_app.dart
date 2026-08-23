/// Mini Project Phase 3 — Shopping Cart App.
///
/// **What this project practices:**
/// - GoRouter: navigation product list → detail → cart → checkout
/// - Riverpod StateNotifier: cart state (add, remove, update quantity)
/// - Derived providers: total price, item count
/// - FutureProvider: simulated product loading from "API"
/// - Passing data (extra) from list to detail screen
/// - AsyncValue.when() to handle loading/data/error states
///
/// **How to run:**
/// ```bash
/// flutter run -t lib/phase3/mini_projects/shopping_cart/shopping_cart_app.dart
/// ```
///
/// **Navigation flow:**
/// ```
/// /products → /products/:id → /cart → /checkout/success
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

/// Product model.
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String emoji;
  final String category;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.emoji,
    required this.category,
  });
}

/// A cart item (product + quantity).
class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  /// Total price for this item.
  double get subtotal => product.price * quantity;
}

// ─────────────────────────────────────────────────────────────────────────────
// Dummy data
// ─────────────────────────────────────────────────────────────────────────────

final _dummyProducts = [
  const Product(
    id: '1',
    name: 'Arabica Coffee',
    description: 'Single origin coffee from Aceh Gayo. Flavor notes: dark chocolate, caramel, mild acidity.',
    price: 85000,
    emoji: '☕',
    category: 'Drinks',
  ),
  const Product(
    id: '2',
    name: 'Butter Croissant',
    description: 'Buttery layered croissant with a flaky texture and inviting aroma. Baked fresh daily.',
    price: 35000,
    emoji: '🥐',
    category: 'Food',
  ),
  const Product(
    id: '3',
    name: 'Complete Flutter Book',
    description: 'Comprehensive Flutter guide from zero to production. 450 pages, full color.',
    price: 195000,
    emoji: '📚',
    category: 'Books',
  ),
  const Product(
    id: '4',
    name: 'Mechanical Keyboard',
    description: '75% layout with Red linear switches. RGB backlight, hot-swappable.',
    price: 850000,
    emoji: '⌨️',
    category: 'Gadgets',
  ),
  const Product(
    id: '5',
    name: 'Matcha Latte',
    description: 'Premium ceremonial grade matcha from Japan, blended with oat milk.',
    price: 55000,
    emoji: '🍵',
    category: 'Drinks',
  ),
  const Product(
    id: '6',
    name: 'Canvas Tote Bag',
    description: '100% organic canvas tote bag. 15L capacity, fits a 13" laptop.',
    price: 120000,
    emoji: '👜',
    category: 'Accessories',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// FutureProvider — simulates loading products from an API.
final productsProvider = FutureProvider<List<Product>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 800)); // simulate network
  return _dummyProducts;
});

/// Active category filter.
final categoryFilterProvider = StateProvider<String?>((ref) => null);

/// Derived provider — filtered product list.
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final products = ref.watch(productsProvider);
  final category = ref.watch(categoryFilterProvider);

  return products.whenData(
    (list) => category == null
        ? list
        : list.where((p) => p.category == category).toList(),
  );
});

/// StateNotifier for the shopping cart.
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  /// Add a product to the cart. Increments quantity if already present.
  void add(Product product) {
    final existing = state.where((i) => i.product.id == product.id);
    if (existing.isNotEmpty) {
      state = state
          .map((i) => i.product.id == product.id
              ? i.copyWith(quantity: i.quantity + 1)
              : i)
          .toList();
    } else {
      state = [...state, CartItem(product: product, quantity: 1)];
    }
  }

  /// Decrease quantity. Removes from cart if quantity reaches 0.
  void decrement(String productId) {
    state = state
        .map((i) => i.product.id == productId
            ? i.copyWith(quantity: i.quantity - 1)
            : i)
        .where((i) => i.quantity > 0)
        .toList();
  }

  /// Remove a product from the cart.
  void remove(String productId) {
    state = state.where((i) => i.product.id != productId).toList();
  }

  /// Empty the entire cart.
  void clear() => state = [];

  /// Get the quantity of a specific product in the cart.
  int quantityOf(String productId) {
    final found = state.where((i) => i.product.id == productId);
    return found.isEmpty ? 0 : found.first.quantity;
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>((ref) => CartNotifier());

/// Total cart price.
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.subtotal);
});

/// Total number of items in the cart (including quantities).
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

// ─────────────────────────────────────────────────────────────────────────────
// Router
// ─────────────────────────────────────────────────────────────────────────────

final _router = GoRouter(
  initialLocation: '/products',
  routes: [
    GoRoute(
      path: '/products',
      name: 'products',
      builder: (context, state) => const ProductListScreen(),
      routes: [
        GoRoute(
          path: ':id',
          name: 'product-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final product = state.extra as Product?;
            return ProductDetailScreen(productId: id, product: product);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/checkout/success',
      name: 'checkout-success',
      builder: (context, state) => const CheckoutSuccessScreen(),
    ),
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  runApp(const ProviderScope(child: ShoppingCartApp()));
}

class ShoppingCartApp extends StatelessWidget {
  const ShoppingCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Shop App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ProductListScreen
// ─────────────────────────────────────────────────────────────────────────────

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(filteredProductsProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);

    // Collect all unique categories
    final allCategories = _dummyProducts.map((p) => p.category).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🛍️ Our Shop'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          // Cart button with item count badge
          Badge(
            isLabelVisible: cartCount > 0,
            label: Text('$cartCount'),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => context.push('/cart'),
            ),
          ),
          const SizedBox(width: 8),
        ],
        // Category filter chips
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                // "All" chip
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: selectedCategory == null,
                    onSelected: (_) =>
                        ref.read(categoryFilterProvider.notifier).state = null,
                  ),
                ),
                ...allCategories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: selectedCategory == cat,
                      onSelected: (_) =>
                          ref.read(categoryFilterProvider.notifier).state = cat,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (products) => products.isEmpty
            ? const Center(child: Text('No products in this category.'))
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) =>
                    _ProductCard(product: products[index]),
              ),
      ),
    );
  }
}

/// Product card in the grid.
class _ProductCard extends ConsumerWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qty = ref.watch(
      cartProvider.select((cart) {
        final found = cart.where((i) => i.product.id == product.id);
        return found.isEmpty ? 0 : found.first.quantity;
      }),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/products/${product.id}', extra: product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji as image placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.orange.shade50,
                child: Center(
                  child: Text(product.emoji, style: const TextStyle(fontSize: 48)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Rp ${_formatPrice(product.price)}',
                    style: const TextStyle(color: Colors.deepOrange),
                  ),
                  const SizedBox(height: 6),
                  // Add to cart button / quantity stepper
                  qty == 0
                      ? SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () =>
                                ref.read(cartProvider.notifier).add(product),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                            ),
                            child: const Text('+ Add'),
                          ),
                        )
                      : Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.deepOrange),
                              onPressed: () => ref
                                  .read(cartProvider.notifier)
                                  .decrement(product.id),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Expanded(
                              child: Text(
                                '$qty',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle,
                                  color: Colors.deepOrange),
                              onPressed: () =>
                                  ref.read(cartProvider.notifier).add(product),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ProductDetailScreen
// ─────────────────────────────────────────────────────────────────────────────

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  final Product? product;

  const ProductDetailScreen({
    required this.productId,
    required this.product,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Resolve from extra or fall back to list lookup
    final resolvedProduct = product ??
        _dummyProducts.firstWhere(
          (p) => p.id == productId,
          orElse: () => throw Exception('Product not found'),
        );

    final qty = ref.watch(
      cartProvider.select((cart) {
        final found = cart.where((i) => i.product.id == productId);
        return found.isEmpty ? 0 : found.first.quantity;
      }),
    );
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(resolvedProduct.name),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          Badge(
            isLabelVisible: cartCount > 0,
            label: Text('$cartCount'),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => context.push('/cart'),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image area
            Container(
              width: double.infinity,
              height: 240,
              color: Colors.orange.shade50,
              child: Center(
                child: Text(resolvedProduct.emoji,
                    style: const TextStyle(fontSize: 96)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Chip(
                    label: Text(resolvedProduct.category),
                    labelStyle: const TextStyle(fontSize: 12),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resolvedProduct.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${_formatPrice(resolvedProduct.price)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(resolvedProduct.description,
                      style: const TextStyle(height: 1.6)),
                  const SizedBox(height: 32),

                  // Quantity stepper + add to cart
                  if (qty == 0)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () =>
                            ref.read(cartProvider.notifier).add(resolvedProduct),
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add to Cart'),
                      ),
                    )
                  else
                    Row(
                      children: [
                        const Text('Qty:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        IconButton.filled(
                          onPressed: () => ref
                              .read(cartProvider.notifier)
                              .decrement(productId),
                          icon: const Icon(Icons.remove),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('$qty',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ),
                        IconButton.filled(
                          onPressed: () => ref
                              .read(cartProvider.notifier)
                              .add(resolvedProduct),
                          icon: const Icon(Icons.add),
                        ),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: () => context.push('/cart'),
                          child: const Text('View Cart'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CartScreen
// ─────────────────────────────────────────────────────────────────────────────

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart (${cart.length} ${cart.length == 1 ? 'item' : 'items'})'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: cart.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your cart is empty.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return ListTile(
                        leading: Text(
                          item.product.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        title: Text(item.product.name),
                        subtitle: Text(
                            'Rp ${_formatPrice(item.product.price)} × ${item.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Rp ${_formatPrice(item.subtotal)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              onPressed: () => ref
                                  .read(cartProvider.notifier)
                                  .remove(item.product.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Summary + checkout button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, -2))
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(fontSize: 16)),
                          Text(
                            'Rp ${_formatPrice(total)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            ref.read(cartProvider.notifier).clear();
                            context.go('/checkout/success');
                          },
                          icon: const Icon(Icons.payment),
                          label: const Text('Pay Now'),
                          style: FilledButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CheckoutSuccessScreen
// ─────────────────────────────────────────────────────────────────────────────

class CheckoutSuccessScreen extends StatelessWidget {
  const CheckoutSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 100, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                'Order Placed! 🎉',
                style:
                    TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Thank you for your purchase.\nYour order is being processed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.6),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.go('/products'),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Continue Shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper
// ─────────────────────────────────────────────────────────────────────────────

/// Format a number with thousands separators (75000 → "75.000").
String _formatPrice(double price) {
  final parts = price.toStringAsFixed(0).split('');
  final result = StringBuffer();
  for (var i = 0; i < parts.length; i++) {
    if (i > 0 && (parts.length - i) % 3 == 0) result.write('.');
    result.write(parts[i]);
  }
  return result.toString();
}
