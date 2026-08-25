/// Phase 10.2 — Topic 03: CRDT (Conflict-free Replicated Data Types)
///
/// CRDTs are data structures that can be updated independently by multiple
/// nodes (devices) and then merged automatically — without conflicts.
///
/// Why CRDTs matter for Flutter apps:
/// - Google Docs / Figma / Notion use CRDTs for collaborative editing
/// - Offline-first apps where multiple devices edit the same data
/// - No central coordinator needed for merging
///
/// Core idea: if you design your data type so that:
///   merge(a, b) == merge(b, a)         (commutative)
///   merge(a, a) == a                   (idempotent)
///   merge(a, merge(b, c)) == merge(merge(a, b), c) (associative)
/// then merging always produces the correct result, regardless of order.
///
/// Key concepts covered:
/// 1. G-Counter (Grow-only counter) — simplest CRDT
/// 2. PN-Counter (increment + decrement counter)
/// 3. LWW-Register (Last-Write-Wins Register)
/// 4. OR-Set (Observed-Remove Set) — add/remove without conflict
/// 5. LWW-Map — CRDT key-value store
/// 6. crdt package — ready-to-use Dart CRDT implementation
/// 7. Practical use: collaborative note editing in Flutter
import 'package:flutter/material.dart';

void main() => runApp(const _StandaloneApp());

class _StandaloneApp extends StatelessWidget {
  const _StandaloneApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRDT Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple), useMaterial3: true),
      home: const CrdtDemo(),
    );
  }
}

class CrdtDemo extends StatefulWidget {
  const CrdtDemo({super.key});
  @override
  State<CrdtDemo> createState() => _CrdtDemoState();
}

class _CrdtDemoState extends State<CrdtDemo> {
  // ── Live G-Counter demo ──────────────────────────────────────────────────
  // Two "devices" increment independently, then merge
  final _deviceA = _GCounter('deviceA');
  final _deviceB = _GCounter('deviceB');

  // ── Live LWW-Register demo ───────────────────────────────────────────────
  _LwwRegister<String>? _regA;
  _LwwRegister<String>? _regB;
  String _mergedValue = '—';

  @override
  void initState() {
    super.initState();
    _regA = _LwwRegister('deviceA', 'Hello from A',
        DateTime(2026, 8, 24, 10, 0));
    _regB = _LwwRegister('deviceB', 'Hello from B',
        DateTime(2026, 8, 24, 11, 0)); // B is newer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('03 — CRDT'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            color: Colors.purple.shade50,
            child: const Text(
              'CRDT = Conflict-free Replicated Data Type\n\n'
              'A mathematical data structure that can be modified independently '
              'on multiple devices and always merged correctly — even if changes '
              'happened in different orders.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),

          // ── 1. G-Counter live demo ────────────────────────────────────
          _header('1. G-Counter — Live Demo', Colors.purple),
          const Text(
            'Each device has its own counter. Merge = take max per device.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _counterTile('Device A', _deviceA.value, () => setState(() => _deviceA.increment())),
                      const Icon(Icons.sync_alt, color: Colors.grey),
                      _counterTile('Device B', _deviceB.value, () => setState(() => _deviceB.increment())),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Merged total: ', style: TextStyle(color: Colors.grey)),
                      Text(
                        '${_deviceA.merge(_deviceB).total}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple),
                      ),
                    ],
                  ),
                  const Text(
                    'merge = sum(max per device) — always correct regardless of order!',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          _code(r'''
// G-Counter: each node has its own slot, increment only
class GCounter {
  final String nodeId;
  final Map<String, int> _counts; // { "deviceA": 3, "deviceB": 5 }

  GCounter(this.nodeId) : _counts = {};

  void increment() => _counts[nodeId] = (_counts[nodeId] ?? 0) + 1;

  // Total = sum of all node counts
  int get total => _counts.values.fold(0, (s, v) => s + v);

  // Merge = take the MAX value per node (not sum!)
  // This is idempotent: merge(a, a) == a
  GCounter merge(GCounter other) {
    final result = GCounter(nodeId).._counts.addAll(_counts);
    for (final entry in other._counts.entries) {
      result._counts[entry.key] = [
        result._counts[entry.key] ?? 0,
        entry.value,
      ].reduce(max);
    }
    return result;
  }
}
// merge(A={a:3,b:0}, B={a:1,b:5}) = {a:3,b:5} → total=8 ✅
// Regardless of order: merge(B,A) = {a:3,b:5} → same result ✅'''),

          const SizedBox(height: 20),

          // ── 2. LWW-Register demo ──────────────────────────────────────
          _header('2. LWW-Register — Last Write Wins', Colors.blue),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _registerTile('Device A', _regA?.value ?? '', _regA?.timestamp ?? DateTime(0)),
                  _registerTile('Device B', _regB?.value ?? '', _regB?.timestamp ?? DateTime(0)),
                  const Divider(),
                  FilledButton(
                    onPressed: () {
                      final merged = _regA!.merge(_regB!);
                      setState(() => _mergedValue = merged.value);
                    },
                    child: const Text('Merge'),
                  ),
                  if (_mergedValue != '—')
                    Text('Merged → "$_mergedValue" (B wins — newer timestamp)',
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          _code(r'''
// LWW-Register: stores a value + timestamp
// merge = pick the value with the latest timestamp
class LwwRegister<T> {
  final String nodeId;
  T value;
  DateTime timestamp;

  LwwRegister(this.nodeId, this.value, this.timestamp);

  void write(T newValue) {
    value = newValue;
    timestamp = DateTime.now();
  }

  LwwRegister<T> merge(LwwRegister<T> other) {
    if (other.timestamp.isAfter(timestamp)) {
      return LwwRegister(other.nodeId, other.value, other.timestamp);
    }
    return this;
  }
}

// Use case: document title, user profile, settings
// NOT suitable for: text editing (use CRDT text type instead)'''),

          const SizedBox(height: 20),

          // ── 3. OR-Set ─────────────────────────────────────────────────
          _header('3. OR-Set — Add/Remove Without Conflict', Colors.teal),
          _code(r'''
// Problem with naive sets:
// Device A removes "apple" while Device B adds "apple"
// Naive merge: "was apple removed or added?" — CONFLICT!
//
// OR-Set solution:
// Each add gets a unique tag. Remove only removes THAT specific tag.
// If another device re-added it with a different tag — it stays.

class ORSet<T> {
  // Stores pairs of (element, uniqueTag)
  final Set<(T, String)> _added   = {};
  final Set<(T, String)> _removed = {};

  void add(T element) {
    _added.add((element, const Uuid().v4()));  // each add is unique
  }

  void remove(T element) {
    // Remove all observed tags for this element
    final toRemove = _added.where((pair) => pair.$1 == element).toSet();
    _removed.addAll(toRemove);
  }

  // The "live" set = added - removed
  Set<T> get elements {
    final live = _added.difference(_removed);
    return live.map((p) => p.$1).toSet();
  }

  ORSet<T> merge(ORSet<T> other) {
    return ORSet<T>()
      .._added.addAll(_added)
      .._added.addAll(other._added)
      .._removed.addAll(_removed)
      .._removed.addAll(other._removed);
  }
}

// Usage example:
// Device A: adds "apple" with tag "uuid1"
// Device B: removes "apple" (removes "uuid1")
// Device B: adds "apple" again with tag "uuid2"
// Merge: "uuid1" is removed, but "uuid2" is still in _added → apple survives!'''),

          const SizedBox(height: 20),

          // ── 4. crdt package ───────────────────────────────────────────
          _header('4. The crdt Package', Colors.orange),
          _code(r'''
// pubspec.yaml
dependencies:
  crdt: ^3.2.3

// The crdt package provides CrdtMap — a CRDT key-value store
// backed by HLC (Hybrid Logical Clock) timestamps.
// HLC = wall clock + counter → monotonically increasing even on same machine

import 'package:crdt/crdt.dart';

final doc = MapCrdt<String, String>('deviceA');

// Write a value
doc.put('title', 'My Note');
doc.put('body', 'Hello world');

// Merge with another device's version
final otherDoc = MapCrdt<String, String>('deviceB');
otherDoc.put('body', 'Updated from B');

doc.merge(otherDoc);
// doc['body'] = 'Updated from B' if B's timestamp is later

// Export changeset for sync (only send changes since last sync)
final changeset = doc.getChangeset(since: lastSyncHlc);
await api.pushChangeset(changeset);

final remoteChangeset = await api.pullChangeset(since: lastSyncHlc);
doc.mergeChangeset(remoteChangeset);'''),

          const SizedBox(height: 16),
          _card(
            color: Colors.purple.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• CRDT merge is always correct — commutative, associative, idempotent'),
                Text('• G-Counter: increment-only, merge = max per node'),
                Text('• LWW-Register: last timestamp wins — simple but can lose data'),
                Text('• OR-Set: unique tags per add → remove never conflicts with re-add'),
                Text('• Use the crdt package for production — HLC timestamps > wall clock'),
                Text('• CRDT is overkill for solo apps — use for multi-device collaboration'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _counterTile(String label, int count, VoidCallback onIncrement) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('$count', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purple)),
        const SizedBox(height: 4),
        FilledButton(onPressed: onIncrement, child: const Text('+1')),
      ],
    );
  }

  Widget _registerTile(String label, String value, DateTime ts) {
    return ListTile(
      dense: true,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('"$value"'),
      trailing: Text(
        '${ts.hour}:${ts.minute.toString().padLeft(2, '0')}',
        style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
      ),
    );
  }
}

/// Minimal G-Counter for the live demo.
class _GCounter {
  final String nodeId;
  final Map<String, int> _counts = {};

  _GCounter(this.nodeId);

  void increment() => _counts[nodeId] = (_counts[nodeId] ?? 0) + 1;
  int get value => _counts[nodeId] ?? 0;
  int get total => _counts.values.fold(0, (s, v) => s + v);

  _GCounter merge(_GCounter other) {
    final result = _GCounter(nodeId).._counts.addAll(_counts);
    for (final e in other._counts.entries) {
      result._counts[e.key] = [result._counts[e.key] ?? 0, e.value].reduce((a, b) => a > b ? a : b);
    }
    return result;
  }
}

/// Minimal LWW-Register for the live demo.
class _LwwRegister<T> {
  final String nodeId;
  final T value;
  final DateTime timestamp;

  _LwwRegister(this.nodeId, this.value, this.timestamp);

  _LwwRegister<T> merge(_LwwRegister<T> other) =>
      other.timestamp.isAfter(timestamp) ? other : this;
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
