/// Demo 05 — Image Caching with cached_network_image.
///
/// **Concepts covered:**
/// - Why image caching matters (avoid re-downloading on every build)
/// - CachedNetworkImage — drop-in replacement for Image.network
/// - placeholder — widget shown while image is loading
/// - errorWidget — widget shown when image fails to load
/// - imageBuilder — customize how the cached image is displayed
/// - CacheManager — clear the cache, set max age/size
/// - Fade-in animation
/// - Skeleton loading (shimmer-like placeholder)
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sample image URLs (public domain photos from picsum.photos)
// ─────────────────────────────────────────────────────────────────────────────

const _images = [
  'https://picsum.photos/seed/flutter/400/300',
  'https://picsum.photos/seed/dart/400/300',
  'https://picsum.photos/seed/riverpod/400/300',
  'https://picsum.photos/seed/bloc/400/300',
  'https://picsum.photos/seed/hive/400/300',
  'https://picsum.photos/seed/dio/400/300',
  'https://broken-url.example.com/image.jpg', // intentionally broken
];

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class ImageCachingDemo extends StatelessWidget {
  const ImageCachingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Caching Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const _ImageCachingScreen(),
    );
  }
}

class _ImageCachingScreen extends StatefulWidget {
  const _ImageCachingScreen();

  @override
  State<_ImageCachingScreen> createState() => _ImageCachingScreenState();
}

class _ImageCachingScreenState extends State<_ImageCachingScreen> {
  bool _showGrid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Caching'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_showGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _showGrid = !_showGrid),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear image cache',
            onPressed: () async {
              await CachedNetworkImage.evictFromCache(_images[0]);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared for first image')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.pink.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💡 Images are cached after first load.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(
                    'Scroll away and back — images load instantly from cache.\n'
                    'The last card uses a broken URL to show the error widget.',
                    style: TextStyle(fontSize: 12)),
              ],
            ),
          ),

          Expanded(
            child: _showGrid ? _buildGrid() : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _images.length + 1, // +1 for comparison section
      itemBuilder: (context, index) {
        if (index == _images.length) return _buildComparison();

        final url = _images[index];
        final isBroken = url.contains('broken-url');

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The main cached image
              CachedNetworkImage(
                imageUrl: url,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,

                // Shown while loading — skeleton box
                placeholder: (context, url) => _SkeletonBox(
                  height: 180,
                  label: 'Loading${isBroken ? ' (broken URL)' : ''}...',
                ),

                // Shown when load fails
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: Colors.red.shade50,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 48, color: Colors.red),
                      SizedBox(height: 8),
                      Text('Failed to load image',
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),

                // Fade in when loaded from network (not cache — instant)
                fadeInDuration: const Duration(milliseconds: 300),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  isBroken ? '⚠️ Broken URL — shows error widget' : url,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: _images[index],
            fit: BoxFit.cover,
            placeholder: (_, __) => const _SkeletonBox(height: 150, label: ''),
            errorWidget: (_, __, ___) => Container(
              color: Colors.red.shade50,
              child: const Icon(Icons.broken_image, color: Colors.red),
            ),
          ),
        );
      },
    );
  }

  /// Shows the difference between Image.network and CachedNetworkImage.
  Widget _buildComparison() {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Image.network vs CachedNetworkImage',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const _CompRow(
              label: 'Caching',
              network: '❌ Re-downloads every time',
              cached: '✅ Disk + memory cache',
            ),
            const _CompRow(
              label: 'Placeholder',
              network: '❌ No built-in support',
              cached: '✅ placeholder builder',
            ),
            const _CompRow(
              label: 'Error widget',
              network: '❌ No built-in support',
              cached: '✅ errorWidget builder',
            ),
            const _CompRow(
              label: 'Fade-in',
              network: '⚠️ Manual AnimatedOpacity',
              cached: '✅ Built-in fade',
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final String label;
  const _SkeletonBox({required this.height, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompRow extends StatelessWidget {
  final String label;
  final String network;
  final String cached;
  const _CompRow(
      {required this.label, required this.network, required this.cached});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(network, style: const TextStyle(fontSize: 11)),
                Text(cached,
                    style: const TextStyle(fontSize: 11, color: Colors.green)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
