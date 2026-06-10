# 📄 Product Requirements Document (PRD)
## BuangYuk — Aplikasi Manajemen Sampah Nasional

---

> **Versi:** 1.0.0
> **Tanggal:** Mei 2026
> **Status:** Draft
> **Bahasa:** Indonesia / English (Bilingual)

---

## 1. Ringkasan Eksekutif

**BuangYuk** adalah platform digital manajemen sampah berbasis mobile (Flutter) dan web dashboard yang menghubungkan masyarakat umum, petugas pengepul sampah, pengelola TPS/TPA, dan instansi pemerintah/dinas kebersihan dalam satu ekosistem terintegrasi. Aplikasi ini hadir untuk menyelesaikan permasalahan pengelolaan sampah di Indonesia melalui pendekatan teknologi: penjadwalan buang sampah, pemilahan berbasis AI, layanan jemput sampah on-demand, dan sistem gamifikasi bank sampah.

**Misi:** Menjadikan Indonesia lebih bersih dengan membuat pengelolaan sampah mudah, menyenangkan, dan menguntungkan bagi semua pihak.

---

## 2. Latar Belakang & Masalah

### 2.1 Permasalahan Saat Ini
- Masyarakat tidak tahu jadwal pengangkutan sampah secara pasti
- Minimnya kesadaran dan pengetahuan tentang pemilahan sampah
- Tidak ada platform yang memudahkan warga memanggil petugas pengangkut sampah secara fleksibel
- Pengelolaan bank sampah masih manual dan tidak transparan
- Data sampah nasional tersebar dan tidak terdigitalisasi dengan baik

### 2.2 Peluang
- Penetrasi smartphone di Indonesia terus meningkat
- Regulasi pemerintah terkait pengelolaan sampah (UU No. 18/2008) menuntut inovasi
- Kesadaran lingkungan masyarakat urban yang semakin meningkat
- Potensi ekonomi circular economy dari sampah yang belum dimaksimalkan

---

## 3. Tujuan Produk

| # | Tujuan | Indikator Keberhasilan |
|---|--------|------------------------|
| 1 | Meningkatkan partisipasi warga dalam memilah sampah | 60% pengguna aktif melakukan pemilahan dalam 6 bulan |
| 2 | Mengurangi sampah yang tidak terangkut | Tingkat pengangkutan sampah meningkat 40% di area terlayani |
| 3 | Mengaktifkan ekonomi bank sampah digital | Rata-rata 10.000 transaksi penukaran poin/bulan dalam tahun pertama |
| 4 | Membantu pemerintah dalam monitoring pengelolaan sampah | Dashboard real-time aktif di 10+ kota tahun pertama |

---

## 4. Pengguna & Segmentasi

BuangYuk memiliki **4 tipe pengguna utama** dengan peran dan akses yang berbeda:

### 4.1 Warga (Citizen)
- **Deskripsi:** Masyarakat umum yang menghasilkan sampah rumah tangga maupun komersial
- **Platform:** Mobile App (Flutter)
- **Kebutuhan utama:** Kemudahan membuang/menyetorkan sampah, mendapatkan reward
- **Pain point:** Tidak tahu jadwal, tidak tahu cara pilah sampah yang benar

### 4.2 Petugas / Pengepul Sampah (Collector)
- **Deskripsi:** Individu atau mitra yang bertugas mengangkut sampah dari lokasi warga
- **Platform:** Mobile App (Flutter) — tampilan role Collector
- **Kebutuhan utama:** Menerima penugasan, navigasi rute, konfirmasi pengangkutan
- **Pain point:** Tidak ada sistem penugasan yang efisien, penghasilan tidak menentu

### 4.3 Pengelola TPS / TPA (Facility Manager)
- **Deskripsi:** Operator tempat pembuangan sementara atau akhir
- **Platform:** Web Dashboard
- **Kebutuhan utama:** Monitoring volume sampah masuk, kapasitas TPS, laporan harian

### 4.4 Pemerintah / Dinas Kebersihan (Government)
- **Deskripsi:** Instansi pemerintah daerah yang bertanggung jawab atas kebersihan
- **Platform:** Web Dashboard (akses lebih luas)
- **Kebutuhan utama:** Laporan statistik, monitoring kinerja petugas, peta sebaran TPS

---

## 5. Fitur & Fungsionalitas

### 5.1 Modul Jadwal & Notifikasi Buang Sampah

**Deskripsi:** Sistem penjadwalan pengangkutan sampah berbasis lokasi yang mengirimkan notifikasi kepada warga.

**Fungsionalitas:**
- Warga mendaftarkan alamat dan wilayah RT/RW/Kelurahan
- Sistem menampilkan jadwal pengangkutan rutin dari dinas setempat
- Push notification H-1 dan H-0 sebelum jadwal pengangkutan
- Warga dapat mengatur preferensi jenis notifikasi (push, in-app)
- Integrasi kalender lokal perangkat

**User Story:**
> *"Sebagai warga, saya ingin mendapat notifikasi pagi hari sebelum petugas tiba, agar saya tidak ketinggalan membuang sampah."*

---

### 5.2 Modul Pemilahan & Edukasi Sampah

**Deskripsi:** Fitur edukasi interaktif yang membantu warga mengenali dan memilah jenis sampah dengan benar.

**Sub-fitur:**

#### a. AI Scan Sampah (Camera Detection)
- Warga mengambil foto sampah menggunakan kamera
- Model AI mengidentifikasi jenis sampah (organik, anorganik, B3, daur ulang)
- Sistem menampilkan cara pemilahan dan penanganan yang benar
- Teknologi: integrasi model computer vision (TFLite / REST API)

#### b. Scan Barcode / QR Produk
- Warga scan barcode produk kemasan
- Sistem menampilkan informasi daur ulang produk tersebut
- Database produk terintegrasi dan dapat diperbarui oleh admin

#### c. Input Manual
- Warga memilih jenis sampah dari kategori yang tersedia
- Mendapatkan panduan pembuangan/pengiriman yang sesuai

#### d. Konten Edukasi
- Artikel, infografis, dan video pendek tentang pengelolaan sampah
- Dikurasi oleh tim BuangYuk dan mitra dinas kebersihan
- Fitur bookmark dan berbagi konten
- Konten tersedia dalam Bahasa Indonesia dan Inggris

---

### 5.3 Modul Jemput Sampah On-Demand

**Deskripsi:** Layanan pemanggilan petugas pengangkut sampah secara real-time, mirip model ride-hailing.

**Alur Layanan:**

```
Warga buat request
       ↓
Sistem cari petugas terdekat (radius algoritma)
       ↓
Petugas terdekat otomatis mendapat notifikasi penugasan
       ↓
Petugas konfirmasi & berangkat (max. 60 detik)
       ↓
Warga tracking posisi petugas secara real-time
       ↓
Petugas tiba, ambil sampah, konfirmasi selesai (foto bukti)
       ↓
Warga beri rating & review
       ↓
Komisi dipotong otomatis oleh sistem
```

**Fungsionalitas Detail:**
- Warga menginput jenis dan estimasi volume sampah
- Pemilihan jadwal: segera (ASAP) atau terjadwal (booking jam tertentu)
- Real-time tracking petugas di peta
- Estimasi waktu kedatangan (ETA)
- Riwayat transaksi pickup
- Sistem rating petugas (1–5 bintang)
- Chat in-app antara warga dan petugas

**Model Komisi:**
- BuangYuk mengambil komisi per transaksi jemput sampah
- Tarif dihitung berdasarkan jarak dan/atau volume sampah
- Petugas menerima pembayaran langsung ke dompet digital dalam app

---

### 5.4 Modul Bank Sampah & Reward

**Deskripsi:** Sistem gamifikasi dan ekonomi digital untuk mendorong perilaku memilah dan menyetorkan sampah.

**Mekanisme Pengumpulan Poin:**
- Setiap kilogram sampah yang diterima petugas → poin masuk ke akun warga
- Bonus poin untuk sampah yang sudah dipilah dengan benar
- Poin tambahan dari challenge/event khusus (misal: Hari Lingkungan Hidup)
- Poin dari menyelesaikan kuis edukasi

**Opsi Penukaran Poin:**

| Jenis Penukaran | Keterangan |
|-----------------|------------|
| 💰 Uang / Saldo | Transfer ke rekening bank atau e-wallet (GoPay, OVO, Dana, dll.) |
| 🎟️ Voucher & Diskon | Partner merchant: belanja, kuliner, transportasi |
| 🏆 Gamifikasi | Badge, level, leaderboard nasional & lokal |

**Gamifikasi Tambahan:**
- Level pengguna: Pemula → Pendekar Hijau → Pahlawan Bumi → dst.
- Leaderboard per kota dan nasional
- Badge koleksi berdasarkan pencapaian (misal: "100 kg Tersimpan", "50 Kali Setoran")
- Tantangan mingguan/bulanan dengan hadiah ekstra

---

## 6. Platform & Arsitektur Teknis

### 6.1 Platform

| Platform | Pengguna | Teknologi |
|----------|----------|-----------|
| Mobile App | Warga, Petugas | Flutter (Android & iOS) |
| Web Dashboard | Admin TPS/TPA, Dinas/Pemerintah | React.js / Next.js |

### 6.2 Autentikasi

- Login Email & Password
- Login Google (OAuth 2.0)
- Social media login (Facebook/Apple sebagai opsional fase berikutnya)
- Verifikasi email saat registrasi
- Role-based access control (RBAC): Warga, Petugas, TPS Manager, Government Admin, Super Admin

### 6.3 Stack Teknologi yang Disarankan

| Layer | Teknologi |
|-------|-----------|
| Mobile | Flutter (Dart) |
| Web Dashboard | React.js / Next.js |
| Backend | Node.js (Express) atau Go |
| Database | PostgreSQL (relasional) + Redis (cache) |
| Storage | AWS S3 / Google Cloud Storage |
| Maps & Geolokasi | Google Maps Platform |
| Push Notification | Firebase Cloud Messaging (FCM) |
| AI Deteksi Sampah | TensorFlow Lite (on-device) + REST API fallback |
| Payment / Dompet | Midtrans atau Xendit |
| Realtime | Firebase Realtime DB / WebSocket |
| Auth | Firebase Auth / Supabase Auth |

### 6.4 Lokalisasi (i18n)
- Bahasa Indonesia (default)
- Bahasa Inggris
- Arsitektur mendukung penambahan bahasa di masa depan

---

## 7. Model Bisnis

### 7.1 Sumber Pendapatan Utama: Komisi Transaksi

BuangYuk mengambil **persentase komisi** dari setiap transaksi layanan jemput sampah on-demand yang berhasil.

```
Contoh:
  Tarif jemput sampah: Rp 15.000
  Komisi BuangYuk (15%): Rp 2.250
  Pendapatan petugas: Rp 12.750
```

### 7.2 Potensi Pendapatan Tambahan (Future)
- Iklan & promosi mitra merchant di halaman reward
- Langganan premium untuk fitur analitik lanjutan bagi pemerintah
- Data insights (anonymized) untuk lembaga riset atau pemerintah
- Kemitraan dengan produsen untuk program tanggung jawab produsen (Extended Producer Responsibility)

---

## 8. Cakupan Wilayah & Go-to-Market

### 8.1 Target Wilayah
- **Fase 1 (Tahun 1):** Seluruh Indonesia — launch nasional dengan fokus di kota-kota besar (Jakarta, Surabaya, Bandung, Medan, Makassar)
- **Fase 2 (Tahun 2):** Ekspansi ke kota tier-2 dan tier-3 dengan onboarding mitra dinas daerah
- **Fase 3 (Tahun 3+):** Penetrasi pedesaan & kemitraan dengan pemerintah kabupaten

### 8.2 Strategi Akuisisi Pengguna
- Kemitraan dengan dinas kebersihan kota sebagai legitimasi dan distribusi
- Program referral antar warga
- Kampanye edukasi lingkungan di media sosial
- Onboarding komunitas bank sampah yang sudah ada
- Kemitraan dengan aplikator petugas kebersihan eksisting

---

## 9. Peran & Hak Akses (RBAC)

| Fitur | Warga | Petugas | TPS Manager | Gov Admin | Super Admin |
|-------|:-----:|:-------:|:-----------:|:---------:|:-----------:|
| Lihat jadwal sampah | ✅ | ✅ | ✅ | ✅ | ✅ |
| Request jemput sampah | ✅ | — | — | — | — |
| Terima penugasan pickup | — | ✅ | — | — | — |
| Scan & identifikasi sampah | ✅ | ✅ | — | — | — |
| Kelola poin & reward | ✅ | — | — | — | — |
| Monitor kapasitas TPS | — | — | ✅ | ✅ | ✅ |
| Laporan statistik wilayah | — | — | — | ✅ | ✅ |
| Kelola pengguna & petugas | — | — | — | — | ✅ |
| Kelola konten edukasi | — | — | — | ✅ | ✅ |
| Kelola partner reward | — | — | — | — | ✅ |

---

## 10. User Journey

### 10.1 Warga — Jemput Sampah On-Demand
1. Buka app → Login
2. Pilih menu "Jemput Sekarang"
3. Konfirmasi lokasi penjemputan
4. Pilih jenis & estimasi volume sampah
5. Pilih waktu: Sekarang atau Jadwalkan
6. Sistem matching petugas terdekat otomatis
7. Warga lihat tracking petugas di peta
8. Sampah diambil → warga konfirmasi & beri rating
9. Poin reward masuk ke akun warga

### 10.2 Petugas — Menerima Penugasan
1. Buka app → Login sebagai Petugas
2. Set status: "Aktif / Siap Terima Tugas"
3. Terima notifikasi penugasan otomatis
4. Navigasi ke lokasi warga (integrasi Google Maps)
5. Tiba di lokasi → konfirmasi pengambilan + foto bukti
6. Selesaikan tugas → penghasilan masuk ke dompet

### 10.3 Admin Dinas — Dashboard Monitoring
1. Login ke web dashboard
2. Lihat peta sebaran pengangkutan hari ini
3. Review statistik volume sampah per wilayah
4. Unduh laporan bulanan (PDF/Excel)
5. Kelola jadwal pengangkutan rutin

---

## 11. Keamanan & Privasi

- Enkripsi data sensitif (AES-256 untuk data at rest, TLS 1.3 untuk data in transit)
- Kepatuhan terhadap regulasi perlindungan data pribadi (UU PDP Indonesia)
- Data lokasi pengguna hanya digunakan saat layanan aktif
- Foto bukti pengambilan sampah disimpan terbatas (30 hari, lalu dianonimkan)
- Audit log untuk aksi sensitif di web dashboard
- Autentikasi dua faktor (2FA) untuk akun admin

---

## 12. Metrik Keberhasilan (KPI)

### 12.1 Pengguna
| Metrik | Target (Tahun 1) |
|--------|-----------------|
| Total pengguna terdaftar | 500.000 |
| Monthly Active Users (MAU) | 150.000 |
| Petugas aktif terdaftar | 10.000 |
| Rating rata-rata app store | ≥ 4.3 / 5.0 |

### 12.2 Transaksi
| Metrik | Target (Tahun 1) |
|--------|-----------------|
| Total transaksi jemput sampah | 1.000.000 |
| Volume sampah terangkut | 5.000 ton |
| Rata-rata komisi per transaksi | Rp 2.500 |
| Total GMV (Gross Merchandise Value) | Rp 15 Miliar |

### 12.3 Engagement
| Metrik | Target (Tahun 1) |
|--------|-----------------|
| Pengguna aktif fitur edukasi | 40% dari MAU |
| Total poin ditukarkan | 10.000.000 poin/bulan |
| Retention rate bulan ke-3 | ≥ 35% |

---

## 13. Risiko & Mitigasi

| Risiko | Dampak | Kemungkinan | Mitigasi |
|--------|--------|-------------|----------|
| Sulitnya onboarding petugas di daerah terpencil | Tinggi | Sedang | Program pelatihan digital, kemitraan dengan koperasi lokal |
| Akurasi AI deteksi sampah rendah | Sedang | Sedang | Iterasi model secara berkala, fallback input manual |
| Resistensi dari petugas tradisional | Tinggi | Tinggi | Pendekatan inklusif, petugas eksisting dijadikan mitra |
| Regulasi daerah yang berbeda-beda | Sedang | Tinggi | Tim legal & government relations, pendekatan per dinas |
| Fraud poin/reward | Sedang | Rendah | Sistem verifikasi foto + algoritma anomali deteksi |
| Server down saat peak usage | Tinggi | Rendah | Arsitektur cloud auto-scaling, CDN, SLA 99.9% |

---

## 14. Roadmap Pengembangan

### Fase 1 — Fondasi (Bulan 1–6)
- [ ] Desain UI/UX lengkap (mobile + web)
- [ ] Setup infrastruktur cloud & database
- [ ] Modul autentikasi & manajemen pengguna (RBAC)
- [ ] Modul jadwal & notifikasi buang sampah
- [ ] Modul jemput sampah on-demand (core flow)
- [ ] Integrasi Google Maps & realtime tracking
- [ ] Web dashboard (TPS & Dinas) — versi awal

### Fase 2 — Enrichment (Bulan 7–12)
- [ ] Modul bank sampah & sistem poin
- [ ] Integrasi penukaran poin (uang, voucher)
- [ ] Modul gamifikasi (leaderboard, badge, level)
- [ ] Fitur edukasi (artikel, video, kuis)
- [ ] AI deteksi sampah (scan foto)
- [ ] Scan barcode produk
- [ ] Laporan & analitik untuk admin pemerintah
- [ ] Sistem rating & review petugas

### Fase 3 — Scale & Optimize (Bulan 13–18)
- [ ] Optimasi algoritma matching petugas
- [ ] Ekspansi kemitraan merchant reward
- [ ] Fitur komunitas & tantangan lingkungan
- [ ] Integrasi API dengan sistem dinas kebersihan daerah
- [ ] Dashboard analytics lanjutan (heatmap, prediksi volume)
- [ ] Program loyalitas tingkat lanjut
- [ ] Internasionalisasi (persiapan ekspansi regional)

---

## 15. Asumsi & Ketergantungan

**Asumsi:**
- Petugas pengepul sampah memiliki smartphone dengan koneksi internet minimal 3G
- Dinas kebersihan bersedia menyediakan data jadwal pengangkutan
- Regulasi daerah mengizinkan operasional layanan jemput sampah berbasis aplikasi

**Ketergantungan Eksternal:**
- Google Maps Platform API
- Firebase (FCM, Auth, Realtime DB)
- Payment gateway (Midtrans/Xendit)
- E-wallet partner (GoPay, OVO, Dana)
- Model AI untuk deteksi sampah (training data diperlukan)

---

## 16. Glosarium

| Istilah | Definisi |
|---------|----------|
| TPS | Tempat Pembuangan Sementara |
| TPA | Tempat Pemrosesan Akhir |
| On-demand | Layanan yang dipanggil secara real-time oleh pengguna |
| Bank Sampah | Sistem pengelolaan sampah dengan prinsip menabung sampah |
| RBAC | Role-Based Access Control — sistem hak akses berdasarkan peran |
| GMV | Gross Merchandise Value — total nilai transaksi |
| MAU | Monthly Active Users — pengguna aktif bulanan |
| ETA | Estimated Time of Arrival — estimasi waktu kedatangan |
| AI | Artificial Intelligence — kecerdasan buatan |
| FCM | Firebase Cloud Messaging — layanan push notification |

---

*Dokumen ini bersifat living document dan akan diperbarui seiring perkembangan produk.*

**Dibuat oleh:** Tim Produk BuangYuk
**Versi berikutnya:** Akan mencakup detail wireframe, API specification, dan test plan.
