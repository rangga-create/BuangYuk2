import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

async function getUserFcmToken(uid: string): Promise<string | null> {
  const userDoc = await db.collection('users').doc(uid).get();
  return userDoc.data()?.fcmToken || null;
}

async function sendNotification(uid: string, title: string, body: string, dataPayload: Record<string, string>) {
  await db.collection('notifications').add({
    uid, title, body, is_read: false, data: dataPayload,
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });
  const token = await getUserFcmToken(uid);
  if (token) {
    try {
      await admin.messaging().send({ token, notification: { title, body }, data: dataPayload });
    } catch (e) {
      console.error(`FCM send failed for ${uid}:`, e);
    }
  }
}

async function sendNotificationToUser(uid: string, title: string, body: string, dataPayload: Record<string, string>) {
  return sendNotification(uid, title, body, dataPayload);
}

export const onPickupStatusChange = functions.firestore
  .document('pickups/{pickupId}')
  .onWrite(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const pickupId = context.params.pickupId;
    if (!after) return null;

    const statusBefore = before?.status;
    const statusAfter = after.status;

    if (!before) {
      await sendNotificationToUser(
        after.citizenId,
        'Pickup Requested',
        'Looking for the nearest collector...',
        { type: 'onPickupCreated', pickupId }
      );
      return null;
    }

    if (statusBefore !== 'assigned' && statusAfter === 'assigned' && after.collectorId) {
      await sendNotificationToUser(
        after.citizenId,
        'Collector Assigned',
        'A collector has been assigned to your pickup.',
        { type: 'onCollectorAssigned', pickupId }
      );
      if (after.collectorId) {
        await sendNotificationToUser(
          after.collectorId,
          'New Pickup Job',
          'You have a new pickup assignment. Please check and accept.',
          { type: 'onPickupCreated', pickupId }
        );
      }
      return null;
    }

    if (statusBefore !== statusAfter && statusAfter === 'accepted') {
      await sendNotificationToUser(
        after.citizenId,
        'Pickup Accepted',
        'The collector has accepted your pickup request.',
        { type: 'onPickupAccepted', pickupId }
      );
    }

    if (statusBefore !== statusAfter && statusAfter === 'on_the_way') {
      await sendNotificationToUser(
        after.citizenId,
        'Collector On The Way',
        'The collector is heading to your location.',
        { type: 'onPickupOnTheWay', pickupId }
      );
    }

    if (statusBefore !== statusAfter && statusAfter === 'arrived') {
      await sendNotificationToUser(
        after.citizenId,
        'Collector Arrived',
        'The collector has arrived at your location.',
        { type: 'onPickupArrived', pickupId }
      );
    }

    if (statusBefore !== statusAfter && statusAfter === 'completed') {
      await sendNotificationToUser(
        after.citizenId,
        'Pickup Completed',
        'Thank you! Your reward will be calculated shortly.',
        { type: 'onPickupCompleted', pickupId }
      );
      if (after.collectorId) {
        await sendNotificationToUser(
          after.collectorId,
        'Pickup Completed',
          'Pickup task completed successfully.',
          { type: 'onPickupCompleted', pickupId }
        );
      }
    }

    return null;
  });

export const onRewardTransaction = functions.firestore
  .document('reward_transactions/{txnId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data) return null;
    const { uid, type, amount, pickupId } = data;
    if (type === 'credit') {
      await sendNotificationToUser(
        uid,
        'Reward Earned!',
        `You earned ${amount} points from pickup.`,
        { type: 'onRewardCalculated', amount: String(amount), pickupId: pickupId || '' }
      );
    } else if (type === 'debit') {
      await sendNotificationToUser(
        uid,
        'Points Redeemed',
        `You redeemed ${amount} points.`,
        { type: 'reward_redeemed', amount: String(amount) }
      );
    }
    return null;
  });
