import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getNotifications(String uid) {
    return _firestore
        .collection('notifications')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<int> getUnreadCount(String uid) async {
    final snap = await _firestore
        .collection('notifications')
        .where('uid', isEqualTo: uid)
        .where('is_read', isEqualTo: false)
        .count()
        .get();
    return snap.count ?? 0;
  }

  Stream<int> unreadCountStream(String uid) {
    return _firestore
        .collection('notifications')
        .where('uid', isEqualTo: uid)
        .where('is_read', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'is_read': true,
    });
  }

  Future<void> markAllAsRead(String uid) async {
    final batch = _firestore.batch();
    final snap = await _firestore
        .collection('notifications')
        .where('uid', isEqualTo: uid)
        .where('is_read', isEqualTo: false)
        .get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'is_read': true});
    }
    await batch.commit();
  }

  Future<void> dismissNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }
}
