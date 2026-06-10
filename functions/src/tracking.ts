import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const updateCollectorLocation = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  const uid = context.auth.uid;
  const { lat, lng } = data;
  if (typeof lat !== 'number' || typeof lng !== 'number') {
    throw new functions.https.HttpsError('invalid-argument', 'Latitude and longitude must be numbers');
  }
  await db.collection('collector_locations').doc(uid).set({
    uid, location: new admin.firestore.GeoPoint(lat, lng),
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  });
  await admin.database().ref(`collectorLocations/${uid}`).update({ lat, lng, updatedAt: Date.now() });
  return { success: true };
});

export const syncLocationToRTDB = functions.firestore
  .document('collector_locations/{collectorId}')
  .onWrite(async (change, context) => {
    const collectorId = context.params.collectorId;
    const after = change.after.exists ? change.after.data() : null;
    if (!after) {
      await admin.database().ref(`collectorLocations/${collectorId}`).remove();
      return null;
    }
    const { location } = after as any;
    await admin.database().ref(`collectorLocations/${collectorId}`).set({
      lat: location.latitude, lng: location.longitude, updatedAt: Date.now()
    });
    return null;
  });

export const getCollectorLocation = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const { collectorId } = data;
  if (!collectorId) throw new functions.https.HttpsError('invalid-argument', 'collectorId required');
  const snap = await db.collection('collector_locations').doc(collectorId).get();
  return snap.data() || null;
});
