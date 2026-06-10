import 'package:flutter/material.dart';

class MockNotifications {
  static final List<Map<String, dynamic>> notifications = [
    {
      'id': 'NOTIF-001',
      'type': 'pickup',
      'title': 'Petugas Dalam Perjalanan',
      'body': 'Ahmad Rizki sedang menuju lokasi Anda. Estimasi tiba 12:15 WIB.',
      'time': '5 menit yang lalu',
      'is_read': false,
      'icon': Icons.local_shipping,
      'color': 0xFF1B8B3C,
    },
    {
      'id': 'NOTIF-002',
      'type': 'reward',
      'title': 'Donasi Berhasil!',
      'body': 'Terima kasih! Donasi pohon bakau Anda telah diproses. Lihat e-sertifikat.',
      'time': '2 jam yang lalu',
      'is_read': false,
      'icon': Icons.eco,
      'color': 0xFF4CAF50,
    },
    {
      'id': 'NOTIF-003',
      'type': 'system',
      'title': 'Challenge Mingguan Baru',
      'body': 'Kurangi 3 kantong plastik minggu ini dan dapatkan 200 poin bonus!',
      'time': '1 hari yang lalu',
      'is_read': true,
      'icon': Icons.assignment,
      'color': 0xFFFFA726,
    },
    {
      'id': 'NOTIF-004',
      'type': 'achievement',
      'title': 'Badge Baru: Eco Warrior',
      'body': 'Selamat! Anda mendapatkan badge Eco Warrior karena telah melakukan 25 penjemputan.',
      'time': '3 hari yang lalu',
      'is_read': true,
      'icon': Icons.emoji_events,
      'color': 0xFFFFD700,
    },
    {
      'id': 'NOTIF-005',
      'type': 'pickup',
      'title': 'Jadwal Penjemputan Besok',
      'body': 'Pengangkutan rutin untuk besok jam 07:00 - 09:00 WIB. Siapkan sampah Anda!',
      'time': '1 hari yang lalu',
      'is_read': true,
      'icon': Icons.schedule,
      'color': 0xFF42A5F5,
    },
    {
      'id': 'NOTIF-006',
      'type': 'system',
      'title': 'Poin Anda Segera Kadaluarsa',
      'body': '500 poin Anda akan kadaluarsa dalam 7 hari. Segera tukarkan!',
      'time': '5 hari yang lalu',
      'is_read': true,
      'icon': Icons.timer_off,
      'color': 0xFFEF5350,
    },
  ];

  static int unreadCount = 2;
}
