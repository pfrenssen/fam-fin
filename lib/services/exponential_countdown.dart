import 'dart:math' as math;

class ExponentialCountdownService {
  // Constants for the formula v = ab^(zx+c).
  // Ref. https://www.desmos.com/calculator/n21xiqgmxv
  static const double a = 1.4;
  static const double b = 0.6;
  static const double z = -1.2;
  static const double c = -2.1;

  // Calculate the function value for a given number of hours.
  double calculateValue(double hours) {
    final double exponent = (z * hours) + c;
    return a * math.pow(b, exponent);
  }

  // Formmat the value to hours and minutes, rounded up to the next 5 minutes.
  String formatValue(double value) {
    final int totalMinutes = (value * 60).round();
    final int hours = totalMinutes ~/ 60;
    final int minutes = (totalMinutes % 60 + 4) ~/ 5 * 5;

    return '${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
