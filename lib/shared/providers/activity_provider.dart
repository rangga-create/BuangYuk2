import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_activity_service.dart';

final activityServiceProvider = Provider<FirebaseActivityService>((ref) {
  return FirebaseActivityService();
});

final activitiesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return ref.read(activityServiceProvider).getActivities(uid);
});
