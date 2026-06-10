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
exports.getCollectorLocation = exports.syncLocationToRTDB = exports.updateCollectorLocation = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const db = admin.firestore();
exports.updateCollectorLocation = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
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
exports.syncLocationToRTDB = functions.firestore
    .document('collector_locations/{collectorId}')
    .onWrite(async (change, context) => {
    const collectorId = context.params.collectorId;
    const after = change.after.exists ? change.after.data() : null;
    if (!after) {
        await admin.database().ref(`collectorLocations/${collectorId}`).remove();
        return null;
    }
    const { location } = after;
    await admin.database().ref(`collectorLocations/${collectorId}`).set({
        lat: location.latitude, lng: location.longitude, updatedAt: Date.now()
    });
    return null;
});
exports.getCollectorLocation = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const { collectorId } = data;
    if (!collectorId)
        throw new functions.https.HttpsError('invalid-argument', 'collectorId required');
    const snap = await db.collection('collector_locations').doc(collectorId).get();
    return snap.data() || null;
});
//# sourceMappingURL=tracking.js.map