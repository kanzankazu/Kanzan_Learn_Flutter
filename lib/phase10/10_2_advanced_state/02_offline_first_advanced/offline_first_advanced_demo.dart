/// Phase 10.2 — Topic 02: Advanced Offline-First
///
/// Phase 4 covered the basics of cache-then-network. This topic goes deeper:
/// - Sync queue: persist operations when offline, replay when back online
/// - Conflict resolution: what happens when device A and device B both edit
///   the same record while offline and then sync?
/// - Connectivity monitoring with connectivity_plus
/// - Optimistic UI + rollback
///
/// Key concepts covered:
/// 1. Sync queue pattern — persist pending mutations to Isar/SQLite
/// 2. Background sync — replay queue when connectivity restored
/// 3. Conflict strategies: Last-Write-Wins (LWW), Server-Wins, Client-Wins
/// 4. connectivity_plus — real-time network status stream
/// 5. Exponential back-off for sync retries
/// 6. Sync status indicators — syncing, synced, pending, error
/// 7. Delta sync — only sync changed fields, not the full record
import 'package:flutter/material.dart';

void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline-First Advanced',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green), useMaterial3: true),
      home: const OfflineFirstAdvancedDemo(),
    );
  }
}

class OfflineFirstAdvancedDemo extends StatefulWidget {
  const OfflineFirstAdvancedDemo({super.key});
  @override
  State<OfflineFirstAdvancedDemo> createState() => _OfflineFirstAdvancedDemoState();
}

class _OfflineFirstAdvancedDemoState extends State<OfflineFirstAdvancedDemo> {
  // Live connectivity simulation
  bool _isOnline = true;
  int _pendingOps = 0;
  String _syncStatus = 'Synced ✅';

  void _toggleConnectivity() {
    setState(() {
      _isOnline = !_isOnline;
      _syncStatus = _isOnline ? 'Online — syncing...' : 'Offline — queuing ops';
    });
  }

  void _addOperation() {
    setState(() {
      if (_isOnline) {
        _syncStatus = 'Syncing... ↑';
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) setState(() => _syncStatus = 'Synced ✅');
        });
      } else {
        _pendingOps++;
        _syncStatus = 'Offline — $_pendingOps op${_pendingOps > 1 ? "s" : ""} queued';
      }
    });
  }

  void _syncNow() {
    if (!_isOnline || _pendingOps == 0) return;
    setState(() => _syncStatus = 'Syncing $_pendingOps ops...');
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _pendingOps = 0;
          _syncStatus = 'Synced ✅';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('02 — Offline-First Advanced'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Live demo ────────────────────────────────────────────────
          _header('Live Demo — Sync Queue', Colors.green.shade700),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isOnline ? Icons.wifi : Icons.wifi_off,
                          color: _isOnline ? Colors.green : Colors.red, size: 28),
                      const SizedBox(width: 10),
                      Text(_isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isOnline ? Colors.green : Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_syncStatus,
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  if (_pendingOps > 0)
                    Chip(
                      label: Text('$_pendingOps pending'),
                      backgroundColor: Colors.orange.shade100,
                      labelStyle: const TextStyle(color: Colors.orange),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _toggleConnectivity,
                        icon: Icon(_isOnline ? Icons.wifi_off : Icons.wifi, size: 16),
                        label: Text(_isOnline ? 'Go Offline' : 'Go Online'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _addOperation,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Op'),
                      ),
                      if (_pendingOps > 0 && _isOnline) ...[
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: _syncNow,
                          icon: const Icon(Icons.sync, size: 16),
                          label: const Text('Sync Now'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── 1. Sync queue pattern ────────────────────────────────────
          _header('1. Sync Queue Pattern', Colors.green.shade700),
          _code(r'''
// The core idea: when offline, don't drop operations — queue them.
// When back online, replay the queue in order.

// lib/core/sync/sync_queue.dart

/// Represents one pending operation waiting to be synced.
class SyncOperation {
  final String id;         // UUID — dedup on server if replayed twice
  final String type;       // "create" | "update" | "delete"
  final String entity;     // "transaction" | "wallet" | "budget"
  final Map<String, dynamic> payload;  // the actual data
  final DateTime createdAt;
  int retryCount;

  SyncOperation({...});
}

// Persist the queue to Isar so it survives app restarts
class SyncQueue {
  final IsarCollection<SyncOperation> _collection;

  // Add an operation to the queue (called offline or online)
  Future<void> enqueue(SyncOperation op) async {
    await _collection.isar.writeTxn(() => _collection.put(op));
  }

  // Replay all pending operations
  Future<void> flush(RemoteApi api) async {
    final ops = await _collection.where().sortByCreatedAt().findAll();

    for (final op in ops) {
      try {
        await _executeOp(api, op);
        await _collection.isar.writeTxn(() => _collection.delete(op.id.hashCode));
      } catch (e) {
        op.retryCount++;
        if (op.retryCount >= 3) {
          // Move to dead-letter queue — show error to user
          await _moveToDeadLetter(op, error: e.toString());
        } else {
          await _collection.isar.writeTxn(() => _collection.put(op));
        }
        // Stop processing — maintain operation order
        break;
      }
    }
  }
}'''),

          const SizedBox(height: 20),

          // ── 2. Connectivity monitoring ───────────────────────────────
          _header('2. Connectivity Monitoring', Colors.blue),
          _code(r'''
// connectivity_plus package — real-time network status
// pubspec.yaml:
//   connectivity_plus: ^6.0.5

import 'package:connectivity_plus/connectivity_plus.dart';

// Riverpod provider that streams connectivity changes
@Riverpod(keepAlive: true)
Stream<bool> isOnline(IsOnlineRef ref) {
  return Connectivity()
      .onConnectivityChanged
      .map((results) => !results.contains(ConnectivityResult.none));
}

// Use in a Notifier to trigger sync automatically
@riverpod
class AppSync extends _$AppSync {
  StreamSubscription? _sub;

  @override
  bool build() {
    // Watch connectivity — auto-sync when going from offline → online
    ref.listen(isOnlineProvider, (prev, next) {
      final wasOffline = prev?.valueOrNull == false;
      final isNowOnline = next.valueOrNull == true;
      if (wasOffline && isNowOnline) {
        _syncPendingOperations();
      }
    });

    // Clean up subscription when provider is disposed
    ref.onDispose(() => _sub?.cancel());
    return true;
  }

  Future<void> _syncPendingOperations() async {
    final queue = ref.read(syncQueueProvider);
    await queue.flush(ref.read(remoteApiProvider));
  }
}

// In main.dart: ProviderScope → AppSync is initialized at startup
// It will auto-sync whenever the device reconnects.'''),

          const SizedBox(height: 20),

          // ── 3. Conflict resolution ───────────────────────────────────
          _header('3. Conflict Resolution Strategies', Colors.orange),
          _card(
            color: Colors.orange.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('The 3 main strategies:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                _ConflictRow('Last-Write-Wins (LWW)',
                    'Whoever has the latest updatedAt timestamp wins. Simple but can lose data if clocks are skewed.'),
                SizedBox(height: 6),
                _ConflictRow('Server-Wins',
                    'The server version always overwrites client changes. No data loss on server, but client changes are silently discarded.'),
                SizedBox(height: 6),
                _ConflictRow('Client-Wins',
                    'Local changes always win over server. Risk: another device\'s changes are overwritten.'),
                SizedBox(height: 6),
                _ConflictRow('Merge (CRDT)',
                    'Mathematically merge both versions — no conflict possible. See topic 03. Best for collaborative apps.'),
              ],
            ),
          ),
          _code(r'''
// Last-Write-Wins implementation:
class TransactionRepository {
  Future<Transaction> save(Transaction local) async {
    try {
      final remote = await _api.save(local);
      await _db.upsert(remote);    // server version is the truth
      return remote;
    } on ConflictException catch (e) {
      // Server has a newer version — decide which wins
      final server = e.serverVersion;

      if (local.updatedAt.isAfter(server.updatedAt)) {
        // Local is newer — force push (Client-Wins)
        return _api.forceUpdate(local);
      } else {
        // Server is newer — accept server version (Server-Wins / LWW)
        await _db.upsert(server);
        return server;
      }
    }
  }
}

// For financial apps: Server-Wins is safest (never lose server transactions)
// For notes/content: LWW or CRDT (user wrote something → preserve it)'''),

          const SizedBox(height: 20),

          // ── 4. Sync status UI ─────────────────────────────────────────
          _header('4. Sync Status Indicators', Colors.purple),
          _code(r'''
// Sync status enum — drives the UI indicator
enum SyncStatus { synced, syncing, pending, error }

// Status badge shown in the app bar or settings screen
Widget _syncBadge(SyncStatus status) {
  final (icon, color, label) = switch (status) {
    SyncStatus.synced  => (Icons.cloud_done,   Colors.green, "Synced"),
    SyncStatus.syncing => (Icons.sync,          Colors.blue,  "Syncing..."),
    SyncStatus.pending => (Icons.cloud_upload,  Colors.orange,"Pending"),
    SyncStatus.error   => (Icons.cloud_off,     Colors.red,   "Sync error"),
  };

  return Chip(
    avatar: Icon(icon, color: color, size: 16),
    label: Text(label, style: TextStyle(fontSize: 11, color: color)),
    backgroundColor: color.withOpacity(0.1),
  );
}'''),

          const SizedBox(height: 16),
          _card(
            color: Colors.green.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• Sync queue persists ops to Isar — survives app restarts and crashes'),
                Text('• connectivity_plus streams network changes → auto-sync on reconnect'),
                Text('• LWW is simplest conflict strategy — use updatedAt timestamp'),
                Text('• Use UUIDs as operation IDs — safe to replay on network retry'),
                Text('• Dead-letter queue for operations that fail 3 times — show error to user'),
                Text('• For financial data: Server-Wins is the safest default'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConflictRow extends StatelessWidget {
  final String strategy;
  final String description;
  const _ConflictRow(this.strategy, this.description);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(strategy, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ),
        Expanded(child: Text(description, style: const TextStyle(fontSize: 12))),
      ],
    );
  }
}

Widget _header(String t, Color c) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(t, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: c)),
    );
Widget _code(String code) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(6)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(code, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCDD6F4))),
      ),
    );
Widget _card({required Color color, required Widget child}) =>
    Card(color: color, child: Padding(padding: const EdgeInsets.all(12), child: child));
