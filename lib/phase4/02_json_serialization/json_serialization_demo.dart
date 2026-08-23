/// Demo 02 — JSON Serialization.
///
/// **Concepts covered:**
/// - Manual fromJson / toJson — the foundation you must understand
/// - Why code generation (freezed + json_serializable) exists and what it solves
/// - Nested objects in JSON
/// - Nullable fields and default values
/// - Lists of objects
/// - Handling unknown/extra fields gracefully
/// - The "data class" problem in Dart: equality, copyWith, toString
///
/// **Note on code generation:**
/// In real projects you run `flutter pub run build_runner build` to generate
/// `.freezed.dart` and `.g.dart` files automatically. In this demo we write
/// everything manually so you understand what the generator produces.
/// The generated output is functionally identical — just less typing.
library;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. Manual fromJson / toJson (baseline)
// ─────────────────────────────────────────────────────────────────────────────

/// Simple user model — manual serialization.
/// This is the raw approach every developer should understand first.
class UserManual {
  final int id;
  final String name;
  final String email;
  final String? phone; // nullable — may not be in JSON

  const UserManual({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  /// Parse from a JSON map. The `as` casts are intentional — they throw early
  /// with a clear error if the server sends a wrong type.
  factory UserManual.fromJson(Map<String, dynamic> json) => UserManual(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?, // safe — handles null
      );

  /// Convert back to JSON (for POST/PUT requests).
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone, // omit null fields
      };

  @override
  String toString() => 'UserManual(id: $id, name: $name, email: $email)';
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Nested objects
// ─────────────────────────────────────────────────────────────────────────────

class Address {
  final String street;
  final String city;
  final String zipcode;

  const Address({
    required this.street,
    required this.city,
    required this.zipcode,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        street: json['street'] as String,
        city: json['city'] as String,
        zipcode: json['zipcode'] as String,
      );

  Map<String, dynamic> toJson() => {
        'street': street,
        'city': city,
        'zipcode': zipcode,
      };

  @override
  String toString() => '$street, $city $zipcode';
}

/// User with a nested Address object.
class UserWithAddress {
  final int id;
  final String name;
  final Address address; // nested object

  const UserWithAddress({
    required this.id,
    required this.name,
    required this.address,
  });

  factory UserWithAddress.fromJson(Map<String, dynamic> json) =>
      UserWithAddress(
        id: json['id'] as int,
        name: json['name'] as String,
        // Cast the nested map and delegate to Address.fromJson
        address: Address.fromJson(json['address'] as Map<String, dynamic>),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Lists of objects
// ─────────────────────────────────────────────────────────────────────────────

/// Parses a JSON array into a typed Dart list.
/// Pattern: (json as List).map((e) => Model.fromJson(e)).toList()
List<UserManual> usersFromJsonList(List<dynamic> jsonList) =>
    jsonList.map((e) => UserManual.fromJson(e as Map<String, dynamic>)).toList();

// ─────────────────────────────────────────────────────────────────────────────
// 4. What freezed gives you (simulated manually)
// ─────────────────────────────────────────────────────────────────────────────

/// This is what a freezed-generated class looks like conceptually.
/// freezed adds: immutability, equality, copyWith, toString for free.
///
/// With freezed you write:
/// ```dart
/// @freezed
/// class Post with _$Post {
///   const factory Post({required int id, required String title}) = _Post;
///   factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
/// }
/// ```
/// And the generator produces everything below automatically.
class Post {
  final int id;
  final String title;
  final String body;
  final int userId;

  const Post({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as int,
        title: json['title'] as String,
        body: json['body'] as String,
        userId: json['userId'] as int,
      );

  /// copyWith — update one field without mutating the original.
  /// This is the #1 reason to use freezed in state management.
  Post copyWith({int? id, String? title, String? body, int? userId}) => Post(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
        userId: userId ?? this.userId,
      );

  /// Value equality — two Post objects are equal if all fields match.
  /// Without freezed you have to write this yourself for every model.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Post &&
          id == other.id &&
          title == other.title &&
          body == other.body &&
          userId == other.userId;

  @override
  int get hashCode => Object.hash(id, title, body, userId);

  @override
  String toString() => 'Post(id: $id, title: $title)';
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Sealed Result type (safe error handling without try/catch in UI)
// ─────────────────────────────────────────────────────────────────────────────

/// A simple Result<T> type. In real apps use freezed union types:
/// ```dart
/// @freezed
/// sealed class Result<T> with _$Result<T> {
///   const factory Result.success(T data) = Success<T>;
///   const factory Result.failure(String message) = Failure<T>;
/// }
/// ```
sealed class Result<T> {}

class Success<T> extends Result<T> {
  final T data;
  Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  Failure(this.message);
}

// ─────────────────────────────────────────────────────────────────────────────
// Dummy JSON data for demo (no network needed)
// ─────────────────────────────────────────────────────────────────────────────

const _dummyUsersJson = [
  {
    'id': 1,
    'name': 'Leanne Graham',
    'email': 'sincere@april.biz',
    'phone': '1-770-736-8031 x56442',
  },
  {
    'id': 2,
    'name': 'Ervin Howell',
    'email': 'shanna@melissa.tv',
    'phone': null, // nullable field
  },
  {'id': 3, 'name': 'Clementine Bauch', 'email': 'bauch@yolanda.io'},
];

const _dummyUserWithAddressJson = {
  'id': 1,
  'name': 'Leanne Graham',
  'address': {
    'street': 'Kulas Light',
    'city': 'Gwenborough',
    'zipcode': '92998-3874',
  },
};

const _dummyPostsJson = [
  {
    'id': 1,
    'userId': 1,
    'title': 'sunt aut facere repellat provident',
    'body': 'quia et suscipit suscipit recusandae consequuntur',
  },
  {
    'id': 2,
    'userId': 1,
    'title': 'qui est esse',
    'body': 'est rerum tempore vitae sequi sint',
  },
];

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class JsonSerializationDemo extends StatelessWidget {
  const JsonSerializationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON Serialization Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const _JsonMenuScreen(),
    );
  }
}

class _JsonMenuScreen extends StatelessWidget {
  const _JsonMenuScreen();

  @override
  Widget build(BuildContext context) {
    // Parse demo data
    final users = usersFromJsonList(_dummyUsersJson);
    final userWithAddress =
        UserWithAddress.fromJson(_dummyUserWithAddressJson);
    final posts = _dummyPostsJson
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();

    // copyWith demo
    final original = posts.first;
    final updated = original.copyWith(title: 'Updated title');

    // Result type demo
    Result<UserManual> parseUser(Map<String, dynamic> json) {
      try {
        return Success(UserManual.fromJson(json));
      } catch (e) {
        return Failure('Parse error: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON Serialization'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 1. fromJson list ──────────────────────────────────────────────
          _Section(
            title: '1. Parse JSON list → List<UserManual>',
            child: Column(
              children: users
                  .map((u) => ListTile(
                        dense: true,
                        leading: CircleAvatar(child: Text('${u.id}')),
                        title: Text(u.name),
                        subtitle: Text(
                            '${u.email}${u.phone != null ? '\n${u.phone}' : ' (no phone)'}'),
                      ))
                  .toList(),
            ),
          ),

          // ── 2. Nested object ──────────────────────────────────────────────
          _Section(
            title: '2. Nested object: UserWithAddress',
            child: ListTile(
              dense: true,
              leading: CircleAvatar(child: Text('${userWithAddress.id}')),
              title: Text(userWithAddress.name),
              subtitle: Text(userWithAddress.address.toString()),
            ),
          ),

          // ── 3. copyWith ───────────────────────────────────────────────────
          _Section(
            title: '3. copyWith — immutable update',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Original: ${original.title}'),
                Text('After copyWith: ${updated.title}'),
                const SizedBox(height: 4),
                Text('Same object? ${identical(original, updated)} '
                    '(always false — copyWith creates a new instance)'),
                Text('Equal? ${original == updated} '
                    '(false because title changed)'),
              ],
            ),
          ),

          // ── 4. Result type ────────────────────────────────────────────────
          _Section(
            title: '4. Result<T> — safe error handling',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(builder: (_) {
                  final result =
                      parseUser({'id': 1, 'name': 'Alice', 'email': 'a@b.com'});
                  return switch (result) {
                    Success(:final data) =>
                      Text('✅ Parsed: ${data.name}'),
                    Failure(:final message) =>
                      Text('❌ Error: $message', style: const TextStyle(color: Colors.red)),
                  };
                }),
                const SizedBox(height: 4),
                Builder(builder: (_) {
                  // bad JSON — missing required field
                  final result = parseUser({'id': 'not-an-int', 'name': 'Bob'});
                  return switch (result) {
                    Success(:final data) => Text('✅ Parsed: ${data.name}'),
                    Failure(:final message) =>
                      Text('❌ Error: $message',
                          style: const TextStyle(color: Colors.red, fontSize: 12)),
                  };
                }),
              ],
            ),
          ),

          // ── 5. toJson ─────────────────────────────────────────────────────
          _Section(
            title: '5. toJson → ready to send with Dio',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('UserManual.toJson():'),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey.shade100,
                  child: Text(
                    users.first.toJson().entries
                        .map((e) => '  "${e.key}": "${e.value}"')
                        .join('\n'),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }
}
