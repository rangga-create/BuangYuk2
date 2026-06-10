class MockAdmin {
  static final Map<String, dynamic> analytics = {
    'total_users': 15234,
    'active_users': 8921,
    'new_users_today': 47,
    'total_collectors': 128,
    'active_collectors': 96,
    'total_pickups': 45231,
    'pickups_today': 312,
    'pickups_this_week': 2104,
    'total_waste_kg': 284500,
    'waste_today_kg': 3850,
    'waste_this_week_kg': 25700,
    'avg_rating': 4.7,
    'completion_rate': 0.94,
    'avg_response_time_min': 18,
    'total_tps': 45,
    'tps_operational': 42,
    'tps_at_capacity': 8,
    'total_rewards_claimed': 12850,
    'total_points_issued': 8925000,
    'monthly_growth': 0.12,
    'revenue': 285000000,
  };

  static final List<Map<String, dynamic>> weeklyWasteData = [
    {'day': 'Sen', 'organik': 320, 'anorganik': 450, 'campur': 280},
    {'day': 'Sel', 'organik': 280, 'anorganik': 520, 'campur': 310},
    {'day': 'Rab', 'organik': 350, 'anorganik': 480, 'campur': 290},
    {'day': 'Kam', 'organik': 300, 'anorganik': 510, 'campur': 350},
    {'day': 'Jum', 'organik': 380, 'anorganik': 490, 'campur': 270},
    {'day': 'Sab', 'organik': 250, 'anorganik': 380, 'campur': 200},
    {'day': 'Min', 'organik': 180, 'anorganik': 290, 'campur': 160},
  ];

  static final List<Map<String, dynamic>> pickupCompletionData = [
    {'month': 'Jan', 'completed': 3200, 'cancelled': 120},
    {'month': 'Feb', 'completed': 3400, 'cancelled': 100},
    {'month': 'Mar', 'completed': 3800, 'cancelled': 90},
    {'month': 'Apr', 'completed': 4200, 'cancelled': 85},
    {'month': 'Mei', 'completed': 4500, 'cancelled': 70},
  ];

  static final List<Map<String, dynamic>> tpsData = [
    {'name': 'TPS Merdeka', 'capacity': 85, 'status': 'high', 'location': 'Jakpus'},
    {'name': 'TPS Senayan', 'capacity': 65, 'status': 'medium', 'location': 'Jaksel'},
    {'name': 'TPS Kelapa Gading', 'capacity': 92, 'status': 'critical', 'location': 'Jakut'},
    {'name': 'TPS Cilandak', 'capacity': 45, 'status': 'low', 'location': 'Jaksel'},
    {'name': 'TPS Duren Sawit', 'capacity': 78, 'status': 'high', 'location': 'Jaktim'},
    {'name': 'TPS Tambora', 'capacity': 55, 'status': 'medium', 'location': 'Jakbar'},
  ];

  static final List<Map<String, dynamic>> topCollectors = [
    {'name': 'Ahmad Rizki', 'pickups': 847, 'rating': 4.8, 'avatar': ''},
    {'name': 'Doni Saputra', 'pickups': 721, 'rating': 4.7, 'avatar': ''},
    {'name': 'Rina Marlina', 'pickups': 694, 'rating': 4.9, 'avatar': ''},
    {'name': 'Fajar Hidayat', 'pickups': 658, 'rating': 4.6, 'avatar': ''},
  ];

  static final List<Map<String, dynamic>> recentReports = [
    {'id': 'RPT-001', 'type': 'sampah_berserakan', 'title': 'Sampah berserakan di TPS', 'location': 'Jl. Mawar No. 12', 'status': 'open', 'date': '2 jam yang lalu', 'priority': 'high'},
    {'id': 'RPT-002', 'type': 'petugas_tidak_datang', 'title': 'Petugas tidak datang', 'location': 'Jl. Anggrek No. 7', 'status': 'in_progress', 'date': '5 jam yang lalu', 'priority': 'medium'},
    {'id': 'RPT-003', 'type': 'tps_penuh', 'title': 'TPS penuh', 'location': 'Jl. Merdeka', 'status': 'open', 'date': '1 hari yang lalu', 'priority': 'high'},
    {'id': 'RPT-004', 'type': 'saran', 'title': 'Usul penambahan jadwal', 'location': 'Kelurahan Menteng', 'status': 'resolved', 'date': '3 hari yang lalu', 'priority': 'low'},
  ];

  static final List<Map<String, dynamic>> wasteCategories = [
    {'name': 'Organik', 'percentage': 35, 'kg': 99575, 'color': 0xFF4CAF50},
    {'name': 'Anorganik', 'percentage': 42, 'kg': 119490, 'color': 0xFF42A5F5},
    {'name': 'Campur', 'percentage': 23, 'kg': 65435, 'color': 0xFFFFA726},
  ];

  static final List<Map<String, dynamic>> regionData = [
    {'region': 'Jakarta Pusat', 'pickups': 8940, 'waste_kg': 56200, 'collectors': 28},
    {'region': 'Jakarta Selatan', 'pickups': 10240, 'waste_kg': 64800, 'collectors': 32},
    {'region': 'Jakarta Utara', 'pickups': 7890, 'waste_kg': 49100, 'collectors': 24},
    {'region': 'Jakarta Timur', 'pickups': 9560, 'waste_kg': 60200, 'collectors': 26},
    {'region': 'Jakarta Barat', 'pickups': 8601, 'waste_kg': 54200, 'collectors': 18},
  ];
}
