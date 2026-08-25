/// Domain entity: Wallet
///
/// A Wallet represents a money container — bank account, e-wallet, or cash.
/// The app supports multiple wallets; the sum of all wallet balances is the
/// user's total net worth.
///
/// Domain rules:
/// - balance can be negative (overdraft is allowed)
/// - name must not be empty (validated at use-case layer)
/// - color is an int (ARGB packed, e.g. 0xFF1B8A5A) for easy serialization

/// The type of financial account this wallet represents.
enum WalletType {
  cash,
  bank,
  eWallet,
  crypto,
  savings;

  /// Human-readable label for the UI.
  String get label => switch (this) {
        cash => 'Cash',
        bank => 'Bank Account',
        eWallet => 'E-Wallet',
        crypto => 'Crypto',
        savings => 'Savings',
      };

  /// Icon for the wallet type chip.
  String get emoji => switch (this) {
        cash => '💵',
        bank => '🏦',
        eWallet => '📱',
        crypto => '₿',
        savings => '🏺',
      };
}

/// An immutable domain entity representing a user's wallet / account.
class Wallet {
  final String id;
  final String name;
  final double balance;
  final WalletType type;

  /// ARGB color packed as int (e.g. 0xFF1B8A5A).
  /// Convert to Flutter Color in the presentation layer:
  /// `Color(wallet.colorValue)`
  final int colorValue;

  const Wallet({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
    required this.colorValue,
  });

  /// Returns a [Color] object from [colorValue].
  ///
  /// Defined here for convenience — in strict Clean Architecture
  /// you would do the conversion only in the presentation layer.
  /// Color is imported from dart:ui which Flutter provides.
  // ignore: avoid_returning_this
  dynamic get color {
    // We avoid importing flutter/material.dart in the domain layer.
    // Presentation layer widgets use: Color(wallet.colorValue) directly.
    return colorValue;
  }

  /// Creates a copy with the given fields replaced.
  Wallet copyWith({
    String? id,
    String? name,
    double? balance,
    WalletType? type,
    int? colorValue,
  }) =>
      Wallet(
        id: id ?? this.id,
        name: name ?? this.name,
        balance: balance ?? this.balance,
        type: type ?? this.type,
        colorValue: colorValue ?? this.colorValue,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Wallet && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Wallet(id: $id, name: $name, balance: $balance)';
}
