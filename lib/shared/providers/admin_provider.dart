import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_admin_service.dart';

final adminServiceProvider = Provider<FirebaseAdminService>((ref) {
  return FirebaseAdminService();
});

final adminStatsProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  return ref.read(adminServiceProvider).getNationalStats().map((snap) => snap.data());
});

final adminRoleCountsProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.read(adminServiceProvider).getRoleCounts();
});

final adminAllPickupsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(adminServiceProvider).getAllPickups().map(
    (snap) => snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList(),
  );
});

final adminAllUsersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(adminServiceProvider).getAllUsers().map(
    (snap) => snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList(),
  );
});
