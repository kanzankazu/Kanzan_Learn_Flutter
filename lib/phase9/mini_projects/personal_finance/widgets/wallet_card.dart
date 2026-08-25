/// Reusable horizontal wallet card widget for the dashboard.
import 'package:flutter/material.dart';
import '../domain/entities/wallet.dart';
import 'amount_display.dart';

/// A compact card showing a wallet's name, type, and current balance.
/// Designed to be shown in a horizontal scroll list on the dashboard.
class WalletCard extends StatelessWidget {
  final Wallet wallet;

  const WalletCard({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(wallet.colorValue),
            Color(wallet.colorValue).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(wallet.colorValue).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Wallet type emoji + name
          Row(
            children: [
              Text(wallet.type.emoji,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  wallet.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Balance
          AmountDisplay(
            amount: wallet.balance,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
