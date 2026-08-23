/// # Mini Project 1 — Profile Card App
///
/// **Tujuan:** Praktikkan topik Phase 2 dalam satu app utuh:
/// - Custom widget (extract & composition)
/// - Layout (Column, Row, Stack)
/// - Container & BoxDecoration (gradient, shadow, radius)
/// - Theming (ColorScheme, dark mode toggle)
/// - ListView untuk daftar kontak
/// - Hero animation antar screen
///
/// **Yang akan dibangun:**
/// - Halaman profil utama dengan card info lengkap
/// - Grid skill/tag
/// - Daftar kontak dengan navigasi ke detail
/// - Hero animation ke detail screen
///
/// Jalankan: `flutter run -t lib/phase2/mini_projects/profile_card/profile_card_app.dart`

import 'package:flutter/material.dart';

void main() => runApp(const ProfileCardApp());

/// Data model untuk profil.
class Profile {
  final String name;
  final String role;
  final String bio;
  final String location;
  final int followers;
  final int following;
  final int posts;
  final List<String> skills;
  final Color avatarColor;

  const Profile({
    required this.name,
    required this.role,
    required this.bio,
    required this.location,
    required this.followers,
    required this.following,
    required this.posts,
    required this.skills,
    required this.avatarColor,
  });
}

// Data dummy
final _profiles = [
  const Profile(
    name: 'Faisal Bahri',
    role: 'Android & Flutter Developer',
    bio: 'Passionate about clean code and great UX. Building mobile apps since 2017.',
    location: 'Jakarta, Indonesia',
    followers: 1250,
    following: 310,
    posts: 42,
    skills: ['Kotlin', 'Flutter', 'Compose', 'Hilt', 'Firebase', 'Clean Arch'],
    avatarColor: Colors.indigo,
  ),
  const Profile(
    name: 'Budi Santoso',
    role: 'iOS Developer',
    bio: 'SwiftUI enthusiast. Love building delightful mobile experiences.',
    location: 'Bandung, Indonesia',
    followers: 890,
    following: 200,
    posts: 28,
    skills: ['Swift', 'SwiftUI', 'UIKit', 'Combine', 'CoreData'],
    avatarColor: Colors.blue,
  ),
  const Profile(
    name: 'Sari Dewi',
    role: 'Backend Engineer',
    bio: 'Building robust APIs. Go enthusiast. Coffee-powered.',
    location: 'Surabaya, Indonesia',
    followers: 540,
    following: 180,
    posts: 15,
    skills: ['Go', 'Kotlin', 'PostgreSQL', 'Redis', 'Docker', 'K8s'],
    avatarColor: Colors.teal,
  ),
];

// ===========================================================================
// APP ROOT
// ===========================================================================

class ProfileCardApp extends StatefulWidget {
  const ProfileCardApp({super.key});

  @override
  State<ProfileCardApp> createState() => _ProfileCardAppState();
}

class _ProfileCardAppState extends State<ProfileCardApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() => setState(() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Card App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true, brightness: Brightness.dark),
      themeMode: _themeMode,
      home: ProfileListScreen(onToggleTheme: _toggleTheme, themeMode: _themeMode),
    );
  }
}

// ===========================================================================
// PROFILE LIST SCREEN
// ===========================================================================

class ProfileListScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const ProfileListScreen({super.key, required this.onToggleTheme, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Developer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: onToggleTheme,
            tooltip: 'Toggle dark mode',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _profiles.length,
        itemBuilder: (context, index) {
          final profile = _profiles[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ProfileCardWidget(profile: profile, index: index),
          );
        },
      ),
    );
  }
}

// ===========================================================================
// PROFILE CARD WIDGET (Hero source)
// ===========================================================================

/// Kartu profil di list — di-tap untuk navigasi ke detail.
class ProfileCardWidget extends StatelessWidget {
  final Profile profile;
  final int index; // dipakai sebagai Hero tag agar unik per item

  const ProfileCardWidget({super.key, required this.profile, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfileDetailScreen(profile: profile, heroIndex: index)),
      ),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            // Header dengan gradient + avatar (Hero wrapper)
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [profile.avatarColor, profile.avatarColor.withOpacity(0.5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Avatar — dibungkus Hero agar animasi saat ke detail
                  Positioned(
                    bottom: -28,
                    left: 16,
                    child: Hero(
                      tag: 'avatar-$index', // tag unik per item
                      child: _AvatarCircle(profile: profile, radius: 36),
                    ),
                  ),
                ],
              ),
            ),
            // Body card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            Text(profile.role, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      // Tombol follow
                      OutlinedButton(onPressed: () {}, child: const Text('Follow')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Stats row
                  _StatsRow(profile: profile),
                  const SizedBox(height: 8),
                  // Skill chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: profile.skills.take(4).map((skill) => // show max 4
                      Chip(
                        label: Text(skill, style: const TextStyle(fontSize: 11)),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      )
                    ).toList(),
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
// PROFILE DETAIL SCREEN (Hero destination)
// ===========================================================================

class ProfileDetailScreen extends StatelessWidget {
  final Profile profile;
  final int heroIndex;

  const ProfileDetailScreen({super.key, required this.profile, required this.heroIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar dengan gambar/gradient header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(profile.name),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [profile.avatarColor, profile.avatarColor.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  // Hero destination — tag sama dengan di ProfileCardWidget
                  child: Hero(
                    tag: 'avatar-$heroIndex',
                    child: _AvatarCircle(profile: profile, radius: 52),
                  ),
                ),
              ),
            ),
          ),
          // Konten detail
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(profile.role, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: profile.avatarColor)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(profile.location, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 12),
                _StatsRow(profile: profile),
                const Divider(height: 24),
                Text('Bio', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(profile.bio),
                const SizedBox(height: 16),
                Text('Skills', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.skills.map((skill) =>
                    Chip(
                      label: Text(skill),
                      backgroundColor: profile.avatarColor.withOpacity(0.1),
                      side: BorderSide(color: profile.avatarColor.withOpacity(0.3)),
                    )
                  ).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.person_add), label: const Text('Follow'))),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.message_outlined), label: const Text('Pesan'))),
                  ],
                ),
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

class _AvatarCircle extends StatelessWidget {
  final Profile profile;
  final double radius;
  const _AvatarCircle({required this.profile, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: radius - 3,
        backgroundColor: profile.avatarColor,
        child: Text(
          profile.name[0].toUpperCase(),
          style: TextStyle(
            fontSize: radius * 0.7,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final Profile profile;
  const _StatsRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(label: 'Posts', value: '${profile.posts}'),
        _Divider(),
        _StatItem(label: 'Followers', value: _formatNum(profile.followers)),
        _Divider(),
        _StatItem(label: 'Following', value: _formatNum(profile.following)),
      ],
    );
  }

  String _formatNum(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 24, color: Colors.grey.shade300);
  }
}
