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
exports.getLeaderboard = exports.getRewardTransactions = exports.getWallet = exports.redeemReward = exports.handleRewardOnPickupComplete = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const db = admin.firestore();
const POINTS_PER_KG = 10;
const BONUS_FOR_RECYCLABLE = 5;
const REWARDABLE_TYPES = ['recyclable', 'organic', 'mixed'];
exports.handleRewardOnPickupComplete = functions.firestore
    .document('pickups/{pickupId}')
    .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    if (before.status === 'completed' || after.status !== 'completed')
        return null;
    if (after.rewardProcessed)
        return null;
    const { citizenId, weightKg = 0, wasteType = 'mixed' } = after;
    if (!citizenId)
        return null;
    let points = weightKg * POINTS_PER_KG;
    if (wasteType === 'recyclable')
        points += weightKg * BONUS_FOR_RECYCLABLE;
    const userRef = db.collection('users').doc(citizenId);
    const userWalletRef = db.collection('rewards').doc(citizenId);
    const leaderboardRef = db.collection('leaderboards').doc(citizenId);
    const pickupRef = db.collection('pickups').doc(context.params.pickupId);
    return db.runTransaction(async (transaction) => {
        const userSnap = await transaction.get(userRef);
        const user = userSnap.data() || {};
        const rewardRef = db.collection('reward_transactions').doc();
        transaction.set(rewardRef, {
            uid: citizenId, pickupId: context.params.pickupId, type: 'credit', amount: points,
            description: `Reward from pickup (${weightKg}kg ${wasteType})`,
            wasteType, weightKg,
            createdAt: admin.firestore.FieldValue.serverTimestamp()
        });
        transaction.set(userWalletRef, {
            balance: admin.firestore.FieldValue.increment(points),
            totalEarned: admin.firestore.FieldValue.increment(points),
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        }, { merge: true });
        transaction.set(leaderboardRef, {
            uid: citizenId, fullName: user.fullName || 'Anonymous',
            city: user.city || 'Unknown', district: user.district || 'Unknown',
            province: user.province || 'Unknown',
            totalPoints: admin.firestore.FieldValue.increment(points),
            totalPickups: admin.firestore.FieldValue.increment(1),
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        }, { merge: true });
        transaction.update(pickupRef, { rewardProcessed: true, rewardPoints: points });
    });
});
exports.redeemReward = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    const uid = context.auth.uid;
    const { amount, redeemType } = data;
    if (!amount || amount <= 0 || !redeemType) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid amount or type');
    }
    const userWalletRef = db.collection('rewards').doc(uid);
    return db.runTransaction(async (transaction) => {
        const walletSnap = await transaction.get(userWalletRef);
        if (!walletSnap.exists)
            throw new functions.https.HttpsError('not-found', 'Wallet not found');
        const wallet = walletSnap.data();
        if (wallet.balance < amount)
            throw new functions.https.HttpsError('failed-precondition', 'Insufficient balance');
        const rewardRef = db.collection('reward_transactions').doc();
        transaction.set(rewardRef, { uid, type: 'debit', amount, description: `Redeemed for ${redeemType}`, createdAt: admin.firestore.FieldValue.serverTimestamp() });
        transaction.update(userWalletRef, { balance: admin.firestore.FieldValue.increment(-amount), updatedAt: admin.firestore.FieldValue.serverTimestamp() });
        return { success: true, redeemedAmount: amount, remainingBalance: wallet.balance - amount };
    });
});
exports.getWallet = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const walletSnap = await db.collection('rewards').doc(uid).get();
    return walletSnap.data() || { balance: 0, totalEarned: 0 };
});
exports.getRewardTransactions = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const { limit = 20, offset = 0 } = data;
    const snap = await db.collection('reward_transactions')
        .where('uid', '==', context.auth.uid)
        .orderBy('createdAt', 'desc')
        .offset(offset).limit(limit).get();
    return { transactions: snap.docs.map(d => ({ id: d.id, ...d.data() })) };
});
exports.getLeaderboard = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const { scope = 'national', scopeValue, limit = 50 } = data;
    let query = db.collection('leaderboards').orderBy('totalPoints', 'desc').limit(limit);
    if (scope === 'city' && scopeValue)
        query = query.where('city', '==', scopeValue);
    else if (scope === 'province' && scopeValue)
        query = query.where('province', '==', scopeValue);
    const snap = await query.get();
    return { leaderboard: snap.docs.map((d, i) => ({ id: d.id, rank: i + 1, ...d.data() })) };
});
//# sourceMappingURL=rewards.js.map