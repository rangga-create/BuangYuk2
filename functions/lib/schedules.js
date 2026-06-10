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
exports.scheduleReminderH1 = exports.scheduleReminderH0 = exports.getSchedules = exports.deleteSchedule = exports.updateSchedule = exports.createSchedule = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const db = admin.firestore();
async function getUsersInRegion(city, district) {
    const tokens = [];
    const usersSnap = await db.collection('users')
        .where('city', '==', city).where('district', '==', district).get();
    usersSnap.forEach(doc => {
        const data = doc.data();
        if (data.fcmToken)
            tokens.push(data.fcmToken);
    });
    return tokens;
}
exports.createSchedule = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const role = context.auth.token.role;
    if (!['government_admin', 'super_admin'].includes(role)) {
        throw new functions.https.HttpsError('permission-denied', 'Insufficient permissions');
    }
    const { city, district, pickupDays, pickupTime, active = true, notificationH0 = true, notificationH1 = true } = data;
    if (!city || !district || !pickupDays || !pickupTime) {
        throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
    }
    const ref = db.collection('schedules').doc();
    await ref.set({
        city, district, pickupDays, pickupTime, active, notificationH0, notificationH1,
        createdBy: context.auth.uid,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    return { scheduleId: ref.id };
});
exports.updateSchedule = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const role = context.auth.token.role;
    if (!['government_admin', 'super_admin'].includes(role)) {
        throw new functions.https.HttpsError('permission-denied', 'Insufficient permissions');
    }
    const { scheduleId, ...updateData } = data;
    if (!scheduleId)
        throw new functions.https.HttpsError('invalid-argument', 'scheduleId required');
    updateData.updatedAt = admin.firestore.FieldValue.serverTimestamp();
    await db.collection('schedules').doc(scheduleId).update(updateData);
    return { success: true };
});
exports.deleteSchedule = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const role = context.auth.token.role;
    if (!['government_admin', 'super_admin'].includes(role)) {
        throw new functions.https.HttpsError('permission-denied', 'Insufficient permissions');
    }
    const { scheduleId } = data;
    if (!scheduleId)
        throw new functions.https.HttpsError('invalid-argument', 'scheduleId required');
    await db.collection('schedules').doc(scheduleId).delete();
    return { success: true };
});
exports.getSchedules = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const { city, district, limit = 50 } = data;
    let query = db.collection('schedules');
    if (city)
        query = query.where('city', '==', city);
    if (district)
        query = query.where('district', '==', district);
    const snap = await query.limit(limit).get();
    return { schedules: snap.docs.map(d => ({ id: d.id, ...d.data() })) };
});
exports.scheduleReminderH0 = functions.pubsub.schedule('0 7 * * *').timeZone('Asia/Jakarta').onRun(async (context) => {
    const todayDayIndex = new Date().getDay();
    const schedulesSnap = await db.collection('schedules').where('active', '==', true).where('notificationH0', '==', true).get();
    for (const doc of schedulesSnap.docs) {
        const data = doc.data();
        if (data.pickupDays && data.pickupDays.includes(todayDayIndex)) {
            const tokens = await getUsersInRegion(data.city, data.district);
            if (tokens.length > 0) {
                await admin.messaging().sendMulticast({
                    tokens,
                    notification: { title: 'Jadwal Buang Sampah Hari Ini!', body: `Petugas akan datang di wilayah ${data.district} sekitar pukul ${data.pickupTime}.` },
                    data: { type: 'onScheduleTriggered', scheduleId: doc.id }
                });
            }
        }
    }
    return null;
});
exports.scheduleReminderH1 = functions.pubsub.schedule('0 19 * * *').timeZone('Asia/Jakarta').onRun(async (context) => {
    const tomorrowDate = new Date();
    tomorrowDate.setDate(tomorrowDate.getDate() + 1);
    const tomorrowDayIndex = tomorrowDate.getDay();
    const schedulesSnap = await db.collection('schedules').where('active', '==', true).where('notificationH1', '==', true).get();
    for (const doc of schedulesSnap.docs) {
        const data = doc.data();
        if (data.pickupDays && data.pickupDays.includes(tomorrowDayIndex)) {
            const tokens = await getUsersInRegion(data.city, data.district);
            if (tokens.length > 0) {
                await admin.messaging().sendMulticast({
                    tokens,
                    notification: { title: 'Besok Jadwal Buang Sampah!', body: `Siapkan sampah Anda. Petugas akan datang esok hari di wilayah ${data.district} pukul ${data.pickupTime}.` },
                    data: { type: 'onScheduleTriggered', scheduleId: doc.id }
                });
            }
        }
    }
    return null;
});
//# sourceMappingURL=schedules.js.map