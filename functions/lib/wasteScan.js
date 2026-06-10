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
exports.getWasteScans = exports.uploadWasteScan = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const path = __importStar(require("path"));
const os = __importStar(require("os"));
const fs = __importStar(require("fs"));
const crypto = __importStar(require("crypto"));
const db = admin.firestore();
exports.uploadWasteScan = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    const uid = context.auth.uid;
    const { base64Image, wasteType } = data;
    if (!base64Image)
        throw new functions.https.HttpsError('invalid-argument', 'Missing image data');
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
exports.getWasteScans = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const { limit = 20, offset = 0 } = data;
    const snap = await db.collection('waste_scans')
        .where('uid', '==', context.auth.uid)
        .orderBy('createdAt', 'desc')
        .offset(offset).limit(limit).get();
    return { scans: snap.docs.map(d => ({ id: d.id, ...d.data() })) };
});
//# sourceMappingURL=wasteScan.js.map