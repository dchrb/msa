class DateUtils {
  // Comprueba si dos fechas son el mismo día
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Comprueba si una fecha fue 'ayer' en comparación con otra
  static bool isYesterday(DateTime then, DateTime now) {
      final yesterday = now.subtract(const Duration(days: 1));
      return isSameDay(then, yesterday);
  }

  // Comprueba si dos fechas están en la misma semana (Lunes-Domingo)
  static bool isSameWeek(DateTime a, DateTime b) {
    final aMonday = a.subtract(Duration(days: a.weekday - 1));
    final bMonday = b.subtract(Duration(days: b.weekday - 1));
    return isSameDay(aMonday, bMonday);
  }

  // Comprueba si una fecha fue en la semana justo anterior a otra
  static bool isLastWeek(DateTime then, DateTime now) {
    final lastWeekDay = now.subtract(const Duration(days: 7));
    return isSameWeek(then, lastWeekDay);
  }
}
