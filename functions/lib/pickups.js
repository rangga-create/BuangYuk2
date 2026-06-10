"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.getCollectorPickups = exports.getCitizenPickups = exports.updatePickupStatus = exports.rejectPickup = exports.acceptPickup = exports.autoAssignNearestCollector = exports.createPickup = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const geofire_common_1 = require("geofire-common");
const db = admin.firestore();
const ALLOWED_TRANSITIONS = {
    'requested': ['assigned', 'cancelled'],
    'assigned': ['accepted', 'rejected', 'cancelled'],
    'accepted': ['on_the_way', 'cancelled'],
    'on_the_way': ['arrived', 'cancelled'],
    'arrived': ['picked_up', 'cancelled'],
    'picked_up': ['completed'],
};
exports.createPickup = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Please login');
    const { location, weightKg, imageUrl, wasteType } = data;
    if (!location?.lat || !location?.lng || !weightKg) {
        throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
    }
    const citizenId = context.auth.uid;
    const userSnap = await db.collection('users').doc(citizenId).get();
    const user = userSnap.data() || {};
    const geoHash = (0, geofire_common_1.geohashForLocation)([location.lat, location.lng]);
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
exports.autoAssignNearestCollector = functions.firestore
    .document('pickups/{pickupId}')
    .onUpdate(async (change, context) => {
    const after = change.after.data();
    if (!after.assignTrigger)
        return null;
    if (after.collectorId && after.status !== 'rejected')
        return null;
    if (after.status === 'cancelled')
        return null;
    const collectorsSnap = await db.collection('users')
        .where('role', '==', 'collector')
        .where('isAvailable', '==', true)
        .get();
    let nearestId = null;
    let nearestDist = Infinity;
    const pickupGeo = after.location;
    collectorsSnap.forEach(doc => {
        const loc = doc.data().location;
        if (!loc)
            return;
        const dist = (0, geofire_common_1.distanceBetween)([pickupGeo.latitude, pickupGeo.longitude], [loc.latitude, loc.longitude]);
        if (dist < nearestDist) {
            nearestDist = dist;
            nearestId = doc.id;
        }
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
exports.acceptPickup = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    const collectorId = context.auth.uid;
    const { pickupId } = data;
    if (!pickupId)
        throw new functions.https.HttpsError('invalid-argument', 'pickupId required');
    return db.runTransaction(async (transaction) => {
        const pickupRef = db.doc(`pickups/${pickupId}`);
        const snap = await transaction.get(pickupRef);
        const pickup = snap.data();
        if (!pickup)
            throw new functions.https.HttpsError('not-found', 'Pickup not found');
        if (pickup.collectorId !== collectorId)
            throw new functions.https.HttpsError('permission-denied', 'Not assigned to you');
        if (pickup.status !== 'assigned')
            throw new functions.https.HttpsError('failed-precondition', 'Pickup not in assignable state');
        transaction.update(pickupRef, { status: 'accepted', updatedAt: admin.firestore.FieldValue.serverTimestamp() });
        const logRef = db.collection('pickup_status_logs').doc();
        transaction.set(logRef, { pickupId, status: 'accepted', changedBy: collectorId, timestamp: admin.firestore.FieldValue.serverTimestamp() });
        return { success: true };
    });
});
exports.rejectPickup = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    const collectorId = context.auth.uid;
    const { pickupId } = data;
    return db.runTransaction(async (transaction) => {
        const pickupRef = db.doc(`pickups/${pickupId}`);
        const snap = await transaction.get(pickupRef);
        const pickup = snap.data();
        if (!pickup)
            throw new functions.https.HttpsError('not-found', 'Pickup not found');
        if (pickup.collectorId !== collectorId)
            throw new functions.https.HttpsError('permission-denied', 'Not assigned to you');
        if (pickup.status !== 'assigned')
            throw new functions.https.HttpsError('failed-precondition', 'Pickup not in assignable state');
        transaction.update(pickupRef, { status: 'requested', collectorId: null, assignTrigger: true, updatedAt: admin.firestore.FieldValue.serverTimestamp() });
        const logRef = db.collection('pickup_status_logs').doc();
        transaction.set(logRef, { pickupId, status: 'rejected', changedBy: collectorId, timestamp: admin.firestore.FieldValue.serverTimestamp() });
        return { success: true };
    });
});
exports.updatePickupStatus = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    const uid = context.auth.uid;
    const { pickupId, newStatus } = data;
    return db.runTransaction(async (transaction) => {
        const pickupRef = db.doc(`pickups/${pickupId}`);
        const snap = await transaction.get(pickupRef);
        const pickup = snap.data();
        if (!pickup)
            throw new functions.https.HttpsError('not-found', 'Pickup not found');
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
exports.getCitizenPickups = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const { status, limit = 20, offset = 0 } = data;
    let query = db.collection('pickups').where('citizenId', '==', context.auth.uid).orderBy('createdAt', 'desc');
    if (status)
        query = query.where('status', '==', status);
    const snap = await query.offset(offset).limit(limit).get();
    return { pickups: snap.docs.map(d => ({ id: d.id, ...d.data() })), total: snap.size };
});
exports.getCollectorPickups = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const { status, limit = 20, offset = 0 } = data;
    let query = db.collection('pickups').where('collectorId', '==', context.auth.uid).orderBy('createdAt', 'desc');
    if (status)
        query = query.where('status', '==', status);
    const snap = await query.offset(offset).limit(limit).get();
    return { pickups: snap.docs.map(d => ({ id: d.id, ...d.data() })), total: snap.size };
});
//# sourceMappingURL=pickups.js.map