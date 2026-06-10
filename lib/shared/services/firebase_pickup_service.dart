import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebasePickupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getActivePickups(String uid) {
    return _firestore
        .collection('pickups')
        .where('citizenId', isEqualTo: uid)
        .where('status', whereIn: ['requested', 'assigned', 'accepted', 'on_the_way', 'arrived', 'picked_up'])
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPickupHistory(String uid) {
    return _firestore
        .collection('pickups')
        .where('citizenId', isEqualTo: uid)
        .where('status', whereIn: ['completed', 'cancelled'])
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCollectorTasks(String collectorId) {
    return _firestore
        .collection('pickups')
        .where('collectorId', isEqualTo: collectorId)
        .where('status', whereIn: ['assigned', 'accepted', 'on_the_way', 'arrived', 'picked_up'])
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCollectorHistory(String collectorId) {
    return _firestore
        .collection('pickups')
        .where('collectorId', isEqualTo: collectorId)
        .where('status', whereIn: ['completed', 'cancelled'])
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<String> createPickup({
    required double lat,
    required double lng,
    required double weightKg,
    String? imageUrl,
  }) async {
    final uid = _auth.currentUser!.uid;
    final docRef = _firestore.collection('pickups').doc();
    await docRef.set({
      'citizenId': uid,
      'collectorId': null,
      'status': 'requested',
      'location': GeoPoint(lat, lng),
      'weightKg': weightKg,
      'imageUrl': imageUrl ?? '',
      'assignTrigger': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }
}
