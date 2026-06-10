import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const getDashboardStats = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const role = context.auth.token.role;
  if (!['tps_manager', 'government_admin', 'super_admin'].includes(role)) {
    throw new functions.https.HttpsError('permission-denied', 'Insufficient permissions');
  }
  const { filterType = 'national', filterValue } = data;

  let pickupsQuery: admin.firestore.Query = db.collection('pickups');
  let usersQuery: admin.firestore.Query = db.collection('users');
  let rewardsQuery: admin.firestore.Query = db.collection('reward_transactions');

  if (filterType === 'city' && filterValue) {
    pickupsQuery = pickupsQuery.where('city', '==', filterValue);
    usersQuery = usersQuery.where('city', '==', filterValue);
    rewardsQuery = rewardsQuery.where('city', '==', filterValue);
  } else if (filterType === 'province' && filterValue) {
    pickupsQuery = pickupsQuery.where('province', '==', filterValue);
    usersQuery = usersQuery.where('province', '==', filterValue);
    rewardsQuery = rewardsQuery.where('province', '==', filterValue);
  }

  const totalUsersSnap = await usersQuery.count().get();
  const collectorsSnap = await usersQuery.where('role', '==', 'collector').count().get();

  const pickupsSnap = await pickupsQuery.get();
  const completedPickups = pickupsSnap.docs.filter(d => d.data().status === 'completed');
  const totalPickupsCompleted = completedPickups.length;
  let totalWasteVolumeKg = 0;
  completedPickups.forEach(d => { totalWasteVolumeKg += (d.data().weightKg || 0); });

  const activePickups = pickupsSnap.docs.filter(d =>
    ['requested', 'assigned', 'accepted', 'on_the_way', 'arrived', 'picked_up'].includes(d.data().status)
  ).length;

  const stats = {
    scope: filterType, region: filterValue || 'All',
    totalUsers: totalUsersSnap.data().count,
    totalCollectors: collectorsSnap.data().count,
    totalPickupsCompleted,
    activePickups,
    totalWasteVolumeKg,
    timestamp: admin.firestore.FieldValue.serverTimestamp()
  };

  const cacheDoc = filterType === 'national' ? 'national' : `${filterType}_${filterValue}`;
  await db.collection('admin_stats').doc(cacheDoc).set(stats);
  return stats;
});

export const dailyStatsJob = functions.pubsub.schedule('55 23 * * *').timeZone('Asia/Jakarta').onRun(async (context) => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const pickupsToday = await db.collection('pickups')
    .where('status', '==', 'completed')
    .where('updatedAt', '>=', today).get();

  let wasteVolumeKg = 0;
  pickupsToday.forEach(d => { wasteVolumeKg += (d.data().weightKg || 0); });

  const dayString = new Date().toISOString().slice(0, 10);
  await db.collection('admin_daily_stats').doc(dayString).set({
    date: dayString, pickupsCompleted: pickupsToday.size, wasteVolumeKg,
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });
  return null;
});
