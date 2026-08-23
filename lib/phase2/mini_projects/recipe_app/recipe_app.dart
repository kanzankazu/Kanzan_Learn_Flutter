/// # Mini Project 3 — Recipe App (UI Only)
///
/// **Tujuan:** Praktikkan topik Phase 2 dalam app yang lebih nyata:
/// - ListView & GridView (daftar resep)
/// - Hero animation (card ke detail)
/// - Custom widget (ResipeCard, InfoChip, StepItem)
/// - Theming & ColorScheme
/// - Responsive layout (grid kolom menyesuaikan lebar)
/// - Image.network dengan loading & error state
/// - Stack (overlay teks di atas gambar)
///
/// **Fitur:**
/// - Grid resep dengan gambar, rating, dan waktu masak
/// - Filter kategori (horizontal scrolling chip)
/// - Detail screen dengan bahan dan langkah
/// - Hero animation dari card ke detail
/// - Favorit toggle (StatefulWidget)
///
/// Jalankan: `flutter run -t lib/phase2/mini_projects/recipe_app/recipe_app.dart`

import 'package:flutter/material.dart';

void main() => runApp(const RecipeApp());

// ===========================================================================
// DATA MODEL
// ===========================================================================

/// Data model resep.
class Recipe {
  final int id;
  final String name;
  final String category;
  final String imageUrl;
  final double rating;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final Color accentColor;

  const Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.cookTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.accentColor,
  });
}

// Data dummy resep
final _recipes = [
  Recipe(
    id: 1,
    name: 'Nasi Goreng Spesial',
    category: 'Nasi',
    imageUrl: 'https://picsum.photos/seed/nasigoreng/400/300',
    rating: 4.8,
    cookTimeMinutes: 20,
    servings: 2,
    difficulty: 'Mudah',
    description: 'Nasi goreng khas Indonesia dengan telur dan sayuran segar.',
    ingredients: ['2 piring nasi', '2 butir telur', '3 siung bawang merah', '2 siung bawang putih', 'Kecap manis', 'Garam & merica'],
    steps: ['Tumis bawang hingga harum.', 'Masukkan nasi, aduk rata.', 'Tambahkan kecap, garam, merica.', 'Buat orak-arik telur di pinggir wajan.', 'Aduk semua bahan, sajikan.'],
    accentColor: Colors.orange,
  ),
  Recipe(
    id: 2,
    name: 'Soto Ayam',
    category: 'Soto',
    imageUrl: 'https://picsum.photos/seed/sotoayam/400/300',
    rating: 4.6,
    cookTimeMinutes: 45,
    servings: 4,
    difficulty: 'Sedang',
    description: 'Soto ayam bening segar dengan kuah kaldu yang gurih.',
    ingredients: ['500g ayam', 'Kunyit', 'Jahe', 'Serai', 'Daun salam', 'Bawang merah & putih', 'Garam'],
    steps: ['Rebus ayam dengan rempah.', 'Saring kaldu, suwir ayam.', 'Tumis bumbu halus.', 'Masukkan ke kaldu, didihkan.', 'Sajikan dengan lontong dan pelengkap.'],
    accentColor: Colors.yellow,
  ),
  Recipe(
    id: 3,
    name: 'Rendang Daging',
    category: 'Daging',
    imageUrl: 'https://picsum.photos/seed/rendang/400/300',
    rating: 4.9,
    cookTimeMinutes: 180,
    servings: 6,
    difficulty: 'Sulit',
    description: 'Rendang khas Padang dengan bumbu rempah yang kaya.',
    ingredients: ['1kg daging sapi', 'Santan kental', 'Cabai merah', 'Bawang merah & putih', 'Jahe', 'Lengkuas', 'Serai', 'Kunyit'],
    steps: ['Haluskan semua bumbu.', 'Tumis bumbu hingga matang.', 'Masukkan daging, aduk rata.', 'Tuang santan, masak dengan api kecil.', 'Aduk terus hingga santan mengering.', 'Masak hingga daging kecokelatan.'],
    accentColor: Colors.brown,
  ),
  Recipe(
    id: 4,
    name: 'Mie Goreng',
    category: 'Mie',
    imageUrl: 'https://picsum.photos/seed/miegoreng/400/300',
    rating: 4.5,
    cookTimeMinutes: 15,
    servings: 1,
    difficulty: 'Mudah',
    description: 'Mie goreng lezat dengan bumbu khas dan topping sayuran.',
    ingredients: ['100g mie kuning', 'Kecap manis', 'Saus tiram', 'Bawang putih', 'Kol & wortel', 'Telur'],
    steps: ['Rebus mie hingga al-dente.', 'Tumis bawang putih.', 'Masukkan telur, orak-arik.', 'Tambahkan sayuran.', 'Masukkan mie dan bumbu, aduk rata.'],
    accentColor: Colors.amber,
  ),
  Recipe(
    id: 5,
    name: 'Gado-Gado',
    category: 'Sayuran',
    imageUrl: 'https://picsum.photos/seed/gadogado/400/300',
    rating: 4.4,
    cookTimeMinutes: 30,
    servings: 2,
    difficulty: 'Mudah',
    description: 'Sayuran rebus segar dengan saus kacang yang creamy.',
    ingredients: ['Kacang tanah goreng', 'Tahu & tempe', 'Kentang', 'Kangkung', 'Tauge', 'Telur rebus', 'Bumbu kacang'],
    steps: ['Rebus semua sayuran.', 'Goreng tahu dan tempe.', 'Buat saus kacang.', 'Tata semua di piring.', 'Siram dengan saus kacang.'],
    accentColor: Colors.green,
  ),
  Recipe(
    id: 6,
    name: 'Bakso',
    category: 'Bakso',
    imageUrl: 'https://picsum.photos/seed/bakso/400/300',
    rating: 4.7,
    cookTimeMinutes: 60,
    servings: 4,
    difficulty: 'Sedang',
    description: 'Bakso daging sapi kenyal dengan kuah bening yang gurih.',
    ingredients: ['500g daging sapi giling', 'Tepung tapioka', 'Bawang putih', 'Garam', 'Merica', 'Kaldu sapi'],
    steps: ['Campur daging dengan tepung dan bumbu.', 'Bulatkan adonan.', 'Rebus bakso hingga mengapung.', 'Buat kuah kaldu.', 'Sajikan dengan mie dan pelengkap.'],
    accentColor: Colors.red,
  ),
];

final _categories = ['Semua', 'Nasi', 'Soto', 'Daging', 'Mie', 'Sayuran', 'Bakso'];

// ===========================================================================
// APP ROOT
// ===========================================================================

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const RecipeListScreen(),
    );
  }
}

// ===========================================================================
// RECIPE LIST SCREEN
// ===========================================================================

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  String _selectedCategory = 'Semua';
  final _favIds = <int>{};

  List<Recipe> get _filteredRecipes => _selectedCategory == 'Semua'
      ? _recipes
      : _recipes.where((r) => r.category == _selectedCategory).toList();

  void _toggleFav(int id) => setState(() {
    _favIds.contains(id) ? _favIds.remove(id) : _favIds.add(id);
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resep Masakan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: () {},
            tooltip: '${_favIds.length} favorit',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter kategori
          _CategoryFilter(
            selected: _selectedCategory,
            onSelected: (cat) => setState(() => _selectedCategory = cat),
          ),
          // Grid resep
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsif: 1 kolom < 400px, 2 kolom < 700px, 3 kolom lebih
                final columns = constraints.maxWidth < 400 ? 1 : constraints.maxWidth < 700 ? 2 : 3;
                return _filteredRecipes.isEmpty
                    ? const Center(child: Text('Tidak ada resep'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _filteredRecipes[index];
                          return RecipeCard(
                            recipe: recipe,
                            isFavorite: _favIds.contains(recipe.id),
                            onFavToggle: () => _toggleFav(recipe.id),
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

// ===========================================================================
// CATEGORY FILTER
// ===========================================================================

class _CategoryFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _CategoryFilter({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
            child: FilterChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (_) => onSelected(cat),
            ),
          );
        },
      ),
    );
  }
}

// ===========================================================================
// RECIPE CARD
// ===========================================================================

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final bool isFavorite;
  final VoidCallback onFavToggle;

  const RecipeCard({super.key, required this.recipe, required this.isFavorite, required this.onFavToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar dengan Hero
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Gambar resep dengan Hero tag
                  Hero(
                    tag: 'recipe-image-${recipe.id}',
                    child: Image.network(
                      recipe.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : Container(color: Colors.grey.shade200, child: const Center(child: CircularProgressIndicator())),
                      errorBuilder: (_, __, ___) => Container(
                        color: recipe.accentColor.withOpacity(0.2),
                        child: Icon(Icons.restaurant, color: recipe.accentColor, size: 48),
                      ),
                    ),
                  ),
                  // Overlay gelap + rating di pojok
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter, end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text('${recipe.rating}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  // Tombol favorit di pojok kanan atas
                  Positioned(
                    top: 8, right: 8,
                    child: GestureDetector(
                      onTap: onFavToggle,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_outline,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info di bawah gambar
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 12, color: Colors.grey),
                      const SizedBox(width: 2),
                      Text('${recipe.cookTimeMinutes}m', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(width: 8),
                      const Icon(Icons.people_outline, size: 12, color: Colors.grey),
                      const SizedBox(width: 2),
                      Text('${recipe.servings}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
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

// ===========================================================================
// RECIPE DETAIL SCREEN
// ===========================================================================

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar dengan gambar Hero
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              background: Hero(
                tag: 'recipe-image-${recipe.id}',
                child: Image.network(
                  recipe.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: recipe.accentColor.withOpacity(0.3),
                    child: Icon(Icons.restaurant, color: recipe.accentColor, size: 80),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_outline),
                color: _isFavorite ? Colors.red : null,
                onPressed: () => setState(() => _isFavorite = !_isFavorite),
              ),
            ],
          ),
          // Konten
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Info chips
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    _InfoChip(icon: Icons.star, label: '${recipe.rating}', color: Colors.amber),
                    _InfoChip(icon: Icons.timer, label: '${recipe.cookTimeMinutes} menit', color: Colors.blue),
                    _InfoChip(icon: Icons.people, label: '${recipe.servings} porsi', color: Colors.green),
                    _InfoChip(icon: Icons.bar_chart, label: recipe.difficulty, color: recipe.accentColor),
                  ],
                ),
                const SizedBox(height: 16),
                // Deskripsi
                Text(recipe.description, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
                // Bahan-bahan
                Text('Bahan-bahan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...recipe.ingredients.map((ing) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 6, color: recipe.accentColor),
                      const SizedBox(width: 8),
                      Text(ing),
                    ],
                  ),
                )),
                const SizedBox(height: 20),
                // Langkah-langkah
                Text('Cara Memasak', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...recipe.steps.asMap().entries.map((entry) => _StepItem(
                  step: entry.key + 1,
                  text: entry.value,
                  color: recipe.accentColor,
                )),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// HELPER WIDGETS
// ===========================================================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int step;
  final String text;
  final Color color;
  const _StepItem({required this.step, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(child: Text('$step', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Padding(padding: const EdgeInsets.only(top: 4), child: Text(text))),
        ],
      ),
    );
  }
}
