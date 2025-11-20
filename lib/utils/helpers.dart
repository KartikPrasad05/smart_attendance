import 'dart:math';

class Helpers {
  /// Generates a 4-digit PIN (1000–9999)
  static String generatePinCode() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  /// Unique session ID like: SESSION_1698792349876_123
  static String generateSessionId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'SESSION_${timestamp}_${random.nextInt(1000)}';
  }

  /// Unique attendance ID like: ATTEND_1698792349876_456
  static String generateAttendanceId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ATTEND_${timestamp}_${random.nextInt(1000)}';
  }

  /// Formats a DateTime to DD/MM/YYYY HH:MM
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
