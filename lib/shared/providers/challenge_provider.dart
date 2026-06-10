import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_challenge_service.dart';

final challengeServiceProvider = Provider<FirebaseChallengeService>((ref) {
  return FirebaseChallengeService();
});

final weeklyChallengesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(challengeServiceProvider).getWeeklyChallenges().map(
    (snap) => snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList(),
  );
});

final achievementsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return ref.read(challengeServiceProvider).getAchievements(uid).map(
    (snap) => snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList(),
  );
});
