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
exports.onRewardTransaction = exports.onPickupStatusChange = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const db = admin.firestore();
async function getUserFcmToken(uid) {
    const userDoc = await db.collection('users').doc(uid).get();
    return userDoc.data()?.fcmToken || null;
}
async function sendNotification(uid, title, body, dataPayload) {
    await db.collection('notifications').add({
        uid, title, body, is_read: false, data: dataPayload,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    const token = await getUserFcmToken(uid);
    if (token) {
        try {
            await admin.messaging().send({ token, notification: { title, body }, data: dataPayload });
        }
        catch (e) {
            console.error(`FCM send failed for ${uid}:`, e);
        }
    }
}
async function sendNotificationToUser(uid, title, body, dataPayload) {
    return sendNotification(uid, title, body, dataPayload);
}
exports.onPickupStatusChange = functions.firestore
    .document('pickups/{pickupId}')
    .onWrite(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const pickupId = context.params.pickupId;
    if (!after)
        return null;
    const statusBefore = before?.status;
    const statusAfter = after.status;
    if (!before) {
        await sendNotificationToUser(after.citizenId, 'Pickup Requested', 'Looking for the nearest collector...', { type: 'onPickupCreated', pickupId });
        return null;
    }
    if (statusBefore !== 'assigned' && statusAfter === 'assigned' && after.collectorId) {
        await sendNotificationToUser(after.citizenId, 'Collector Assigned', 'A collector has been assigned to your pickup.', { type: 'onCollectorAssigned', pickupId });
        if (after.collectorId) {
            await sendNotificationToUser(after.collectorId, 'New Pickup Job', 'You have a new pickup assignment. Please check and accept.', { type: 'onPickupCreated', pickupId });
        }
        return null;
    }
    if (statusBefore !== statusAfter && statusAfter === 'accepted') {
        await sendNotificationToUser(after.citizenId, 'Pickup Accepted', 'The collector has accepted your pickup request.', { type: 'onPickupAccepted', pickupId });
    }
    if (statusBefore !== statusAfter && statusAfter === 'on_the_way') {
        await sendNotificationToUser(after.citizenId, 'Collector On The Way', 'The collector is heading to your location.', { type: 'onPickupOnTheWay', pickupId });
    }
    if (statusBefore !== statusAfter && statusAfter === 'arrived') {
        await sendNotificationToUser(after.citizenId, 'Collector Arrived', 'The collector has arrived at your location.', { type: 'onPickupArrived', pickupId });
    }
    if (statusBefore !== statusAfter && statusAfter === 'completed') {
        await sendNotificationToUser(after.citizenId, 'Pickup Completed', 'Thank you! Your reward will be calculated shortly.', { type: 'onPickupCompleted', pickupId });
        if (after.collectorId) {
            await sendNotificationToUser(after.collectorId, 'Pickup Completed', 'Pickup task completed successfully.', { type: 'onPickupCompleted', pickupId });
        }
    }
    return null;
});
exports.onRewardTransaction = functions.firestore
    .document('reward_transactions/{txnId}')
    .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data)
        return null;
    const { uid, type, amount, pickupId } = data;
    if (type === 'credit') {
        await sendNotificationToUser(uid, 'Reward Earned!', `You earned ${amount} points from pickup.`, { type: 'onRewardCalculated', amount: String(amount), pickupId: pickupId || '' });
    }
    else if (type === 'debit') {
        await sendNotificationToUser(uid, 'Points Redeemed', `You redeemed ${amount} points.`, { type: 'reward_redeemed', amount: String(amount) });
    }
    return null;
});
//# sourceMappingURL=notifications.js.map