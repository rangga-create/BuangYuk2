import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as os from 'os';
import * as path from 'path';
import * as fs from 'fs';
import * as crypto from 'crypto';

const db = admin.firestore();

export const generateReport = functions.runWith({ timeoutSeconds: 300, memory: '1GB' }).https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const role = context.auth.token.role;
  if (!['government_admin', 'super_admin'].includes(role)) {
    throw new functions.https.HttpsError('permission-denied', 'Insufficient permissions');
  }
  const { reportType = 'monthly', format = 'csv' } = data;
  const now = new Date();
  let startDate = new Date();
  if (reportType === 'daily') startDate.setDate(now.getDate() - 1);
  else if (reportType === 'weekly') startDate.setDate(now.getDate() - 7);
  else startDate.setMonth(now.getMonth() - 1);

  const pickupsSnap = await db.collection('pickups')
    .where('status', '==', 'completed')
    .where('createdAt', '>=', startDate).get();

  const results: any[] = [];
  pickupsSnap.forEach(doc => {
    const p = doc.data();
    results.push({
      id: doc.id, citizenId: p.citizenId, collectorId: p.collectorId,
      weightKg: p.weightKg || 0, wasteType: p.wasteType || 'mixed',
      city: p.city || '', district: p.district || '', province: p.province || '',
      createdAt: p.createdAt ? (p.createdAt as admin.firestore.Timestamp).toDate().toISOString() : '',
      status: p.status
    });
  });

  let fileContent = '';
  if (format === 'json') {
    fileContent = JSON.stringify(results, null, 2);
  } else {
    if (results.length > 0) {
      const headers = Object.keys(results[0]).join(',');
      const rows = results.map(row => Object.values(row).map(v => `"${v}"`).join(',')).join('\n');
      fileContent = `${headers}\n${rows}`;
    } else {
      fileContent = 'id,citizenId,collectorId,weightKg,wasteType,city,district,province,createdAt,status\n';
    }
  }

  const tmpDir = os.tmpdir();
  const fileName = `report_${reportType}_${crypto.randomBytes(4).toString('hex')}.${format}`;
  const filePath = path.join(tmpDir, fileName);
  fs.writeFileSync(filePath, fileContent);

  const bucket = admin.storage().bucket();
  const destination = `reports/${fileName}`;
  await bucket.upload(filePath, { destination, metadata: { contentType: format === 'json' ? 'application/json' : 'text/csv' } });
  fs.unlinkSync(filePath);

  const file = bucket.file(destination);
  const [url] = await file.getSignedUrl({ action: 'read', expires: Date.now() + 1000 * 60 * 60 * 24 * 7 });

  await db.collection('reports').add({
    reportType, format, url, generatedBy: context.auth.uid,
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });
  return { url, fileName };
});

export const getReports = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const role = context.auth.token.role;
  if (!['government_admin', 'super_admin'].includes(role)) {
    throw new functions.https.HttpsError('permission-denied', 'Insufficient permissions');
  }
  const snap = await db.collection('reports').orderBy('createdAt', 'desc').limit(20).get();
  return { reports: snap.docs.map(d => ({ id: d.id, ...d.data() })) };
});
