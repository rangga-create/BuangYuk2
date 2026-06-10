import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseWalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> getWallet(String uid) {
    return _firestore.collection('rewards').doc(uid).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTransactions(String uid) {
    return _firestore
        .collection('reward_transactions')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLeaderboard() {
    return _firestore
        .collection('leaderboards')
        .orderBy('totalPoints', descending: true)
        .limit(50)
        .snapshots();
  }
}
