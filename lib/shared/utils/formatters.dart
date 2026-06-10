import 'package:intl/intl.dart';

class Formatters {
  static String formatPoints(int points) {
    if (points >= 1000) {
      return NumberFormat('#,##0', 'id_ID').format(points);
    }
    return points.toString();
  }

  static String formatKg(double kg) {
    if (kg >= 1000) {
      return '${(kg / 1000).toStringAsFixed(1)} ton';
    }
    return '${kg.toStringAsFixed(1)} kg';
  }

  static String formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  static String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
      if (diff.inDays == 1) return 'Kemarin';
      if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';

      return DateFormat('dd MMM yyyy', 'id').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatTime(String timeStr) {
    try {
      final time = DateTime.parse(timeStr);
      return DateFormat('HH:mm', 'id').format(time);
    } catch (_) {
      return timeStr;
    }
  }

  static String dateLabel(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) return 'Hari Ini';
      if (diff.inDays == 1) return 'Kemarin';

      return DateFormat('EEEE, dd MMM yyyy', 'id').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
