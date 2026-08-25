/// Phase 10.6 — Topic 03: Supabase Advanced
///
/// Phase 4 covered Firebase basics. This topic covers Supabase —
/// the open-source Firebase alternative — with production-level patterns.
///
/// Supabase = PostgreSQL + Auth + Storage + Realtime + Edge Functions
///
/// Key concepts covered:
/// 1. RLS (Row Level Security) — database-level access control
/// 2. Realtime subscriptions — listen to DB changes
/// 3. Edge Functions — Deno/TypeScript serverless functions
/// 4. Storage — file upload with RLS policies
/// 5. Auth flows — email, OAuth, magic link, phone OTP
/// 6. Advanced queries — joins, filtering, pagination
/// 7. Flutter Supabase client setup + Riverpod integration
import 'package:flutter/material.dart';

void main() => runApp(const _App());
class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Supabase Advanced',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green), useMaterial3: true),
    home: const SupabaseAdvancedDemo(),
  );
}

class SupabaseAdvancedDemo extends StatelessWidget {
  const SupabaseAdvancedDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('03 — Supabase Advanced'), backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(color: Colors.green.shade50, child: const Text(
            'Supabase = open-source Firebase alternative.\n\n'
            'Built on PostgreSQL — use full SQL, joins, RLS policies.\n'
            'Host yourself or use Supabase Cloud (generous free tier).',
            style: TextStyle(fontSize: 13),
          )),
          const SizedBox(height: 16),

          _h('1. Setup + Initialization', Colors.green.shade700),
          _code(r'''
# pubspec.yaml
dependencies:
  supabase_flutter: ^2.8.4

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url:      'https://your-project.supabase.co',
    anonKey:  'your-anon-key',
    // authFlowType: AuthFlowType.pkce (recommended for mobile)
  );

  runApp(const MyApp());
}

// Access the client anywhere:
final supabase = Supabase.instance.client;

// Riverpod provider:
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(SupabaseClientRef ref) =>
    Supabase.instance.client;'''),

          const SizedBox(height: 20),
          _h('2. Row Level Security (RLS)', Colors.orange),
          _card(color: Colors.orange.shade50, child: const Text(
            'RLS is the most important Supabase concept.\n\n'
            'It enforces access control at the database level — even if your '
            'Flutter app has a bug, users can NEVER read or write data they '
            'are not authorized to access.',
            style: TextStyle(fontSize: 13),
          )),
          _code(r'''
-- SQL in Supabase Dashboard → Table Editor → Policies

-- Table: messages
-- Policy: users can only read messages in rooms they are a member of

-- 1. Enable RLS on the table
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- 2. READ policy: users can only see messages in their rooms
CREATE POLICY "users_read_own_messages" ON messages
  FOR SELECT USING (
    room_id IN (
      SELECT room_id FROM room_members
      WHERE user_id = auth.uid()  -- auth.uid() = currently logged-in user
    )
  );

-- 3. INSERT policy: users can only insert in rooms they belong to
CREATE POLICY "users_insert_own_messages" ON messages
  FOR INSERT WITH CHECK (
    sender_id = auth.uid()  -- can only send as yourself
    AND room_id IN (
      SELECT room_id FROM room_members WHERE user_id = auth.uid()
    )
  );

-- 4. DELETE policy: users can only delete their own messages
CREATE POLICY "users_delete_own_messages" ON messages
  FOR DELETE USING (sender_id = auth.uid());

-- Now: if Flutter queries supabase.from('messages').select(), it
-- automatically only returns rows allowed by the policy.
-- No extra WHERE clause needed in Dart code!'''),

          const SizedBox(height: 20),
          _h('3. Realtime Subscriptions', Colors.blue),
          _code(r'''
// Subscribe to changes in the messages table
// Flutter updates automatically when another user inserts/updates/deletes

@riverpod
Stream<List<Message>> chatMessages(ChatMessagesRef ref, String roomId) async* {
  final supabase = ref.watch(supabaseClientProvider);

  // Initial fetch
  final initial = await supabase
      .from('messages')
      .select('*, profiles(name, avatar_url)')
      .eq('room_id', roomId)
      .order('created_at');

  yield initial.map(Message.fromJson).toList();

  // Subscribe to real-time changes
  final channel = supabase.channel('messages:$roomId')
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'messages',
      filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'room_id', value: roomId),
      callback: (payload) {
        // Trigger a re-fetch when any change happens in this room
        ref.invalidateSelf();
      },
    )
    .subscribe();

  // Clean up when provider is disposed
  ref.onDispose(() => supabase.removeChannel(channel));
}'''),

          const SizedBox(height: 20),
          _h('4. Edge Functions', Colors.purple),
          _code(r'''
// Edge Functions = Deno/TypeScript serverless functions
// Run server-side logic without managing servers

// supabase/functions/send-notification/index.ts
import { serve } from "https://deno.land/std/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  const { userId, message } = await req.json()

  // Server-side logic with service_role key (bypasses RLS)
  const supabase = createClient(Deno.env.get("URL")!, Deno.env.get("SERVICE_KEY")!)

  // Send push notification via FCM
  const { data: user } = await supabase.from("profiles").select("fcm_token").eq("id", userId).single()
  await sendFcmNotification(user.fcm_token, message)

  return new Response(JSON.stringify({ sent: true }), { headers: { "Content-Type": "application/json" } })
})

// Deploy: supabase functions deploy send-notification

// Call from Flutter:
final response = await supabase.functions.invoke(
  'send-notification',
  body: {'userId': '123', 'message': 'You have a new message!'},
);
print(response.data); // { sent: true }'''),

          const SizedBox(height: 16),
          _card(color: Colors.green.shade50, child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• RLS = database-level security — enable it on ALL tables'),
              Text('• auth.uid() in policies = automatically scoped to logged-in user'),
              Text('• Realtime: channel.onPostgresChanges() → live DB updates in Flutter'),
              Text('• Edge Functions: Deno serverless, call from Flutter via supabase.functions.invoke()'),
              Text('• Use service_role key only in Edge Functions (server-side), NEVER in Flutter'),
              Text('• anon key in Flutter is safe because RLS policies control what it can access'),
            ],
          )),
        ],
      ),
    );
  }
}

Widget _h(String t, Color c) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: c)));
Widget _code(String s) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(6)), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(s, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCDD6F4)))));
Widget _card({required Color color, required Widget child}) => Card(color: color, child: Padding(padding: const EdgeInsets.all(12), child: child));
