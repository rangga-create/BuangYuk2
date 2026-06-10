import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as path from 'path';
import * as os from 'os';
import * as fs from 'fs';
import * as crypto from 'crypto';

const db = admin.firestore();

export const uploadWasteScan = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  const uid = context.auth.uid;
  const { base64Image, wasteType } = data;
  if (!base64Image) throw new functions.https.HttpsError('invalid-argument', 'Missing image data');

  const buffer = Buffer.from(base64Image, 'base64');
  const tmpDir = os.tmpdir();
  const fileName = `${crypto.randomBytes(16).toString('hex')}.jpg`;
  const filePath = path.join(tmpDir, fileName);
  fs.writeFileSync(filePath, buffer);

  const bucket = admin.storage().bucket();
  const destination = `waste_scans/${uid}/${fileName}`;
  await bucket.upload(filePath, { destination, metadata: { contentType: 'image/jpeg' } });
  fs.unlinkSync(filePath);

  const file = bucket.file(destination);
  const [url] = await file.getSignedUrl({ action: 'read', expires: '03-01-2500' });

  const scanRef = db.collection('waste_scans').doc();
  await scanRef.set({
    uid, wasteType: wasteType || 'unknown', imageUrl: url,
    processed: false, createdAt: admin.firestore.FieldValue.serverTimestamp()
  });
  return { scanId: scanRef.id, imageUrl: url };
});

export const getWasteScans = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
  const { limit = 20, offset = 0 } = data;
  const snap = await db.collection('waste_scans')
    .where('uid', '==', context.auth.uid)
    .orderBy('createdAt', 'desc')
    .offset(offset).limit(limit).get();
  return { scans: snap.docs.map(d => ({ id: d.id, ...d.data() })) };
});
