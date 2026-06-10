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
exports.getReports = exports.generateReport = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const os = __importStar(require("os"));
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
const crypto = __importStar(require("crypto"));
const db = admin.firestore();
exports.generateReport = functions.runWith({ timeoutSeconds: 300, memory: '1GB' }).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const role = context.auth.token.role;
    if (!['government_admin', 'super_admin'].includes(role)) {
        throw new functions.https.HttpsError('permission-denied', 'Insufficient permissions');
    }
    const { reportType = 'monthly', format = 'csv' } = data;
    const now = new Date();
    let startDate = new Date();
    if (reportType === 'daily')
        startDate.setDate(now.getDate() - 1);
    else if (reportType === 'weekly')
        startDate.setDate(now.getDate() - 7);
    else
        startDate.setMonth(now.getMonth() - 1);
    const pickupsSnap = await db.collection('pickups')
        .where('status', '==', 'completed')
        .where('createdAt', '>=', startDate).get();
    const results = [];
    pickupsSnap.forEach(doc => {
        const p = doc.data();
        results.push({
            id: doc.id, citizenId: p.citizenId, collectorId: p.collectorId,
            weightKg: p.weightKg || 0, wasteType: p.wasteType || 'mixed',
            city: p.city || '', district: p.district || '', province: p.province || '',
            createdAt: p.createdAt ? p.createdAt.toDate().toISOString() : '',
            status: p.status
        });
    });
    let fileContent = '';
    if (format === 'json') {
        fileContent = JSON.stringify(results, null, 2);
    }
    else {
        if (results.length > 0) {
            const headers = Object.keys(results[0]).join(',');
            const rows = results.map(row => Object.values(row).map(v => `"${v}"`).join(',')).join('\n');
            fileContent = `${headers}\n${rows}`;
        }
        else {
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
exports.getReports = functions.https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const role = context.auth.token.role;
    if (!['government_admin', 'super_admin'].includes(role)) {
        throw new functions.https.HttpsError('permission-denied', 'Insufficient permissions');
    }
    const snap = await db.collection('reports').orderBy('createdAt', 'desc').limit(20).get();
    return { reports: snap.docs.map(d => ({ id: d.id, ...d.data() })) };
});
//# sourceMappingURL=reports.js.map