import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/avatar_widget.dart';

final allUsersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
});

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _searchQuery = '';
  String _roleFilter = 'All';
  int _currentPage = 0;
  final int _perPage = 8;

  List<Map<String, dynamic>> _filterUsers(List<Map<String, dynamic>> users) {
    var filtered = users.where((u) {
      if (_roleFilter != 'All' && u['role'] != _roleFilter.toLowerCase()) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final name = (u['fullName'] as String? ?? '').toLowerCase();
        final email = (u['email'] as String? ?? '').toLowerCase();
        if (!name.contains(q) && !email.contains(q)) return false;
      }
      return true;
    }).toList();
    return filtered;
  }

  List<Map<String, dynamic>> _paginate(List<Map<String, dynamic>> users) {
    final start = _currentPage * _perPage;
    final end = start + _perPage;
    return users.sublist(start, end.clamp(0, users.length));
  }

  void _showAddOfficerDialog() {
    final nameCtl = TextEditingController();
    final emailCtl = TextEditingController();
    final phoneCtl = TextEditingController();
    String selectedRole = 'collector';
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.person_add_rounded, color: AppColors.success, size: 22)),
            const SizedBox(width: 12),
            const Text('Tambah Petugas'),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtl, decoration: InputDecoration(labelText: 'Nama Lengkap', prefixIcon: const Icon(Icons.person_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: emailCtl, decoration: InputDecoration(labelText: 'Email', prefixIcon: const Icon(Icons.email_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: phoneCtl, decoration: InputDecoration(labelText: 'Nomor Telepon', prefixIcon: const Icon(Icons.phone_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedRole,
              decoration: InputDecoration(labelText: 'Role', prefixIcon: const Icon(Icons.badge_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              items: const [
                DropdownMenuItem(value: 'collector', child: Text('Petugas Kolektor')),
                DropdownMenuItem(value: 'tps_manager', child: Text('Manajer TPS')),
                DropdownMenuItem(value: 'government_admin', child: Text('Admin Dinas')),
              ],
              onChanged: (v) => setDialogState(() => selectedRole = v!),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton.icon(
              onPressed: isSaving ? null : () async {
                if (nameCtl.text.trim().isEmpty || emailCtl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama dan email wajib diisi')));
                  return;
                }
                setDialogState(() => isSaving = true);
                try {
                  final authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailCtl.text.trim(), password: 'password123');
                  final uid = authResult.user!.uid;
                  final batch = FirebaseFirestore.instance.batch();
                  batch.set(FirebaseFirestore.instance.collection('users').doc(uid), {
                    'uid': uid, 'email': emailCtl.text.trim(), 'role': selectedRole,
                    'fullName': nameCtl.text.trim(), 'phone': phoneCtl.text.trim(), 'address': '-',
                    'district': '-', 'city': '-', 'province': '-', 'photoUrl': '', 'fcmToken': null,
                    'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
                  });
                  batch.set(FirebaseFirestore.instance.collection('rewards').doc(uid), {
                    'uid': uid, 'balance': 0, 'totalEarned': 0, 'updatedAt': FieldValue.serverTimestamp(),
                  });
                  batch.set(FirebaseFirestore.instance.collection('leaderboards').doc(uid), {
                    'uid': uid, 'fullName': nameCtl.text.trim(), 'city': '-', 'district': '-', 'province': '-',
                    'totalPoints': 0, 'totalPickups': 0, 'updatedAt': FieldValue.serverTimestamp(),
                  });
                  batch.set(FirebaseFirestore.instance.collection('notifications').doc(), {
                    'uid': uid, 'type': 'welcome', 'title': 'Selamat Bergabung!',
                    'body': 'Akun petugas telah dibuat untuk ${nameCtl.text.trim()}.',
                    'is_read': false, 'createdAt': FieldValue.serverTimestamp(),
                  });
                  await batch.commit();
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${nameCtl.text.trim()} berhasil ditambahkan sebagai $selectedRole')));
                } on FirebaseAuthException catch (e) {
                  setDialogState(() => isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${e.message ?? e.code}')));
                } catch (e) {
                  setDialogState(() => isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                }
              },
              icon: isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_rounded, size: 18),
              label: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetail(Map<String, dynamic> user, bool isDark) {
    final name = user['fullName'] as String? ?? '-';
    final email = user['email'] as String? ?? '-';
    final role = user['role'] as String? ?? 'citizen';
    final phone = user['phone'] as String?;
    final city = user['city'] as String?;
    final district = user['district'] as String?;
    final address = user['address'] as String?;
    final photoUrl = user['photoUrl'] as String?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            AvatarWidget(imageUrl: photoUrl, name: name, radius: 40),
            const SizedBox(height: 12),
            Text(name, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(email, style: GoogleFonts.inter(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
            const SizedBox(height: 16),
            _roleBadge(role, isDark),
            const SizedBox(height: 24),
            if (phone != null) _detailRow(Icons.phone_rounded, 'Telepon', phone, isDark),
            if (address != null && address != '-') ...[const SizedBox(height: 12), _detailRow(Icons.location_on_rounded, 'Alamat', address, isDark)],
            if (city != null && city != '-') ...[const SizedBox(height: 12), _detailRow(Icons.location_city_rounded, 'Kota', city, isDark)],
            if (district != null && district != '-') ...[const SizedBox(height: 12), _detailRow(Icons.map_rounded, 'Kecamatan', district, isDark)],
          ]),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, bool isDark) {
    return Row(children: [
      Icon(icon, size: 18, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
      const SizedBox(width: 10),
      Text('$label: ', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
      Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary))),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Pengguna', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddOfficerDialog,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Tambah Petugas'),
        backgroundColor: isDark ? AppColors.secondary : AppColors.primary,
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Gagal memuat data: $e')),
        data: (allUsers) {
          final filtered = _filterUsers(allUsers);
          final paginated = _paginate(filtered);
          final total = allUsers.length;
          final collectors = allUsers.where((u) => u['role'] == 'collector').length;
          final citizens = allUsers.where((u) => u['role'] == 'citizen').length;
          final admins = allUsers.where((u) => u['role'] == 'super_admin' || u['role'] == 'government_admin' || u['role'] == 'tps_manager' || u['role'] == 'admin').length;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  _summaryChip(Icons.people_rounded, 'Total', '$total', AppColors.info, '${allUsers.length} pengguna', isDark),
                  const SizedBox(width: 10),
                  _summaryChip(Icons.person_rounded, 'Warga', '$citizens', AppColors.success, '${((total > 0 ? citizens / total : 0) * 100).toInt()}%', isDark),
                  const SizedBox(width: 10),
                  _summaryChip(Icons.local_shipping_rounded, 'Petugas', '$collectors', AppColors.warning, '${((total > 0 ? collectors / total : 0) * 100).toInt()}%', isDark),
                  const SizedBox(width: 10),
                  _summaryChip(Icons.admin_panel_settings_rounded, 'Admin', '$admins', AppColors.error, '${((total > 0 ? admins / total : 0) * 100).toInt()}%', isDark),
                ]).animate().fadeIn(duration: 300.ms).moveY(begin: 15, duration: 300.ms),
                const SizedBox(height: 20),
                _buildSearchAndFilter(isDark),
                const SizedBox(height: 20),
                if (paginated.isEmpty)
                  GlassCard(padding: const EdgeInsets.all(32), child: Center(child: Column(children: [
                    Icon(Icons.search_off_rounded, size: 48, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                    const SizedBox(height: 12),
                    Text('Tidak ada pengguna ditemukan', style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
                  ])))
                else
                  ...paginated.map((u) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildUserCard(u, isDark),
                  )),
                if (filtered.length > _perPage) ...[
                  const SizedBox(height: 16),
                  _buildPagination(filtered.length, isDark),
                ],
                const SizedBox(height: 80),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        TextField(
          onChanged: (v) => setState(() { _searchQuery = v; _currentPage = 0; }),
          decoration: InputDecoration(
            hintText: 'Cari berdasarkan nama atau email...',
            prefixIcon: const Icon(Icons.search_rounded, size: 22),
            filled: true, fillColor: isDark ? AppColors.cardDark : AppColors.backgroundLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () => setState(() { _searchQuery = ''; _currentPage = 0; })) : null,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView(scrollDirection: Axis.horizontal, children: ['All', 'Citizen', 'Collector', 'Admin'].map((filter) {
            final isSelected = _roleFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter == 'All' ? 'Semua' : filter),
                selected: isSelected,
                onSelected: (_) => setState(() { _roleFilter = filter; _currentPage = 0; }),
                selectedColor: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.15),
                checkmarkColor: isDark ? AppColors.secondary : AppColors.primary,
                labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? (isDark ? AppColors.secondary : AppColors.primary) : (isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
              ),
            );
          }).toList()),
        ),
      ]),
    ).animate().fadeIn(duration: 350.ms).moveY(begin: 20, duration: 350.ms);
  }

  Widget _buildUserCard(Map<String, dynamic> user, bool isDark) {
    final name = user['fullName'] as String? ?? '-';
    final email = user['email'] as String? ?? '-';
    final role = user['role'] as String? ?? 'citizen';
    final city = user['city'] as String? ?? '-';
    final photoUrl = user['photoUrl'] as String?;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showUserDetail(user, isDark),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            AvatarWidget(imageUrl: photoUrl, name: name, radius: 24, showBadge: true, isOnline: true),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(email, style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint), overflow: TextOverflow.ellipsis),
            ])),
            const SizedBox(width: 8),
            _roleBadge(role, isDark),
            const SizedBox(width: 8),
            Text(city, style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 20, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
          ]),
        ),
      ),
    );
  }

  Widget _roleBadge(String role, bool isDark) {
    Color color; String label;
    switch (role) {
      case 'super_admin': color = AppColors.error; label = 'Super Admin'; break;
      case 'government_admin': color = AppColors.warning; label = 'Admin Dinas'; break;
      case 'tps_manager': color = AppColors.primary; label = 'Manajer TPS'; break;
      case 'admin': color = AppColors.warning; label = 'Admin'; break;
      case 'collector': color = AppColors.info; label = 'Petugas'; break;
      default: color = AppColors.success; label = 'Warga';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _summaryChip(IconData icon, String label, String value, Color color, String subtitle, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : color.withValues(alpha: 0.1))),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w500, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
        ]),
      ),
    );
  }

  Widget _buildPagination(int total, bool isDark) {
    final totalPages = (total / _perPage).ceil();
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      IconButton(
        icon: const Icon(Icons.chevron_left_rounded),
        onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
        style: IconButton.styleFrom(backgroundColor: isDark ? AppColors.cardDark : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
      const SizedBox(width: 8),
      ...List.generate(totalPages, (i) {
        final isActive = _currentPage == i;
        return GestureDetector(
          onTap: () => setState(() => _currentPage = i),
          child: Container(
            width: 36, height: 36, margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isActive ? (isDark ? AppColors.secondary : AppColors.primary) : (isDark ? AppColors.cardDark : Colors.white),
              borderRadius: BorderRadius.circular(10),
              border: !isActive ? Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1)) : null),
            child: Center(child: Text('${i + 1}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textHint)))),
          ),
        );
      }),
      const SizedBox(width: 8),
      IconButton(
        icon: const Icon(Icons.chevron_right_rounded),
        onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
        style: IconButton.styleFrom(backgroundColor: isDark ? AppColors.cardDark : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
    ]).animate().fadeIn(duration: 500.ms);
  }
}
