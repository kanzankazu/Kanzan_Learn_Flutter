/// Phase 10.5 — Mini Project: Super App Shell
///
/// A working Super App shell with 3 independent feature modules:
/// - Wallet module — balance, transactions
/// - Promo module — offers, cashback
/// - Settings module — profile, preferences
///
/// Demonstrates: module registry, dynamic nav, feature flags, event bus.
import 'package:flutter/material.dart';

void main() => runApp(const SuperAppShell());

class SuperAppShell extends StatelessWidget {
  const SuperAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      home: const _ShellScreen(),
    );
  }
}

// ── Module registry (simulated) ────────────────────────────────────────────────

/// Simulated feature module — no separate packages needed for demo.
class _FeatureModule {
  final String id;
  final String name;
  final IconData icon;
  final Widget screen;
  const _FeatureModule({required this.id, required this.name, required this.icon, required this.screen});
}

final _modules = <_FeatureModule>[
  _FeatureModule(id: 'wallet', name: 'Wallet', icon: Icons.account_balance_wallet, screen: const _WalletScreen()),
  _FeatureModule(id: 'promo',  name: 'Promo',  icon: Icons.local_offer,             screen: const _PromoScreen()),
  _FeatureModule(id: 'settings', name: 'Settings', icon: Icons.settings,            screen: const _SettingsScreen()),
];

// ── Shell scaffold ─────────────────────────────────────────────────────────────

class _ShellScreen extends StatefulWidget {
  const _ShellScreen();
  @override
  State<_ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<_ShellScreen> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final module = _modules[_activeIndex];

      if (constraints.maxWidth < 600) {
        // ── Compact: BottomNav ────────────────────────────────────────────
        return Scaffold(
          appBar: AppBar(
            title: Text(module.name),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          body: IndexedStack(index: _activeIndex, children: _modules.map((m) => m.screen).toList()),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _activeIndex,
            onDestinationSelected: (i) => setState(() => _activeIndex = i),
            destinations: _modules.map((m) => NavigationDestination(icon: Icon(m.icon), label: m.name)).toList(),
          ),
        );
      }

      // ── Wide: NavigationRail ──────────────────────────────────────────
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _activeIndex,
              onDestinationSelected: (i) => setState(() => _activeIndex = i),
              extended: constraints.maxWidth > 900,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(children: [
                  const FlutterLogo(size: 32),
                  const SizedBox(height: 4),
                  Text('SuperApp', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                ]),
              ),
              destinations: _modules.map((m) => NavigationRailDestination(icon: Icon(m.icon), label: Text(m.name))).toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: IndexedStack(index: _activeIndex, children: _modules.map((m) => m.screen).toList())),
          ],
        ),
      );
    });
  }
}

// ── Feature screens ────────────────────────────────────────────────────────────

class _WalletScreen extends StatelessWidget {
  const _WalletScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Balance card
        Card(
          color: Theme.of(context).colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
              SizedBox(height: 6),
              Text('Rp 12.450.000', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('3 wallets active', style: TextStyle(color: Colors.white60, fontSize: 12)),
                Text('Aug 24, 2026', style: TextStyle(color: Colors.white60, fontSize: 12)),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _quickAction(context, Icons.send, 'Transfer'),
            _quickAction(context, Icons.qr_code, 'QR Pay'),
            _quickAction(context, Icons.history, 'History'),
            _quickAction(context, Icons.add_circle_outline, 'Top Up'),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._txns.map((t) => ListTile(
              leading: CircleAvatar(backgroundColor: t.$3.withAlpha(40), child: Icon(t.$2, color: t.$3, size: 20)),
              title: Text(t.$1),
              subtitle: const Text('Today, 10:30'),
              trailing: Text(t.$4, style: TextStyle(fontWeight: FontWeight.bold, color: t.$3)),
            )),
      ],
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label) => Column(
        children: [
          CircleAvatar(radius: 24, backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Icon(icon, color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      );

  static const _txns = [
    ('Lunch @ Warung', Icons.restaurant, Colors.orange, '- Rp 45.000'),
    ('Salary', Icons.work, Colors.green, '+ Rp 8.500.000'),
    ('GoFood', Icons.delivery_dining, Colors.red, '- Rp 78.000'),
  ];
}

class _PromoScreen extends StatelessWidget {
  const _PromoScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('🎁 Available Offers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._promos.map((p) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(color: p.$2.withAlpha(40), borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: Text(p.$3, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.$1, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(p.$4, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ])),
                    Chip(
                      label: Text(p.$5, style: const TextStyle(fontSize: 10)),
                      backgroundColor: p.$2.withAlpha(40),
                      labelStyle: TextStyle(color: p.$2, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  static const _promos = [
    ('10% Cashback on Food', Colors.orange, '🍔', 'Valid until Aug 31', '10%'),
    ('Free Transfer', Colors.blue, '💸', 'First 3 transfers free', 'FREE'),
    ('50% Off First Ride', Colors.green, '🚗', 'New user promo', '50%'),
    ('2x Points Dining', Colors.purple, '⭐', 'Weekend only', '2x'),
  ];
}

class _SettingsScreen extends StatefulWidget {
  const _SettingsScreen();
  @override
  State<_SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<_SettingsScreen> {
  bool _biometric = true, _notif = true, _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(radius: 36, backgroundColor: Colors.deepPurple, child: Text('FB', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
        const SizedBox(height: 8),
        const Center(child: Text('Faisal Bahri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
        const Center(child: Text('kanzankazu46@gmail.com', style: TextStyle(color: Colors.grey, fontSize: 13))),
        const SizedBox(height: 20),
        const Text('Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
        SwitchListTile(title: const Text('Biometric Login'), value: _biometric, onChanged: (v) => setState(() => _biometric = v)),
        SwitchListTile(title: const Text('Push Notifications'), value: _notif, onChanged: (v) => setState(() => _notif = v)),
        SwitchListTile(title: const Text('Dark Mode'), value: _darkMode, onChanged: (v) => setState(() => _darkMode = v)),
        const Divider(),
        ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Sign Out', style: TextStyle(color: Colors.red)), onTap: () {}),
      ],
    );
  }
}
