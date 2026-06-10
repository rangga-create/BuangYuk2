# BuangYuk Firebase Backend

## Overview
This repository contains **production‑ready** Firebase Cloud Functions that power the BuangYuk app (Citizen, Collector, Admin/Government). It implements:
- Multi‑role authentication with custom claims (citizen, collector, admin, government)
- Pickup workflow with auto‑assign, status transitions, and real‑time tracking
- Reward engine (points per kilogram, recyclable bonus) and leaderboard
- Waste‑scan image upload (Storage) and Firestore record
- Event‑driven notifications via FCM
- Admin analytics (dashboard stats, daily aggregation)
- Full security rules (Firestore & Storage) enforcing RBAC

## Prerequisites
- **Node.js 20** (as defined in `package.json`)
- **Firebase CLI** (`npm i -g firebase-tools`) and you must be logged in (`firebase login`).
- The Firebase project must already be linked to this folder (`firebase use --add`).
- Optional: **Flutter SDK** for testing callable functions from the app.

## Setup
```bash
# Clone / open the project (already in your workspace)
cd "C:/Users/lenovo legion/OneDrive/Documents/buangYuk/functions"

# Install dependencies
npm install
```

## Build
```bash
npm run build   # compiles TypeScript to ./lib
```
The compiled entry point is `lib/index.js` as referenced in `package.json`.

## Local Testing (Emulator)
Firebase Emulator Suite lets you run Functions, Firestore, Storage, Auth and Realtime Database locally.
```bash
firebase emulators:start --only functions,firestore,storage,auth,rtdb
```
- Use the **Firebase Admin SDK** or **Firebase JS SDK** in your Flutter/Dart code pointing to `localhost:5001` (or the port displayed).
- Example callable from Flutter (see *Calling the Functions* section below).

## Deploy to Production
```bash
# Ensure you are on the correct project
firebase use <your-project-id>

# Deploy functions, rules, indexes and storage rules in one step
npm run deploy
```
After deployment you can verify:
- Functions listed in Firebase Console → Functions
- Firestore Rules → `firestore.rules`
- Storage Rules → `storage.rules`
- Indexes → `firestore.indexes.json`

## Calling the Functions from Flutter
```dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

final functions = FirebaseFunctions.instance;
final auth = FirebaseAuth.instance;

Future<void> registerCitizen(String email, String password) async {
  final result = await functions.httpsCallable('registerUser').call({
    'email': email,
    'password': password,
    'role': 'citizen',
  });
  print('Registered UID: ${result.data['uid']}');
}

Future<void> createPickup({required double lat, required double lng, required double weightKg}) async {
  final uid = auth.currentUser?.uid;
  if (uid == null) throw 'Not logged in';
  final result = await functions.httpsCallable('createPickup').call({
    'location': {'lat': lat, 'lng': lng},
    'weightKg': weightKg,
  });
  print('Pickup ID: ${result.data['pickupId']}');
}

Future<void> uploadWasteScan(String base64Image, String wasteType) async {
  final result = await functions.httpsCallable('uploadWasteScan').call({
    'base64Image': base64Image,
    'wasteType': wasteType,
  });
  print('Scan saved: ${result.data['scanId']}');
}
```
All callable functions perform server‑side validation and will throw a `FirebaseFunctionsException` with proper error codes if the request is invalid.

## Security Rules Overview
- **Firestore** (`firestore.rules`) enforces role‑based read/write permissions per collection.
- **Storage** (`storage.rules`) only allows authenticated users to upload waste‑scan images under `/waste_scans/{uid}/...` with size ≤ 5 MB and MIME type `image/*`.
- Review the rules files if you need to extend permissions.

## Indexes
Composite indexes defined in `firestore.indexes.json` are required for:
- Querying pickups by `status` and `createdAt`.
- Sorting reward transactions by user and timestamp.
- Leaderboard ranking by `totalPoints`.
Deploying with `npm run deploy` automatically creates them.

## CI/CD (Optional)
You can add a GitHub Actions workflow that runs `npm ci`, `npm run build`, and `firebase deploy` on pushes to `main`. Example snippet:
```yaml
name: Deploy Firebase Functions
on:
  push:
    branches: [ main ]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '20'
      - run: npm ci
      - run: npm run build
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          channelId: live
```
Store the service‑account JSON as a secret named `FIREBASE_SERVICE_ACCOUNT`.

---
### 🎉 Done!
All backend source files, configuration, security rules, indexes, and a complete README are now ready. You can proceed with the steps above to build, test locally, and deploy to your Firebase project.

If you need any further tweaks (e.g., adding extra domain‑specific logic, updating point formulas, or integrating additional Cloud Scheduler jobs), just let me know. Happy coding!
