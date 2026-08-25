/// Entry point Phase 10.6 — Track 6: Backend Integration
import 'package:flutter/material.dart';

import '01_graphql/graphql_demo.dart';
import '02_grpc/grpc_demo.dart';
import '03_supabase_advanced/supabase_advanced_demo.dart';
import '04_rest_advanced/rest_advanced_demo.dart';
import 'mini_projects/chat_app/chat_app.dart';

void main() => runApp(const Phase106MenuApp());

class Phase106MenuApp extends StatelessWidget {
  const Phase106MenuApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Phase 10.6 — Backend',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink), useMaterial3: true),
        home: const Phase106MenuScreen(),
      );
}

class Phase106MenuScreen extends StatelessWidget {
  const Phase106MenuScreen({super.key});

  static const _topics = [
    _T('01 — GraphQL', 'Schema, queries, mutations, subscriptions, ferry code-gen', Icons.device_hub, Colors.pink, GraphqlDemo()),
    _T('02 — gRPC', '.proto, Dart stubs, unary/streaming, interceptors', Icons.speed, Colors.cyan, GrpcDemo()),
    _T('03 — Supabase Advanced', 'RLS, realtime, edge functions, storage', Icons.storage, Colors.green, SupabaseAdvancedDemo()),
    _T('04 — REST Advanced', 'OpenAPI codegen, cursor pagination, rate limiting, multipart', Icons.http, Colors.indigo, RestAdvancedDemo()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phase 10.6 — Backend'), backgroundColor: Colors.pink, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(color: Colors.pink.shade50, child: const Padding(padding: EdgeInsets.all(14), child: Text(
            'Track 6 covers production-grade backend integration strategies.\n\n'
            'REST is the baseline. GraphQL when the client needs flexible queries. '
            'gRPC for high-performance service-to-service. Supabase for a full '
            'backend-as-a-service with PostgreSQL power.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ))),
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
          Card(color: Colors.green.shade50, child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.chat, color: Colors.white)),
            title: const Text('Mini Project: Realtime Chat', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Supabase realtime + RLS + auth — full working chat UI'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatApp())),
          )),
        ],
      ),
    );
  }
}

class _T { final String label, sub; final IconData icon; final Color color; final Widget dest; const _T(this.label, this.sub, this.icon, this.color, this.dest); }
