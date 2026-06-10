import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getWeeklyChallenges() {
    return _firestore
        .collection('challenges')
        .where('type', isEqualTo: 'weekly')
        .orderBy('deadline', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAchievements(String uid) {
    return _firestore
        .collection('user_achievements')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserChallengeProgress(
      String uid) {
    return _firestore
        .collection('user_challenges')
        .doc(uid)
        .snapshots();
  }

  Future<Map<String, dynamic>> getDefaultChallenges() async {
    final snap = await _firestore.collection('challenges').limit(10).get();
    return {'challenges': snap.docs.map((d) => d.data()).toList()};
  }
}
