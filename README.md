# BuangYuk

Aplikasi manajemen sampah berbasis Flutter + Firebase.

## Tech Stack

- **Frontend:** Flutter (Riverpod, GoRouter)
- **Backend:** Firebase Cloud Functions (TypeScript)
- **Database:** Cloud Firestore
- **Auth:** Firebase Authentication
- **Storage:** Firebase Storage
- **Messaging:** Firebase Cloud Messaging

## Firebase Functions

| Function | Type | Deskripsi |
|----------|------|-----------|
| `registerUser` | Callable | Registrasi user baru (email, password, role) |
| `getUserRole` | Callable | Ambil role & profile user dari token |
| `createPickup` | Callable | Buat request pickup baru |
| `acceptPickup` | Callable | Collector menerima pickup |
| `rejectPickup` | Callable | Collector menolak pickup |
| `updatePickupStatus` | Callable | Update status pickup (on_the_way, picked_up, completed, cancelled) |
| `updateCollectorLocation` | Callable | Update lokasi collector (lat, lng) |
| `uploadWasteScan` | Callable | Upload gambar scan sampah (base64) |
| `getDashboardStats` | Callable | Statistik dashboard (admin/government only) |
| `autoAssignNearestCollector` | Firestore trigger | Auto-assign collector terdekat |
| `handleRewardOnPickupComplete` | Firestore trigger | Beri poin reward saat pickup completed |
| `onPickupCreated` | Firestore trigger | Notifikasi pickup dibuat |
| `onCollectorAssigned` | Firestore trigger | Notifikasi collector diassign |
| `onPickupCompleted` | Firestore trigger | Notifikasi pickup selesai |
| `dailyStatsJob` | PubSub scheduled | Aggregasi statistik harian (setiap 24 jam) |

## Cara Panggil dari Flutter

### 1. Tambahkan dependensi

```yaml
dependencies:
  cloud_functions: ^5.x.x
```

### 2. Inisialisasi Firebase (sudah di firebase_options.dart)

### 3. Panggil Callable Functions

```dart
import 'package:cloud_functions/cloud_functions.dart';

final functions = FirebaseFunctions.instance;
functions.useFunctionsEmulator(origin: 'http://127.0.0.1:5001'); // untuk testing lokal
```

#### Register User

```dart
Future<Map<String, dynamic>> registerUser({
  required String email,
  required String password,
  required String role, // 'citizen' | 'collector' | 'admin' | 'government'
}) async {
  final result = await functions
      .httpsCallable('registerUser')
      .call({'email': email, 'password': password, 'role': role});
  return Map<String, dynamic>.from(result.data);
}
```

#### Get User Role

```dart
Future<Map<String, dynamic>> getUserRole() async {
  final result = await functions.httpsCallable('getUserRole').call();
  return Map<String, dynamic>.from(result.data);
}
// Response: { uid: String, role: String, profile: Map }
```

#### Create Pickup

```dart
Future<String> createPickup({
  required double lat,
  required double lng,
  required double weightKg,
  String? imageUrl,
}) async {
  final result = await functions.httpsCallable('createPickup').call({
    'location': {'lat': lat, 'lng': lng},
    'weightKg': weightKg,
    'imageUrl': imageUrl,
  });
  return result.data['pickupId'] as String;
}
```

#### Accept Pickup

```dart
Future<void> acceptPickup(String pickupId) async {
  await functions.httpsCallable('acceptPickup').call({'pickupId': pickupId});
}
```

#### Reject Pickup

```dart
Future<void> rejectPickup(String pickupId) async {
  await functions.httpsCallable('rejectPickup').call({'pickupId': pickupId});
}
```

#### Update Pickup Status

```dart
Future<void> updatePickupStatus({
  required String pickupId,
  required String newStatus, // 'on_the_way' | 'picked_up' | 'completed' | 'cancelled'
}) async {
  await functions.httpsCallable('updatePickupStatus').call({
    'pickupId': pickupId,
    'newStatus': newStatus,
  });
}
```

#### Update Collector Location

```dart
Future<void> updateCollectorLocation({
  required double lat,
  required double lng,
}) async {
  await functions.httpsCallable('updateCollectorLocation').call({
    'lat': lat,
    'lng': lng,
  });
}
```

#### Upload Waste Scan

```dart
Future<String> uploadWasteScan({
  required String base64Image,
  String wasteType = 'other', // 'recyclable' | 'organic' | 'other'
}) async {
  final result = await functions.httpsCallable('uploadWasteScan').call({
    'base64Image': base64Image,
    'wasteType': wasteType,
  });
  return result.data['scanId'] as String;
}
```

#### Get Dashboard Stats (Admin/Government only)

```dart
Future<Map<String, dynamic>> getDashboardStats() async {
  final result = await functions.httpsCallable('getDashboardStats').call();
  return Map<String, dynamic>.from(result.data);
}
// Response: { totalPickups: int, totalWeightKg: num, totalUsers: int, timestamp: Timestamp }
```

## Firestore Rules

Sudah dideploy dengan aturan RBAC berdasarkan custom claims (`role`). Lihat `functions/firestore.rules`.

## Storage Rules

Aturan storage ada di `storage.rules`. Aktifkan Firebase Storage di console, lalu deploy:

```bash
firebase deploy --only storage
```

## Development

```bash
# Install dependencies
cd functions && npm install

# Build TypeScript
npm run build

# Emulator lokal (butuh Java untuk firestore/storage/auth)
firebase emulators:start --only functions,firestore,storage,auth

# Deploy
firebase deploy --only functions,firestore
```
