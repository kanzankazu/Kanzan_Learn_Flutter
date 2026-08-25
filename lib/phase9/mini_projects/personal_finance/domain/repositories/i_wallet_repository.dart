/// Domain repository interface: IWalletRepository
import '../entities/wallet.dart';

abstract interface class IWalletRepository {
  Future<List<Wallet>> getAllWallets();
  Future<Wallet?> getWalletById(String id);
  Future<Wallet> addWallet(Wallet wallet);
  Future<Wallet> updateWallet(Wallet wallet);
  Future<void> deleteWallet(String id);

  /// Adjusts the balance of [walletId] by [delta] (positive = add, negative = subtract).
  Future<void> adjustBalance({required String walletId, required double delta});

  /// Returns the sum of all wallet balances (net worth).
  Future<double> getTotalNetWorth();

  Stream<List<Wallet>> watchAllWallets();
}
