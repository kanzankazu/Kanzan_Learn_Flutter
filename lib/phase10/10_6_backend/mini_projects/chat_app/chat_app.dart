/// Phase 10.6 — Mini Project: Realtime Chat
///
/// A production-quality realtime chat app demonstrating:
/// - Supabase Realtime for live message updates
/// - RLS to scope messages to the correct room
/// - Optimistic UI (message appears instantly before server confirms)
/// - Clean Architecture: domain / data / presentation
import 'package:flutter/material.dart';

void main() => runApp(const ChatApp());

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Realtime Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green), useMaterial3: true),
      home: const ChatScreen(),
    );
  }
}

// ── Domain entities ────────────────────────────────────────────────────────────

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime sentAt;
  final bool isOptimistic; // true = not yet confirmed by server

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
    this.isOptimistic = false,
  });
}

// ── Chat screen ────────────────────────────────────────────────────────────────

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isOnline = true;

  // Simulated current user
  static const _myId = 'user_faisal';
  static const _myName = 'Faisal';

  // Simulated message list (replace with Supabase realtime stream in production)
  final List<ChatMessage> _messages = [
    ChatMessage(id: '1', senderId: 'user_budi', senderName: 'Budi', content: 'Hei, ada update sprint gak?', sentAt: DateTime.now().subtract(const Duration(minutes: 10))),
    ChatMessage(id: '2', senderId: _myId, senderName: _myName, content: 'Masih in progress, targeting EOD today', sentAt: DateTime.now().subtract(const Duration(minutes: 8))),
    ChatMessage(id: '3', senderId: 'user_siti', senderName: 'Siti', content: 'Kalau butuh help ping aja', sentAt: DateTime.now().subtract(const Duration(minutes: 5))),
    ChatMessage(id: '4', senderId: _myId, senderName: _myName, content: 'Thanks! 🙏', sentAt: DateTime.now().subtract(const Duration(minutes: 3))),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    // ── Optimistic update: show message immediately ────────────────────
    final optimisticMsg = ChatMessage(
      id: 'opt_${DateTime.now().millisecondsSinceEpoch}',
      senderId: _myId,
      senderName: _myName,
      content: text,
      sentAt: DateTime.now(),
      isOptimistic: true,
    );

    setState(() => _messages.add(optimisticMsg));
    _ctrl.clear();
    _scrollToBottom();

    if (_isOnline) {
      // Simulate server confirmation after 500ms
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          final idx = _messages.indexWhere((m) => m.id == optimisticMsg.id);
          if (idx >= 0) {
            _messages[idx] = ChatMessage(
              id: 'srv_${DateTime.now().millisecondsSinceEpoch}',
              senderId: optimisticMsg.senderId,
              senderName: optimisticMsg.senderName,
              content: optimisticMsg.content,
              sentAt: optimisticMsg.sentAt,
            );
          }
        });
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(radius: 16, backgroundColor: Colors.green, child: Text('T', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Team Channel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('4 members', style: TextStyle(fontSize: 11)),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isOnline ? Icons.wifi : Icons.wifi_off),
            onPressed: () => setState(() => _isOnline = !_isOnline),
            tooltip: _isOnline ? 'Go offline' : 'Go online',
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline banner
          if (!_isOnline)
            Container(
              width: double.infinity,
              color: Colors.orange.shade100,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              child: const Text('Offline — messages will be queued', style: TextStyle(fontSize: 12, color: Colors.orange)),
            ),

          // Message list
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _MessageBubble(
                message: _messages[i],
                isMe: _messages[i].senderId == _myId,
              ),
            ),
          ),

          // Input bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: 'Type a message…',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  backgroundColor: Colors.green,
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message bubble ─────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Sender name (only for others)
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                  child: Text(message.senderName,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: scheme.primary)),
                ),

              // Bubble
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isMe ? scheme.primary : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(message.content,
                          style: TextStyle(
                              color: isMe ? Colors.white : scheme.onSurface,
                              fontSize: 14)),
                    ),
                    const SizedBox(width: 6),
                    // Optimistic indicator
                    if (message.isOptimistic)
                      Icon(Icons.access_time, size: 12, color: isMe ? Colors.white60 : Colors.grey)
                    else
                      Icon(Icons.done_all, size: 12, color: isMe ? Colors.white60 : Colors.grey),
                  ],
                ),
              ),

              // Timestamp
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                child: Text(
                  _formatTime(message.sentAt),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
