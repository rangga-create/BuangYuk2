import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getActivities(String uid) {
    return _firestore
        .collection('reward_transactions')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {...doc.data(), 'id': doc.id, '_source': 'reward'})
            .toList());
  }

  Stream<List<Map<String, dynamic>>> getAllActivities(String uid) {
    return _firestore
        .collection('reward_transactions')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {...doc.data(), 'id': doc.id, '_source': 'reward'})
            .toList());
  }
}
