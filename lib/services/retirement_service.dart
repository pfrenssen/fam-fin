import 'dart:math';
import '../models/frequency_period.dart';

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

  /// Calculates the future value of a one-time investment
  ({double invested, double interest, double total})
  calculateOneTimeOpportunityCost(
    double amount,
    DateTime? birthDate,
    int retirementAge,
  ) {
    if (birthDate == null) return (invested: 0, interest: 0, total: 0);

    final days = calculateDaysUntilRetirement(birthDate, retirementAge);
    final years = days / 365.25; // Account for leap years
    final rate = 0.08; // 8% annual return

    final invested = amount;
    final total = amount * pow(1 + rate, years);
    final interest = total - invested;

    return (invested: invested, interest: interest, total: total);
  }

  /// Calculates the future value of periodic investments
  ({double invested, double interest, double total})
  calculateRecurringOpportunityCost(
    double amount,
    DateTime? birthDate,
    int retirementAge,
    int frequencyCount,
    FrequencyPeriod frequencyPeriod,
  ) {
    if (birthDate == null) return (invested: 0, interest: 0, total: 0);

    final days = calculateDaysUntilRetirement(birthDate, retirementAge);
    final rate = 0.08; // 8% annual return

    // Calculate the number of days between investments
    final daysPerPeriod = switch (frequencyPeriod) {
      FrequencyPeriod.week => 7,
      FrequencyPeriod.month => 30.44, // Average days per month
      FrequencyPeriod.year => 365.25, // Account for leap years
    };
    final investmentInterval = daysPerPeriod / frequencyCount;

    // Calculate number of investments
    final numberOfInvestments = (days / investmentInterval).floor();
    if (numberOfInvestments <= 0) return (invested: 0, interest: 0, total: 0);

    double total = 0;
    for (var i = 0; i < numberOfInvestments; i++) {
      final yearsRemaining = (days - (i * investmentInterval)) / 365.25;
      total += amount * pow(1 + rate, yearsRemaining);
    }

    final invested = amount * numberOfInvestments;
    final interest = total - invested;

    return (invested: invested, interest: interest, total: total);
  }
}
