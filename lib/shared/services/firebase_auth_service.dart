import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Stream<User?> get authState => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String role,
    required String fullName,
    required String phone,
    required String address,
    required String district,
    required String city,
    required String province,
    String? photoUrl,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final uid = userCredential.user!.uid;

    final batch = _firestore.batch();
    batch.set(_firestore.collection('users').doc(uid), {
      'uid': uid, 'email': email, 'role': role, 'fullName': fullName,
      'phone': phone, 'address': address, 'district': district, 'city': city, 'province': province,
      'photoUrl': photoUrl ?? '', 'fcmToken': null,
      'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_firestore.collection('rewards').doc(uid), {
      'uid': uid, 'balance': 0, 'totalEarned': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_firestore.collection('leaderboards').doc(uid), {
      'uid': uid, 'fullName': fullName, 'city': city, 'district': district, 'province': province,
      'totalPoints': 0, 'totalPickups': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_firestore.collection('notifications').doc(), {
      'uid': uid, 'type': 'welcome', 'title': 'Selamat Datang di BuangYuk!',
      'body': 'Halo $fullName, mulailah perjalananmu menjaga lingkungan.',
      'is_read': false, 'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return {'uid': uid, 'email': email, 'role': role};
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final uid = userCredential.user!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data() ?? {};
  }

  Future<void> logout() => _auth.signOut();

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  Future<String> getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    return (await user.getIdToken())!;
  }
}
