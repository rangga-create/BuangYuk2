import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> getNationalStats() {
    return _firestore.collection('admin_stats').doc('national').snapshots();
  }

  Future<Map<String, int>> getRoleCounts() async {
    final usersSnap = await _firestore.collection('users').get();
    int citizens = 0, collectors = 0, admins = 0;
    for (final doc in usersSnap.docs) {
      final role = doc.data()['role'] as String?;
      if (role == 'citizen') citizens++;
      else if (role == 'collector') collectors++;
      else if (role == 'tps_manager' || role == 'government_admin' || role == 'super_admin' || role == 'admin') admins++;
    }
    return {'citizens': citizens, 'collectors': collectors, 'admins': admins};
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllPickups() {
    return _firestore.collection('pickups').orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return _firestore.collection('users').snapshots();
  }
}
