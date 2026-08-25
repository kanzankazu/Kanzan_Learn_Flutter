/// Entry point Phase 10.5 — Track 5: Super App
import 'package:flutter/material.dart';

import '01_melos/melos_demo.dart';
import '02_micro_frontend/micro_frontend_demo.dart';
import '03_feature_flags/feature_flags_demo.dart';
import '04_module_communication/module_communication_demo.dart';
import 'mini_projects/super_app_shell/super_app_shell.dart';

void main() => runApp(const Phase105MenuApp());

class Phase105MenuApp extends StatelessWidget {
  const Phase105MenuApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Phase 10.5 — Super App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
        home: const Phase105MenuScreen(),
      );
}

class Phase105MenuScreen extends StatelessWidget {
  const Phase105MenuScreen({super.key});

  static const _topics = [
    _T('01 — Melos', 'Monorepo, bootstrap, scripts, versioning, conventional commits', Icons.folder_special, Colors.deepOrange, MelosDemo()),
    _T('02 — Micro-Frontend', 'Feature module contract, registry, shell scaffold, dynamic routing', Icons.view_module, Colors.indigo, MicroFrontendDemo()),
    _T('03 — Feature Flags', 'Remote Config, A/B testing, local override, kill switch', Icons.flag, Colors.amber, FeatureFlagsDemo()),
    _T('04 — Module Communication', 'EventBus, shared providers, module API interface', Icons.hub, Colors.teal, ModuleCommunicationDemo()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phase 10.5 — Super App'), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.deepPurple.shade50,
            child: const Padding(padding: EdgeInsets.all(14), child: Text(
              'Track 5 teaches you to build a Super App — one shell that hosts '
              'independent feature mini-apps, each built by a separate team.\n\n'
              'Skills: Melos monorepo, micro-frontend modules, feature flags, '
              'inter-module communication without coupling.',
              style: TextStyle(fontSize: 13, height: 1.5),
            )),
          ),
          const SizedBox(height: 12),
          ..._topics.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(child: ListTile(
                  leading: CircleAvatar(backgroundColor: t.color.withAlpha(38), child: Icon(t.icon, color: t.color, size: 20)),
                  title: Text(t.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(t.sub, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => t.dest)),
                )),
              )),
          const Divider(height: 24),
          Card(
            color: Colors.deepPurple.shade100,
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.deepPurple, child: Icon(Icons.apps, color: Colors.white)),
              title: const Text('Mini Project: Super App Shell', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Shell + 3 modules: Wallet, Promo, Settings. Adaptive nav, feature flags, event bus.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuperAppShell())),
            ),
          ),
        ],
      ),
    );
  }
}

class _T {
  final String label, sub; final IconData icon; final Color color; final Widget dest;
  const _T(this.label, this.sub, this.icon, this.color, this.dest);
}
