import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const POINTS_PER_KG = 10;
const BONUS_FOR_RECYCLABLE = 5;

const REWARDABLE_TYPES = ['recyclable', 'organic', 'mixed'];

export const handleRewardOnPickupComplete = functions.firestore
  .document('pickups/{pickupId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    if (before.status === 'completed' || after.status !== 'completed') return null;
    if (after.rewardProcessed) return null;

    const { citizenId, weightKg = 0, wasteType = 'mixed' } = after as any;
    if (!citizenId) return null;

    let points = weightKg * POINTS_PER_KG;
    if (wasteType === 'recyclable') points += weightKg * BONUS_FOR_RECYCLABLE;

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

export const redeemReward = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  const uid = context.auth.uid;
  const { amount, redeemType } = data;
  if (!amount || amount <= 0 || !redeemType) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid amount or type');
  }
  const userWalletRef = db.collection('rewards').doc(uid);
  return db.runTransaction(async (transaction) => {
    const walletSnap = await transaction.get(userWalletRef);
    if (!walletSnap.exists) throw new functions.https.HttpsError('not-found', 'Wallet not found');
    const wallet = walletSnap.data()!;
    if (wallet.balance < amount) throw new functions.https.HttpsError('failed-precondition', 'Insufficient balance');
    const rewardRef = db.collection('reward_transactions').doc();
    transaction.set(rewardRef, { uid, type: 'debit', amount, description: `Redeemed for ${redeemType}`, createdAt: admin.firestore.FieldValue.serverTimestamp() });
    transaction.update(userWalletRef, { balance: admin.firestore.FieldValue.increment(-amount), updatedAt: admin.firestore.FieldValue.serverTimestamp() });
    return { success: true, redeemedAmount: amount, remainingBalance: wallet.balance - amount };
  });
});

export const getWallet = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const uid = context.auth.uid;
  const walletSnap = await db.collection('rewards').doc(uid).get();
  return walletSnap.data() || { balance: 0, totalEarned: 0 };
});

export const getRewardTransactions = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const { limit = 20, offset = 0 } = data;
  const snap = await db.collection('reward_transactions')
    .where('uid', '==', context.auth.uid)
    .orderBy('createdAt', 'desc')
    .offset(offset).limit(limit).get();
  return { transactions: snap.docs.map(d => ({ id: d.id, ...d.data() })) };
});

export const getLeaderboard = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const { scope = 'national', scopeValue, limit = 50 } = data;
  let query: admin.firestore.Query = db.collection('leaderboards').orderBy('totalPoints', 'desc').limit(limit);
  if (scope === 'city' && scopeValue) query = query.where('city', '==', scopeValue);
  else if (scope === 'province' && scopeValue) query = query.where('province', '==', scopeValue);
  const snap = await query.get();
  return { leaderboard: snap.docs.map((d, i) => ({ id: d.id, rank: i + 1, ...d.data() })) };
});
