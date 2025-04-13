class RetirementService {
  /// Calculates the number of days until retirement based on the birth date and
  /// retirement age.
  int calculateDaysUntilRetirement(DateTime? birthDate, int retirementAge) {
    if (birthDate == null) return 0;

    final retirementDate = DateTime(
      birthDate.year + retirementAge,
      birthDate.month,
      birthDate.day,
    );
    final now = DateTime.now();

    if (retirementDate.isBefore(now)) return 0;

    return retirementDate.difference(now).inDays;
  }

  (int years, int months, int days) calculateTimeUntilRetirement(
    DateTime? birthDate,
    int retirementAge,
  ) {
    if (birthDate == null) return (0, 0, 0);

    final retirementDate = DateTime(
      birthDate.year + retirementAge,
      birthDate.month,
      birthDate.day,
    );
    final now = DateTime.now();

    if (retirementDate.isBefore(now)) return (0, 0, 0);

    var years = retirementDate.year - now.year;
    var months = retirementDate.month - now.month;
    var days = retirementDate.day - now.day;

    if (days < 0) {
      months--;
      days += DateTime(now.year, now.month + 1, 0).day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return (years, months, days);
  }

  String formatDaysUntilRetirement(DateTime? birthDate, int retirementAge) {
    if (birthDate == null) return 'N/A';

    final retirementDate = DateTime(
      birthDate.year + retirementAge,
      birthDate.month,
      birthDate.day,
    );

    if (retirementDate.isBefore(DateTime.now())) return 'Already retired';

    final (years, months, days) = calculateTimeUntilRetirement(
      birthDate,
      retirementAge,
    );

    if (years > 0) {
      return '$years years, $months months, $days days';
    } else if (months > 0) {
      return '$months months, $days days';
    }
    return '$days days';
  }
}
