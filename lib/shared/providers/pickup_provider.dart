import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_pickup_service.dart';

final pickupServiceProvider = Provider<FirebasePickupService>((ref) {
  return FirebasePickupService();
});

final activePickupsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return ref.read(pickupServiceProvider).getActivePickups(uid).map(
    (snap) => snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList(),
  );
});

final pickupHistoryProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return ref.read(pickupServiceProvider).getPickupHistory(uid).map(
    (snap) => snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList(),
  );
});

final collectorTasksProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return ref.read(pickupServiceProvider).getCollectorTasks(uid).map(
    (snap) => snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList(),
  );
});

final collectorHistoryProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return ref.read(pickupServiceProvider).getCollectorHistory(uid).map(
    (snap) => snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList(),
  );
});
