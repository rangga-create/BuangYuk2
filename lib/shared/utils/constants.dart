import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'BuangYuk';
  static const String appTagline = 'Bijak Kelola Sampah';

  static const List<String> wasteTypes = [
    'Organik',
    'Plastik',
    'Kertas',
    'Campur',
  ];

  static const List<Map<String, dynamic>> wasteTypeIcons = [
    {'label': 'Organik', 'icon': Icons.eco, 'color': Color(0xFF4CAF50)},
    {'label': 'Plastik', 'icon': Icons.local_drink, 'color': Color(0xFF42A5F5)},
    {'label': 'Kertas', 'icon': Icons.description, 'color': Color(0xFFFFA726)},
    {'label': 'Campur', 'icon': Icons.recycling, 'color': Color(0xFFAB47BC)},
  ];

  static const List<Map<String, dynamic>> levels = [
    {'name': 'Warga Baru', 'min_points': 0, 'icon': Icons.person_outline},
    {'name': 'Warga Peduli', 'min_points': 100, 'icon': Icons.eco},
    {'name': 'Pendekar Hijau', 'min_points': 500, 'icon': Icons.eco},
    {'name': 'Pelindung Bumi', 'min_points': 2000, 'icon': Icons.public},
    {'name': 'Ksatria Lingkungan', 'min_points': 5000, 'icon': Icons.shield},
  ];
}
