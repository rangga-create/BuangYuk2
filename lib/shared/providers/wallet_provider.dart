import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_wallet_service.dart';

final walletServiceProvider = Provider<FirebaseWalletService>((ref) {
  return FirebaseWalletService();
});

final walletProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return ref.read(walletServiceProvider).getWallet(uid).map((snap) => snap.data());
});

final walletTransactionsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return ref.read(walletServiceProvider).getTransactions(uid).map(
    (snap) => snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList(),
  );
});

final leaderboardProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(walletServiceProvider).getLeaderboard().map(
    (snap) => snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList(),
  );
});
