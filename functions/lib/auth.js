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
exports.getAllUsers = exports.updateFcmToken = exports.getUserRole = exports.registerUser = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const db = admin.firestore();
exports.registerUser = functions.https.onCall(async (data, context) => {
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
        const userData = {
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
    }
    catch (error) {
        throw new functions.https.HttpsError('internal', error.message);
    }
});
exports.getUserRole = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'User not authenticated');
    const uid = context.auth.uid;
    const role = context.auth.token.role || 'citizen';
    const userDoc = await db.collection('users').doc(uid).get();
    return { uid, role, profile: userDoc.data() || {} };
});
exports.updateFcmToken = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'User not authenticated');
    const { fcmToken } = data;
    if (!fcmToken)
        throw new functions.https.HttpsError('invalid-argument', 'fcmToken required');
    await db.collection('users').doc(context.auth.uid).update({ fcmToken });
    return { success: true };
});
exports.getAllUsers = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const role = context.auth.token.role;
    if (!['government_admin', 'super_admin'].includes(role)) {
        throw new functions.https.HttpsError('permission-denied', 'Insufficient permissions');
    }
    const snap = await db.collection('users').get();
    return { users: snap.docs.map(d => ({ id: d.id, ...d.data() })) };
});
//# sourceMappingURL=auth.js.map