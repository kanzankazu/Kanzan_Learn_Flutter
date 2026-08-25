/// Wallets Screen — Personal Finance Manager
import 'package:flutter/material.dart';
import '../domain/entities/wallet.dart';
import '../widgets/amount_display.dart';

/// Shows all wallets, their balances, and total net worth.
class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  static final _wallets = [
    Wallet(id: '1', name: 'Cash', balance: 1200000, type: WalletType.cash, colorValue: 0xFF2E7D32),
    Wallet(id: '2', name: 'BCA Savings', balance: 8750000, type: WalletType.bank, colorValue: 0xFF0D47A1),
    Wallet(id: '3', name: 'GoPay', balance: 2500000, type: WalletType.eWallet, colorValue: 0xFF1565C0),
    Wallet(id: '4', name: 'Dana', balance: 150000, type: WalletType.eWallet, colorValue: 0xFF00838F),
  ];

  @override
  Widget build(BuildContext context) {
    final total = _wallets.fold(0.0, (s, w) => s + w.balance);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallets'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Total net worth banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              children: [
                const Text('Total Net Worth',
                    style: TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 6),
                AmountDisplay(
                  amount: total,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Wallet list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _wallets.length,
              itemBuilder: (_, i) => _WalletDetailCard(wallet: _wallets[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Wallet'),
      ),
    );
  }
}

/// Expanded wallet card for the wallets screen.
class _WalletDetailCard extends StatelessWidget {
  final Wallet wallet;
  const _WalletDetailCard({required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Wallet type indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(wallet.colorValue).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(wallet.type.emoji,
                  style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            // Name and type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wallet.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(wallet.type.label,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            // Balance
            AmountDisplay(
              amount: wallet.balance,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: wallet.balance >= 0 ? Colors.black87 : Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
