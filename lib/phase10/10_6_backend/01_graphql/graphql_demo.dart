/// Phase 10.6 — Topic 01: GraphQL
///
/// GraphQL is an API query language where the CLIENT specifies exactly
/// what data it needs — no over-fetching, no under-fetching.
///
/// REST vs GraphQL:
/// - REST: multiple endpoints, each returns a fixed shape
/// - GraphQL: one endpoint (/graphql), client writes queries
///
/// Key concepts covered:
/// 1. Schema — types, queries, mutations, subscriptions
/// 2. Queries — read data, choose specific fields
/// 3. Mutations — write data, receive the result
/// 4. Subscriptions — real-time updates over WebSocket
/// 5. Variables — parameterized operations
/// 6. Fragments — reusable field selections
/// 7. graphql_flutter package — GQL clients, widgets
/// 8. ferry package — code-gen, type-safe queries
import 'package:flutter/material.dart';

void main() => runApp(const _App());
class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'GraphQL',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink), useMaterial3: true),
    home: const GraphqlDemo(),
  );
}

class GraphqlDemo extends StatelessWidget {
  const GraphqlDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('01 — GraphQL'), backgroundColor: Colors.pink, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(color: Colors.pink.shade50, child: const Text(
            'GraphQL = one endpoint, client-defined queries.\n\n'
            'Instead of GET /users/1 then GET /users/1/posts, you write:\n'
            'query { user(id:"1") { name posts { title } } }\n'
            'and get exactly what you asked for in ONE request.',
            style: TextStyle(fontSize: 13),
          )),
          const SizedBox(height: 16),

          _h('1. Schema Definition (server side)', Colors.pink),
          _code(r'''
# GraphQL Schema (SDL — Schema Definition Language)
# Defined on the server, shared with the client

type User {
  id:        ID!      # ! = non-null
  name:      String!
  email:     String!
  posts:     [Post!]! # list of posts
  createdAt: DateTime!
}

type Post {
  id:      ID!
  title:   String!
  body:    String!
  author:  User!
  tags:    [String!]!
}

type Query {
  # Read operations
  user(id: ID!): User          # returns null if not found
  users(limit: Int, offset: Int): [User!]!
  searchPosts(query: String!): [Post!]!
}

type Mutation {
  # Write operations — always return the affected object
  createPost(input: CreatePostInput!): Post!
  updatePost(id: ID!, input: UpdatePostInput!): Post!
  deletePost(id: ID!): Boolean!
}

type Subscription {
  # Real-time updates over WebSocket
  onPostCreated: Post!
  onUserUpdated(userId: ID!): User!
}

input CreatePostInput {
  title: String!
  body:  String!
  tags:  [String!]
}'''),

          const SizedBox(height: 20),
          _h('2. Queries & Mutations (client side)', Colors.blue),
          _code(r'''
// lib/graphql/queries/get_user.graphql
query GetUser($id: ID!) {
  user(id: $id) {
    id
    name
    email
    # Only request the fields the screen needs — no over-fetching
    posts {
      id
      title
      tags
    }
  }
}

// lib/graphql/mutations/create_post.graphql
mutation CreatePost($input: CreatePostInput!) {
  createPost(input: $input) {
    id
    title
    body
    author {
      id
      name
    }
  }
}

// lib/graphql/subscriptions/post_created.graphql
subscription OnPostCreated {
  onPostCreated {
    id
    title
    author { name }
  }
}'''),

          const SizedBox(height: 20),
          _h('3. graphql_flutter — Runtime Client', Colors.teal),
          _code(r'''
// pubspec.yaml
dependencies:
  graphql_flutter: ^5.2.0

// Setup in main.dart
final _httpLink = HttpLink('https://api.example.com/graphql');
final _authLink = AuthLink(getToken: () async => 'Bearer ${await getToken()}');
final _wsLink = WebSocketLink('wss://api.example.com/graphql');

// Combine links: mutations/queries → HTTP, subscriptions → WebSocket
final _link = Link.split(
  (request) => request.isSubscription,
  _wsLink,
  _authLink.concat(_httpLink),
);

final client = ValueNotifier(
  GraphQLClient(link: _link, cache: GraphQLCache(store: InMemoryStore())),
);

// Wrap app:
GraphQLProvider(client: client, child: const MyApp())

// Query widget:
Query(
  options: QueryOptions(
    document: gql(r"query GetUser(\$id: ID!) { user(id: \$id) { id name email } }"),
    variables: {'id': '123'},
    pollInterval: const Duration(seconds: 30), // auto-refresh
  ),
  builder: (result, {refetch, fetchMore}) {
    if (result.isLoading) return const CircularProgressIndicator();
    if (result.hasException) return Text(result.exception.toString());

    final user = result.data!['user'] as Map;
    return Text('Hello, ${user["name"]}');
  },
)

// Mutation:
Mutation(
  options: MutationOptions(
    document: gql(r"mutation CreatePost(\$input: CreatePostInput!) { createPost(input: \$input) { id title } }"),
    onCompleted: (data) => print('Created: ${data?["createPost"]["id"]}'),
  ),
  builder: (runMutation, result) {
    return ElevatedButton(
      onPressed: () => runMutation({'input': {'title': 'Hello', 'body': '...'}}),
      child: const Text('Create Post'),
    );
  },
)'''),

          const SizedBox(height: 20),
          _h('4. ferry — Code-Gen Type-Safe Client', Colors.purple),
          _code(r'''
# pubspec.yaml
dependencies:
  ferry: ^0.15.2
  ferry_flutter: ^0.5.4

dev_dependencies:
  ferry_generator: ^0.10.2
  build_runner: ^2.4.9

# build.yaml — point to your schema
targets:
  $default:
    builders:
      ferry_generator:
        options:
          schema: lib/graphql/schema.graphql

# Run: dart run build_runner build
# Generates: lib/graphql/__generated__/get_user.var.gql.dart etc.

// Usage — fully typed, no Map<String, dynamic>
final req = GGetUserReq((b) => b..vars.id = '123');

// In a Riverpod provider:
ref.watch(
  ferryClientProvider.select((client) => client.request(req))
).listen((response) {
  final user = response.data?.user;
  if (user != null) {
    print(user.name);      // typed String, not dynamic
    print(user.email);     // typed String
    user.posts.forEach((p) => print(p.title)); // typed list
  }
});'''),

          const SizedBox(height: 16),
          _card(color: Colors.pink.shade50, child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Key Takeaways', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• GraphQL: one endpoint, client chooses fields → no over/under-fetching'),
              Text('• Schema = contract between frontend and backend (SDL)'),
              Text('• Query = read, Mutation = write, Subscription = real-time'),
              Text('• graphql_flutter = runtime widgets (Query, Mutation, Subscription)'),
              Text('• ferry = code-gen for full type safety (recommended for production)'),
              Text('• Variables = parameterized queries — NEVER concatenate strings into GQL'),
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
