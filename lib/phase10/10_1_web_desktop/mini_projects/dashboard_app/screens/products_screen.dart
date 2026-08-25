/// Products Screen — Admin Dashboard
import 'package:flutter/material.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _search = '';
  String _category = 'All';

  static const _products = [
    ('PRD001', 'MacBook Pro 16"', 'Electronics', 'Rp 32M', 145, Icons.laptop),
    ('PRD002', 'iPhone 16 Pro', 'Electronics', 'Rp 22M', 89, Icons.phone_iphone),
    ('PRD003', 'Nike Air Max', 'Fashion', 'Rp 2.4M', 340, Icons.directions_run),
    ('PRD004', 'Clean Code Book', 'Books', 'Rp 350K', 78, Icons.menu_book),
    ('PRD005', 'Espresso Machine', 'Food', 'Rp 4.8M', 23, Icons.coffee),
    ('PRD006', 'Mechanical Keyboard', 'Electronics', 'Rp 1.8M', 210, Icons.keyboard),
  ];

  static const _categories = ['All', 'Electronics', 'Fashion', 'Food', 'Books'];

  List<(String, String, String, String, int, IconData)> get _filtered =>
      _products.where((p) {
        final matchSearch = _search.isEmpty ||
            p.$2.toLowerCase().contains(_search.toLowerCase());
        final matchCat = _category == 'All' || p.$3 == _category;
        return matchSearch && matchCat;
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Products',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Product'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search products…',
                      prefixIcon: Icon(Icons.search, size: 18),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                const SizedBox(width: 12),
                ...(_categories.map((cat) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ChoiceChip(
                        label: Text(cat,
                            style: const TextStyle(fontSize: 11)),
                        selected: _category == cat,
                        onSelected: (_) =>
                            setState(() => _category = cat),
                        visualDensity: VisualDensity.compact,
                      ),
                    ))),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(builder: (_, constraints) {
                final cols = (constraints.maxWidth / 240).floor().clamp(1, 5);
                final itemW = (constraints.maxWidth - (cols - 1) * 12) / cols;
                final products = _filtered;
                return SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: products
                        .map((p) => SizedBox(
                              width: itemW,
                              child: _ProductCard(product: p),
                            ))
                        .toList(),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final (String, String, String, String, int, IconData) product;
  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade200,
          ),
          boxShadow: _hovered
              ? [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 12)]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(p.$6,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22),
              ),
              const SizedBox(height: 10),
              Text(p.$2,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(p.$3,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(p.$4,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.primary)),
                  Text('${p.$5} in stock',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
