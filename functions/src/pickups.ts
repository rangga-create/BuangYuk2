import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { geohashForLocation, distanceBetween } from 'geofire-common';

const db = admin.firestore();

const ALLOWED_TRANSITIONS: Record<string, string[]> = {
  'requested': ['assigned', 'cancelled'],
  'assigned': ['accepted', 'rejected', 'cancelled'],
  'accepted': ['on_the_way', 'cancelled'],
  'on_the_way': ['arrived', 'cancelled'],
  'arrived': ['picked_up', 'cancelled'],
  'picked_up': ['completed'],
};

export const createPickup = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Please login');
  const { location, weightKg, imageUrl, wasteType } = data;
  if (!location?.lat || !location?.lng || !weightKg) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
  }
  const citizenId = context.auth.uid;
  const userSnap = await db.collection('users').doc(citizenId).get();
  const user = userSnap.data() || {};
  const geoHash = geohashForLocation([location.lat, location.lng]);
  const pickupData = {
    citizenId, collectorId: null, status: 'requested',
    location: new admin.firestore.GeoPoint(location.lat, location.lng),
    geoHash, weightKg, wasteType: wasteType || 'mixed',
    imageUrl: imageUrl || null,
    city: user.city || null,
    district: user.district || null,
    province: user.province || null,
    citizenName: user.fullName || null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  };
  const pickupRef = db.collection('pickups').doc();
  await pickupRef.set(pickupData);
  await db.collection('pickup_status_logs').add({
    pickupId: pickupRef.id, status: 'requested', changedBy: citizenId,
    timestamp: admin.firestore.FieldValue.serverTimestamp()
  });
  await pickupRef.update({ assignTrigger: true });
  return { pickupId: pickupRef.id };
});

export const autoAssignNearestCollector = functions.firestore
  .document('pickups/{pickupId}')
  .onUpdate(async (change, context) => {
    const after = change.after.data();
    if (!after.assignTrigger) return null;
    if (after.collectorId && after.status !== 'rejected') return null;
    if (after.status === 'cancelled') return null;

    const collectorsSnap = await db.collection('users')
      .where('role', '==', 'collector')
      .where('isAvailable', '==', true)
      .get();

    let nearestId: string | null = null;
    let nearestDist = Infinity;
    const pickupGeo = after.location as admin.firestore.GeoPoint;
    collectorsSnap.forEach(doc => {
      const loc = doc.data().location as admin.firestore.GeoPoint | undefined;
      if (!loc) return;
      const dist = distanceBetween([pickupGeo.latitude, pickupGeo.longitude], [loc.latitude, loc.longitude]);
      if (dist < nearestDist) { nearestDist = dist; nearestId = doc.id; }
    });
    if (!nearestId) {
      await change.after.ref.update({ assignTrigger: admin.firestore.FieldValue.delete() });
      return null;
    }
    await change.after.ref.update({
      collectorId: nearestId, status: 'assigned',
      assignTrigger: admin.firestore.FieldValue.delete(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    await db.collection('pickup_status_logs').add({
      pickupId: context.params.pickupId, status: 'assigned', changedBy: 'system',
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    });
    return null;
  });

export const acceptPickup = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  const collectorId = context.auth.uid;
  const { pickupId } = data;
  if (!pickupId) throw new functions.https.HttpsError('invalid-argument', 'pickupId required');
  return db.runTransaction(async (transaction) => {
    const pickupRef = db.doc(`pickups/${pickupId}`);
    const snap = await transaction.get(pickupRef);
    const pickup = snap.data();
    if (!pickup) throw new functions.https.HttpsError('not-found', 'Pickup not found');
    if (pickup.collectorId !== collectorId) throw new functions.https.HttpsError('permission-denied', 'Not assigned to you');
    if (pickup.status !== 'assigned') throw new functions.https.HttpsError('failed-precondition', 'Pickup not in assignable state');
    transaction.update(pickupRef, { status: 'accepted', updatedAt: admin.firestore.FieldValue.serverTimestamp() });
    const logRef = db.collection('pickup_status_logs').doc();
    transaction.set(logRef, { pickupId, status: 'accepted', changedBy: collectorId, timestamp: admin.firestore.FieldValue.serverTimestamp() });
    return { success: true };
  });
});

export const rejectPickup = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  const collectorId = context.auth.uid;
  const { pickupId } = data;
  return db.runTransaction(async (transaction) => {
    const pickupRef = db.doc(`pickups/${pickupId}`);
    const snap = await transaction.get(pickupRef);
    const pickup = snap.data();
    if (!pickup) throw new functions.https.HttpsError('not-found', 'Pickup not found');
    if (pickup.collectorId !== collectorId) throw new functions.https.HttpsError('permission-denied', 'Not assigned to you');
    if (pickup.status !== 'assigned') throw new functions.https.HttpsError('failed-precondition', 'Pickup not in assignable state');
    transaction.update(pickupRef, { status: 'requested', collectorId: null, assignTrigger: true, updatedAt: admin.firestore.FieldValue.serverTimestamp() });
    const logRef = db.collection('pickup_status_logs').doc();
    transaction.set(logRef, { pickupId, status: 'rejected', changedBy: collectorId, timestamp: admin.firestore.FieldValue.serverTimestamp() });
    return { success: true };
  });
});

export const updatePickupStatus = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  const uid = context.auth.uid;
  const { pickupId, newStatus } = data;
  return db.runTransaction(async (transaction) => {
    const pickupRef = db.doc(`pickups/${pickupId}`);
    const snap = await transaction.get(pickupRef);
    const pickup = snap.data();
    if (!pickup) throw new functions.https.HttpsError('not-found', 'Pickup not found');
    const currentStatus = pickup.status;
    const validNextStates = ALLOWED_TRANSITIONS[currentStatus] || [];
    if (!validNextStates.includes(newStatus)) {
      throw new functions.https.HttpsError('failed-precondition', `Invalid transition from ${currentStatus} to ${newStatus}`);
    }
    const isCollector = pickup.collectorId === uid;
    const isCitizen = pickup.citizenId === uid;
    const isAdmin = ['super_admin', 'government_admin'].includes(context.auth?.token.role);
    if (newStatus === 'cancelled' && !isCitizen && !isCollector && !isAdmin) {
      throw new functions.https.HttpsError('permission-denied', 'Not allowed to cancel');
    }
    if (newStatus !== 'cancelled' && !isCollector && !isAdmin) {
      throw new functions.https.HttpsError('permission-denied', 'Only collector can update status');
    }
    transaction.update(pickupRef, { status: newStatus, updatedAt: admin.firestore.FieldValue.serverTimestamp() });
    const logRef = db.collection('pickup_status_logs').doc();
    transaction.set(logRef, { pickupId, status: newStatus, changedBy: uid, timestamp: admin.firestore.FieldValue.serverTimestamp() });
    return { success: true };
  });
});

export const getCitizenPickups = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const { status, limit = 20, offset = 0 } = data;
  let query: admin.firestore.Query = db.collection('pickups').where('citizenId', '==', context.auth.uid).orderBy('createdAt', 'desc');
  if (status) query = query.where('status', '==', status);
  const snap = await query.offset(offset).limit(limit).get();
  return { pickups: snap.docs.map(d => ({ id: d.id, ...d.data() })), total: snap.size };
});

export const getCollectorPickups = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const { status, limit = 20, offset = 0 } = data;
  let query: admin.firestore.Query = db.collection('pickups').where('collectorId', '==', context.auth.uid).orderBy('createdAt', 'desc');
  if (status) query = query.where('status', '==', status);
  const snap = await query.offset(offset).limit(limit).get();
  return { pickups: snap.docs.map(d => ({ id: d.id, ...d.data() })), total: snap.size };
});
