import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const registerUser = functions.https.onCall(async (data, context) => {
  const { email, password, role, fullName, phone, address, district, city, province, photoUrl, fcmToken } = data;
  if (!email || !password || !role || !fullName || !phone || !address || !district || !city || !province) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
  }
  const validRoles = ['citizen', 'collector', 'tps_manager', 'government_admin', 'super_admin'];
  if (!validRoles.includes(role)) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid role');
  }
  try {
    const userRecord = await admin.auth().createUser({ email, password, displayName: fullName, phoneNumber: phone, photoURL: photoUrl || undefined });
    await admin.auth().setCustomUserClaims(userRecord.uid, { role });
    const userData: any = {
      uid: userRecord.uid, email, role, fullName, phone, address, district, city, province,
      photoUrl: photoUrl || null, fcmToken: fcmToken || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };
    await db.collection('users').doc(userRecord.uid).set(userData);
    await db.collection('rewards').doc(userRecord.uid).set({
      uid: userRecord.uid, balance: 0, totalEarned: 0,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    await db.collection('leaderboards').doc(userRecord.uid).set({
      uid: userRecord.uid, fullName, city, district, province, totalPoints: 0, totalPickups: 0,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    const notifRef = db.collection('notifications').doc();
    await notifRef.set({
      uid: userRecord.uid, type: 'welcome',
      title: 'Selamat Datang di BuangYuk!',
      body: `Halo ${fullName}, mulailah perjalananmu menjaga lingkungan.`,
      is_read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    return { uid: userRecord.uid, email, role };
  } catch (error) {
    throw new functions.https.HttpsError('internal', (error as Error).message);
  }
});

export const getUserRole = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'User not authenticated');
  const uid = context.auth.uid;
  const role = context.auth.token.role || 'citizen';
  const userDoc = await db.collection('users').doc(uid).get();
  return { uid, role, profile: userDoc.data() || {} };
});

export const updateFcmToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'User not authenticated');
  const { fcmToken } = data;
  if (!fcmToken) throw new functions.https.HttpsError('invalid-argument', 'fcmToken required');
  await db.collection('users').doc(context.auth.uid).update({ fcmToken });
  return { success: true };
});

export const getAllUsers = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const role = context.auth.token.role;
  if (!['government_admin', 'super_admin'].includes(role)) {
    throw new functions.https.HttpsError('permission-denied', 'Insufficient permissions');
  }
  const snap = await db.collection('users').get();
  return { users: snap.docs.map(d => ({ id: d.id, ...d.data() })) };
});
